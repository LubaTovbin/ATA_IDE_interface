	//modified by Luba Tovbin
	//July, 2013

module nand_lane (      
      IO,
      RXB,
      ALE,
      CLE,
      xCE,
      xRE,
      xWE);


/*   NAND interface: (assume 1 lane for now) */
inout [7:0]     IO;
output          RXB;
input           ALE;
input           CLE;
input           xCE;
input           xRE;
input           xWE;

reg [7:0]  IO_o; 
reg        io_oe; 
reg        io_oe_o;
reg [23:0] page_addr;
reg [8:0]  byte_addr;
reg        read_mode;
reg        data_input_mode;
reg        read_mode_o;      
reg        data_input_mode_o;
reg        expect_addr;
reg        RXB;
reg [7:0]  data_buf [511:0];  

reg       ram_ce   ;
reg       ram_rd_en;
reg       ram_wr_en;
reg [32:0]ram_adr  ; 
reg [7:0] ram_data_drv ;
 
wire [7:0]ram_data ; 
reg      io_out_en;

reg [9:0] j   ; 
reg [9:0] j_o ;
reg cr_st, nx_st;

integer    byte_index;
integer    addr_index; 
integer    i;

`include "steed.vh"

task load_page;  // load page from nand
input integer page_addr;
   begin
                                                                             
     for (i = 0; i < 512;  i = i + 1) begin 
         ram_adr = (page_addr << 9) + byte_addr + i;
         ram_ce    = 1'b1; 
         ram_rd_en = 1'b1;
         #1                                                  
         data_buf[i] = ram_data;
         #1 
         ram_rd_en = 1'b0;                                                  
         ram_ce    = 1'b0; 
         ram_adr = 0;                                                       
     end                                                                     
                                                                                                   
     end                                                                                           
endtask                                                                                            

task write_page;  // write page_buf into nand
input integer page_addr;
   begin  
   
     for (i = 0; i < 512;  i = i + 1) begin 
         ram_adr = (page_addr << 9) + byte_addr + i;
         ram_ce    = 1'b1; 
         ram_wr_en = 1'b1;                                                  
         ram_data_drv = data_buf[i];
         #1 
         ram_wr_en = 1'b0;                                                  
         ram_ce    = 1'b0; 
         ram_adr = 0;                                                       
     end                     

   end
endtask

//assign io_out_en = io_oe && !xCE;
assign IO = (io_out_en) ? IO_o : 8'hzz;
assign ram_data = (ram_ce && ram_wr_en) ? ram_data_drv : 8'hzz;

initial begin
        RXB       <= 1'b1;
        io_out_en <= 1'b0;
        j         <= 10'd0; 
        cr_st     <= 1'b0;
        ram_ce    <= 1'b0;
        ram_wr_en <= 1'b0;
        ram_rd_en <= 1'b0;
        
       end
                                                        
// command and address decoder
//Based on Toshiba, TC58DVG02A1FTI0 
always @(posedge xWE)
   if (!xCE) begin  // only if xCE is selected
                 if (CLE) begin   // command phase           
                             case (IO)
                                8'haa: begin  //Read mode(1)
                                   byte_addr[8] = 1'b0;
                                   read_mode = 1'b1;
                                   expect_addr = 1'b1;
                                   addr_index = 0;
                                end
                                8'h01: begin //Read mode(2)
                                   byte_addr[8] = 1'b1;
                                   read_mode = 1'b1;
                                   expect_addr = 1'b1;
                                   addr_index = 0;               
                                end
                                8'h80: begin //Serial Data Input
                                   byte_addr[8] = 1'b0;
                                   read_mode = 1'b0;
                                   data_input_mode = 1'b1;
                                   expect_addr = 1'b1;
                                   addr_index = 0;
                                   byte_index = 0;
                                end
                                8'h10: begin //Auto Program (True)
                                   if (data_input_mode && addr_index==4) begin
                                      #10;
                                      RXB = 1'b0;
                                      load_page(page_addr);
                                      #`tPROG;
                                      RXB = 1'b1;
                                   end
                                end
                             endcase
                         end //CLE
                 else 
                           if (ALE) begin
                                         if (expect_addr) begin
                                            			      case (addr_index)
                                            			       		0: byte_addr[7:0]   = IO;
                                            			       		1: page_addr[7:0]   = IO;
                                            			       		2: page_addr[15:8]  = IO;
                                            			       		3: page_addr[23:16] = IO;
                                            			      endcase
                                                              addr_index = addr_index + 1;
                                            			      if (read_mode && addr_index==4) begin 
                                            			      								  #10;
                                            			      								  RXB = 1'b0;                              
                                            			      								  load_page(page_addr);  //Read Mode (1), 00h
                                            			      								  #`tR;
                                            			      								  RXB = 1'b1;
                                            			                                      end
                                                          end//expect_addr   
                                     end//ALE  
                                                        
                               
                else 
                         if (data_input_mode) begin   //data goes into nand_lane module                                              
                                                   	data_buf[byte_index] = IO;
                                                   	byte_index = byte_index + 1;
                                                   	if (byte_index == 512) write_page(page_addr);                                                     
                                                   end

      end //!xCE          

always @(posedge xRE)                   
    if (!xCE) begin
                  if (read_mode )  begin                    
       		                           IO_o  <= data_buf[j];        
       		                           io_out_en <= 1'b1;            
       		                           j     <= j + 1;             
     		                       end   
     		      else begin 
     		               io_out_en <= 1'b0;
     		               j        <= 10'd0;
     		           end                                    
     		 end  
     		 
//always @(xCE)
//    if (xCE) 
//           read_mode_o = 1'b0;
//   
//    else if (!xCE)                       
//                 read_mode_o  = read_mode;       
//     		                   

   ram_8bit nand_ram (     
   			.address(ram_adr  ),
   			.data   (ram_data ),
   			.cs     (ram_ce   ),
    		.we     (ram_wr_en),
    		.re     (ram_rd_en)    		        
    );

endmodule




//always @(posedge xRE)
//    if (!xCE)  begin                    
//       		       io_oe <= io_oe_o;                 
//       		       j <= j_o;  
//       		       cr_st <= nx_st;                                                       		       
//     		   end       
//     		                                            
//always @(*) begin  
//                io_oe_o = io_oe;
//                j_o     = j;
//                case (cr_st)
//                   1'b0: begin 
//                             if ( j_o == 10'd512 ) begin
//                                                      nx_st = 1'b1;   
//                                                      j_o   = 10'd0;                                                       
//                                                  end  
//                             else begin
//                                      IO_o = data_buf[j]; 
//                                      io_oe_o = 1'b1;     
//                                      j_o = j_o + 1; 
//                                      nx_st = 1'b0;     
//                                 end                     		                            
//                   end//1'b0;
//                   
//                   1'b1: begin  
//                       if (read_mode_sm == 1'b0 && read_mode == 1'b1 ) nx_st = 1'b0;
//                       else nx_st = 1'b1;
//                             
//                   end
//                endcase 
//                                
//end//(*)

                                          