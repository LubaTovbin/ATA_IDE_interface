	//modified by Luba Tovbin
	//July, 2013
module ide_host (
      DD,
      DIOR,
      DIOW,
      IOCHRDY,
      CS,
      DA,
      INTRQ,
      DMARQ,
      DMACL,
      CSEL);
`include "steed.vh"
/*   IDE interface: */
inout    [15:0] DD;
output          DIOR;
output          DIOW;
input           IOCHRDY;
output    [1:0] CS;
output    [2:0] DA;
input           INTRQ;
input           DMARQ;
output          DMACL;
output          CSEL;

reg      [15:0] DD_drv;
reg             DIOR;
reg             DIOW;
reg       [1:0] CS;
reg       [2:0] DA;
reg             DMACL;
reg             CSEL;

reg [`FIFO_DATA_WIDTH -1:0]  data_buf [0:`FIFO_DEPTH -1];
reg         rom_ce   ;
reg         rom_rd_en;
reg  [`FIFO_ADDR_WIDTH -1:0]  rom_adr  ;  
wire [`FIFO_DATA_WIDTH -1:0] rom_data ; 

parameter t1 = 25;
parameter t2 = 100;
parameter t3 = 20;
parameter t4 = 10;
parameter t5 = 20;
parameter t6 = 5;
parameter t9 = 100;

   assign DD = DD_drv;

   initial begin
     DD_drv = 16'hzzzz;
     DIOR = 1'b1;
     DIOW = 1'b1;
     CS = 2'bxx;
     DA = 3'bxxx;
     DMACL = 1'bx;
     CSEL = 1'bx;
   end

   task check_read_reg;
     input [1:0] cs;
     input [2:0] da;
     input [15:0] data;
     begin
       CS = cs;
       DA = da;
       #t1;
       DIOR = 1'b0;
       #t2;
       DIOR = 1'b1;
       if (data[15:0] !== DD[15:0])
          $display("ERROR: %t ns, data read does not match expected", $time);
       #t9;
       CS = 2'bxx;
       DA = 3'bxxx;    
     end
endtask//check_read_reg
 
task write_reg;
     input [1:0] cs;
     input [2:0] da;
     input [15:0] data;
     begin
       CS = cs;
       DA = da;
       #t1;
       DIOW = 1'b0;  
       #(t2-t3);
       DD_drv = data;
       #t3;
       DIOW = 1'b1;
       #t4;
       CS = 2'bxx;
       DA = 3'bxxx;           
       DD_drv = 16'bz;
     end
endtask//write_reg   

task read_reg;
     input [1:0] cs;
     input [2:0] da;
     begin        
       CS = cs;
       DA = da;
       DIOR = 1'b0;                                    
       #t2;                                            
       DIOR = 1'b1;                                    
       #t9;                                            
       CS = 2'bxx;                                     
       DA = 3'bxxx;                                           
     end
endtask//read_reg

integer i;
task read_from_nand;
     begin
          for (i = 0; i < `FIFO_DEPTH; i = i + 1) begin          
			  DIOR = 1'b0;
			  #t2;         
			  DIOR = 1'b1;   
			  #t9;                 
		  end//for	       
     end
endtask//read_from_nand  

task load_page;
   begin
                                                                             
     for (i = 0; i < `FIFO_DEPTH;  i = i + 1) begin 
         rom_adr = i;
         rom_ce    = 1'b1; 
         rom_rd_en = 1'b1;
         #1;                                                  
         data_buf[i] = rom_data;
         #1; 
         rom_rd_en = 1'b0;                                                  
         rom_ce    = 1'b0; 
         rom_adr = 0;                                                       
     end                                                                     
                                                                                                   
     end                                                                                           
endtask                         
 
task send_page_to_nand;  // load page to fifo
   begin                                                                             
     for (i = 0; i < `FIFO_DEPTH;  i = i + 1) begin          
         DIOW = 1'b0;                                                          
         DD_drv = data_buf[i];                                                          
		 #100; 
		 DIOW = 1'b1;         
         DD_drv = 16'bz;
         #200;                                                      
     end                                                                     
                                                                                                   
     end                                                                                           
endtask                          

   rom_16bit host_rom (     
   	.ce     (rom_ce   ),
   	.read_en(rom_rd_en),
   	.address(rom_adr  ),
    .data   (rom_data )    
    );                
                                       
   
initial begin
  #300;
//	write_reg (`CS0, `IDE_SEC_CNT, {8'hx, 8'h00});
//	write_reg (`CS0, `IDE_SEC_NUM, {8'hx, 8'h00});
//	write_reg (`CS0, `IDE_CYL_LO,  {8'hx, 8'h00});
//	write_reg (`CS0, `IDE_CYL_HI,  {8'hx, 8'h00});
//	write_reg (`CS0, `IDE_COMMAND, {8'hx, `IDE_READ_SECTORS});  
////  #110000;
    write_reg (`CS0, `IDE_SEC_CNT, {8'hx, 8'h07});
	write_reg (`CS0, `IDE_SEC_NUM, {8'hx, 8'h05});
	write_reg (`CS0, `IDE_CYL_LO,  {8'hx, 8'h01});
	write_reg (`CS0, `IDE_CYL_HI,  {8'hx, 8'h00});
	write_reg (`CS0, `IDE_COMMAND, {8'hx, `IDE_WRITE_SECTORS});	
	#300;
	load_page;
	send_page_to_nand;
end

always @(*) 
     if (INTRQ) begin
                    #200;
                    read_reg(`CS0, `IDE_STATUS); //read status register    
                    #200;
                    read_from_nand; 
                end   
                       
endmodule

