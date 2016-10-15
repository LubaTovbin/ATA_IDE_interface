	
	//modified by Luba Tovbin & Sweta Shah
    //July, 2013
	/* the top control block */
	module steed ( rst_n,
	               clk, 
	               steed_dd_out,
	               steed_dd_oe,
	               io_dd_in,
	               io_dior,
	               io_diow,
	               io_cs,
	               io_da,
	               steed_intrq,
	               steed_dmarq,
	               io_dmacl,
	               io_csel,
	
	               io_io_in,
	               steed_io_out,
	               steed_io_oe,
	               io_rxb,
	               io_ale, 
	               io_cle,
	               io_xce,
	               io_xre,
	               io_xwe,
	               
	               fifo_host_nand,
	               fifo_wr_cs,
	               fifo_rd_cs,
	               fifo_rd_en,
	               fifo_wr_en,               
	               fifo_full,
	               fifo_empty,
	               steed_fifo_in,
	               steed_fifo_out
	              
	        );
	`include "steed.vh" 
	input              rst_n;
	input              clk;              
	output      [15:0] steed_dd_out;
	output             steed_dd_oe;
	input       [15:0] io_dd_in;
	input              io_dior;
	input              io_diow;
	input        [1:0] io_cs;
	input        [2:0] io_da;
	output             steed_intrq;
	output             steed_dmarq;
	input              io_dmacl;
	input              io_csel;
	input  [`IO_MSB:0] io_io_in; 
	
	output [`IO_MSB:0] steed_io_out;
	output             steed_io_oe; 
	
	input               io_rxb; 
	output              io_ale;
	output              io_cle;
	output              io_xce;
	output              io_xre;
	output              io_xwe; 
	
	input  [`FIFO_DATA_WIDTH-1:0] steed_fifo_out;
	output [`FIFO_DATA_WIDTH-1:0] steed_fifo_in; 
	output                   fifo_host_nand;
	output                   fifo_wr_cs;
	output                   fifo_rd_cs;
	output                   fifo_rd_en;
	output                   fifo_wr_en; 
	
	input                    fifo_full;
	input                    fifo_empty;
	
	wire  [15:0]        io_dd_in;
	wire  [7:0]        reg_status;
	wire  [15:0]       reg_data;
	wire  [7:0]        reg_features;
	wire  [7:0]        reg_sector_count;
	wire  [7:0]        reg_sector_number;
	wire  [7:0]        reg_cylinder_low;
	wire  [7:0]        reg_cylinder_high;
	wire  [7:0]        reg_drive;
	wire  [7:0]        reg_head;
	wire  [7:0]        reg_dev_control;
	wire  [7:0]        reg_command;
	wire  [15:0]       reg_dd_out;
	wire  [27:0]       reg_lba;
	wire               reg_cmdin_tgl;  // to be sync'd by internal clock   
	wire               rd_status;  
	
	reg  [15:0]       steed_dd_out_pre;	
	reg               rd_stus_smp;   
	reg               fifo2host_oe;
	reg              steed_io_oe; 
	reg   [7:0]      steed_io_out;
	reg              io_ale;
	reg              io_cle;
	reg              io_xce;
	reg              io_xre;
	reg              io_xwe;
	reg              busy;
	reg              drdy;  // drive ready
	reg              dwf;   // drive write fault
	reg              dsc;   // drive seek complete
	reg              drq;   // data request
	reg              err;   // error reg contains more info when asserted
   	reg              steed_intrq;
	   
	parameter NAND_IDLE        = 5'd0 ;
	parameter NAND_CMND        = 5'd1 ;	
	parameter ST_WE1           = 5'd4 ;
	parameter NAND_ADDR        = 5'd2 ;
	parameter ST_WE2           = 5'd3 ; 
	parameter WAIT_RXB_LO      = 5'd7 ;
	parameter WAIT_RXB_HI      = 5'd8 ;    
	parameter NAND_DATA_OUT_1  = 5'd9 ;
	parameter ST_RE1           = 5'd13;
	parameter NAND_DATA_OUT_2  = 5'd10;
	parameter ST_RE2           = 5'd14;	     
	parameter NAND_DATA_IN_1   = 5'd11;
	parameter ST_WE3           = 5'd5 ;
	parameter NAND_DATA_IN_2   = 5'd12;
	parameter ST_WE4           = 5'd6 ;   
	parameter WAIT_STEED_DD_OE = 5'd15; 
	parameter DATA_TO_HOST     = 5'd16; 
	parameter LAST_ONE         = 5'd17; 
	parameter WAIT_OE          = 5'd18;
	parameter HOST_DATA_IN     = 5'd19; 
	parameter WAIT_STEED_DD_IE = 5'd20;
	parameter PREP             = 5'd21; 
	parameter LAST_1           = 5'd22;
	parameter LAST_2           = 5'd23;
	parameter ST_WE            = 5'd24;
		
	reg  [4:0] nxt_st;
	reg  [4:0] cur_st;
	reg  [1:0] cntr; 
	reg  [1:0] cntr_o;
	
	reg                    fifo2host_oe_o;
	reg                   steed_io_oe_o  ;
	reg             [7:0] steed_io_out_o ; 

	reg [(`FIFO_DATA_WIDTH >> 1)-1:0] fifo_in_l_o;
	reg [(`FIFO_DATA_WIDTH >> 1)-1:0] fifo_in_h_o;
	reg                   io_ale_o    ;
	reg                   io_cle_o    ;
	reg                   io_xce_o    ;
	reg                   io_xre_o    ;
	reg                   io_xwe_o    ;
	
    reg [(`FIFO_DATA_WIDTH >> 1)-1:0] fifo_in_l;
    reg [(`FIFO_DATA_WIDTH >> 1)-1:0] fifo_in_h; 
    reg                   host_nand;	
	reg                   wr_cs   ;
	reg                   rd_cs   ;
	reg                   rd_en   ;
	reg                   wr_en   ;
	reg                   host_nand_o;
	reg                   wr_cs_o ;
	reg                   rd_cs_o ;
	reg                   rd_en_o ;
	reg                   wr_en_o ; 
	reg drq_o;
	reg busy_o;
	reg busy_smp;
	
	reg reg_cmdin_tgl_0;
	reg reg_cmdin_tgl_1;  
	
 //////////////////////////////////////////////////////////////////////////////////////////////	
	steed_regs steed_regs0(
	               .io_dd_in          (io_dd_in),  
	               .io_dior           (io_dior),
	               .io_diow           (io_diow),
	               .rst_n             (rst_n),
	               .io_cs             (io_cs),
	               .io_da             (io_da),
	               .reg_status        (reg_status),
	               .reg_data          (reg_data),
	               .reg_features      (reg_features),
	               .reg_sector_count  (reg_sector_count),
	               .reg_sector_number (reg_sector_number),
	               .reg_cylinder_low  (reg_cylinder_low),
	               .reg_cylinder_high (reg_cylinder_high),
	               .reg_head          (reg_head),
	               .reg_dev_control   (reg_dev_control),
	               .reg_command       (reg_command),
	               .reg_dd_out        (reg_dd_out),
	               .reg_lba           (reg_lba),
	               .reg_cmdin_tgl     (reg_cmdin_tgl),
	               .rd_status         (rd_status) 
	);
	
	assign steed_dd_oe = ~io_dior;
	assign steed_dd_ie = ~io_diow; 
	assign steed_dd_out  = steed_dd_out_pre; 
	assign reg_status[7] = busy;
	assign reg_status[6] = drdy;
	assign reg_status[5] = dwf;
	assign reg_status[4] = dsc;
	assign reg_status[3] = drq;
	assign reg_status[0] = err;
	
	assign fifo_host_nand = host_nand;
	assign fifo_wr_cs = wr_cs;
	assign fifo_rd_cs = rd_cs;
	assign fifo_rd_en = rd_en;
	assign fifo_wr_en = wr_en; 
	assign steed_fifo_in = {fifo_in_h, fifo_in_l} ;
		  
	assign start = reg_cmdin_tgl_0 ^ reg_cmdin_tgl_1;  
	 
		 
//////////////////////////////////////////////////////////////////////////////////////  
    initial steed_intrq = 1'b0;  
    
    always @(*)    
           if (fifo2host_oe) 
                           steed_dd_out_pre = steed_fifo_out;
           else if (steed_dd_oe && !fifo_rd_cs)
                           steed_dd_out_pre = reg_dd_out;
           else
                           steed_dd_out_pre = 16'hzzzz;                                
    
    
    always @(*)
          if ((busy == 1'b0)&&(busy_smp == 1'b1))
             steed_intrq = 1'b1; 
          else if (rd_status ^ rd_stus_smp)
                  steed_intrq = 1'b0;
           
               
    always @(posedge clk or negedge rst_n)    
          if (!rst_n)
             rd_stus_smp <= 1'b0;
          else
             rd_stus_smp <= rd_status;
            

	always @(posedge clk or negedge rst_n)
 	  	  if (!rst_n) begin
 	  	                  reg_cmdin_tgl_0 <= 1'b0;
 	  	                  reg_cmdin_tgl_1 <= 1'b0; 
 	  	              end
 	  	  else begin
 	  	           reg_cmdin_tgl_0 <= reg_cmdin_tgl;
	               reg_cmdin_tgl_1 <= reg_cmdin_tgl_0;  
	           end  
	
	                                                                                                     
    
////////// The logic below is the FSM that handles the communication interface with NAND and HOST   
//// The sequential part of the FSM	         
	always @(posedge clk or negedge rst_n)
	  if (!rst_n) begin 
	       cur_st <= NAND_IDLE;
	       
	       io_ale <= 1'b0; 
	       io_cle <= 1'b0;
	       io_xce <= 1'b1;
	       io_xre <= 1'b1;
	       io_xwe <= 1'b1; 
	       
	       host_nand <= 1'b0;
	       wr_cs <= 1'b0;
	       rd_cs <= 1'b0;
	       rd_en <= 1'b0;
	       wr_en <= 1'b0;
	       
	       fifo_in_l <= 8'h00;
	       fifo_in_h <= 8'h00;
	       
	       steed_io_oe  <= 1'b0;
	       steed_io_out <= 8'h00;
	       fifo2host_oe <= 1'b0;
	       
	       busy     <= 1'b0;
	       busy_smp <= 1'b0;
	       drq      <= 1'b0;
	       
	       cntr <= 2'b00;   
	       
	   end
	   else begin
	       cur_st <= nxt_st;
	       
	       io_ale <= io_ale_o    ; 
	       io_cle <= io_cle_o    ;
	       io_xce <= io_xce_o    ;
	       io_xre <= io_xre_o    ;
	       io_xwe <= io_xwe_o    ; 
	       
	       host_nand <= host_nand_o;
	       wr_cs  <= wr_cs_o;
	       rd_cs  <= rd_cs_o;
	       rd_en  <= rd_en_o;
	       wr_en  <= wr_en_o;
	       
	       fifo_in_l <= fifo_in_l_o;
	       fifo_in_h <= fifo_in_h_o;
	       	              
	       steed_io_oe  <= steed_io_oe_o ;
	       steed_io_out <= steed_io_out_o;  
	        fifo2host_oe <=  fifo2host_oe_o;
	       
	       busy     <= busy_o;
	       busy_smp <= busy; 
	       drq      <= drq_o; 
	       
	       cntr = #1 cntr_o;
	   end                                                               
	   
//// The combinational part of the FSM	  	      
	 always @(*) begin  
	   nxt_st = cur_st;
	   
	   io_ale_o  = io_ale     ;
	   io_cle_o  = io_cle     ;
	   io_xce_o  = io_xce     ;
	   io_xre_o  = io_xre     ;
	   io_xwe_o  = io_xwe     ;
	                              
	   host_nand_o = host_nand;
	   wr_cs_o = wr_cs ;
	   rd_cs_o = rd_cs ;
	   rd_en_o = rd_en ;
	   wr_en_o = wr_en ; 
	   
	   fifo_in_l_o = fifo_in_l;
	   fifo_in_h_o = fifo_in_h;
	   
	   steed_io_oe_o  = steed_io_oe ; 
	   steed_io_out_o = steed_io_out;
	    fifo2host_oe_o =  fifo2host_oe;
	   
	   busy_o = busy;
	   drq_o  = drq;
	    
	   cntr_o = cntr;
	   
	   case (cur_st)     
	    NAND_IDLE: begin 
	                   fifo2host_oe_o = 1'b0;
	                   rd_cs_o = 1'b0;       
	                   rd_en_o = 1'b0;
	                   io_xce_o = 1'b1;
	                          
	                   if (start) begin
	                     busy_o = 1'b1;
	                     io_xce_o = 1'b0;
	                     nxt_st = NAND_CMND;
	                   end
	                   else
	                     nxt_st = NAND_IDLE;
	    end//NAND_IDLE
	     
	    NAND_CMND: begin          
	                   io_cle_o = 1'b1;
	                   io_xwe_o = 1'b0;
	                   steed_io_oe_o = 1'b1;
	                                                                           
	                   case (reg_command)
	                    `IDE_READ_SECTORS: begin
	                      steed_io_out_o = 8'haa;         
	                    end
	                    
	                    `IDE_WRITE_SECTORS: begin
	                      steed_io_out_o = 8'h80;
	                    end
	                   endcase //reg_command  
	                   nxt_st = ST_WE1;                   
	    end//NAND_CMND 
	    
	    ST_WE1: begin
	                     io_xwe_o = 1'b1; 
	                     nxt_st = NAND_ADDR;
	                     
	    end//NAND_ST_WE1
	           
	    NAND_ADDR: begin           
	                   io_cle_o = 1'b0;
	                   io_ale_o = 1'b1;
	                   io_xwe_o = 1'b0;              
	                   
	                   case(cntr)
	                     2'b00: steed_io_out_o = reg_sector_count ;//byte_addr[7:0]                  
	                     2'b01: steed_io_out_o = reg_sector_number;//page_addr[7:0]                  
	                     2'b10: steed_io_out_o = reg_cylinder_low ;//page_addr[15:8]
	                     2'b11: steed_io_out_o = reg_cylinder_high;//page_addr[23:16]
	                   endcase//cntr          
	                   nxt_st = ST_WE2;
	    end//NAND_ADDR  
	     
	    ST_WE2: begin 
	                     io_xwe_o = 1'b1; 
	                     
	                     if (cntr_o == 2'b11) begin
	                       		   cntr_o = 2'b00;                          
			                       case (reg_command)                                            
			                          `IDE_READ_SECTORS : 
			                                                nxt_st = WAIT_RXB_LO;
			                                                                          
			                          `IDE_WRITE_SECTORS : 
			                                                nxt_st = WAIT_STEED_DD_IE;  
			                                                                          
			                        endcase// reg_command 
	                      end                                            
	                     else begin
	                       nxt_st = NAND_ADDR;
	                       cntr_o = cntr_o + 1;
	                     end  
	    end//NAND_ST_WE2

///*************************HOST WRITES TO FIFO LOGIC**************************** 
        WAIT_STEED_DD_IE: begin
                              io_ale_o = 1'b0;
                              io_xce_o = 1'b1;
                              host_nand_o = 1'b1; 
                              wr_cs_o     = 1'b1;    
                                                            
                              if (steed_dd_ie) begin                                                
                                               nxt_st = HOST_DATA_IN;
                                               wr_en_o = 1'b1;                                                
                                               end                   
                                   else                                   
                                      nxt_st = WAIT_STEED_DD_IE;                                                                                   
        end    
        
        HOST_DATA_IN: begin 
                          wr_en_o = 1'b0;
                          {fifo_in_h, fifo_in_l} = io_dd_in; 
                          
                          if (fifo_full) begin                    
                                         wr_cs_o = 1'b0;          
                                         wr_en_o = 1'b0; 
                                         rd_cs_o = 1'b1;
                                         rd_en_o = 1'b1;                                                                                         
                                         host_nand_o = 1'b0;      
                                         nxt_st = PREP; 
                                         end                      
                          else                                    
                                                                  
                          nxt_st = WAIT_STEED_DD_IE;
                         
        end//HOST_DATA_IN
                                                                                      
        
////************************** STEED WRITES TO NAND LOGIC **************************    
        PREP: begin
                   rd_en_o = 1'b0;
                   io_xce_o = 1'b0;
                   io_xwe_o = 1'b0;
                   nxt_st = NAND_DATA_IN_1;
        end//FIFO_PREP     
         	    
	    NAND_DATA_IN_1: begin 
	                      rd_en_o = 1'b1;	     	              	     	                           	                      
	                      io_xwe_o = 1'b1; 	                      
	                      steed_io_out_o = steed_fifo_out[7:0];	                                          	                      
	                      nxt_st = ST_WE3;
	                                           
	    end//NAND_DATA_IN 
	    
	    ST_WE3: begin
	                io_xwe_o = 1'b0;
	                rd_en_o  = 1'b0;    	                
	                nxt_st =NAND_DATA_IN_2;
	    end//ST_WE3      
	    
	    NAND_DATA_IN_2: begin  
	                        io_xwe_o = 1'b1;
	                        rd_en_o  = 1'b1; 
	                        steed_io_out_o = steed_fifo_out[`FIFO_DATA_WIDTH-1:8];   //[15:8]                         
	                        nxt_st = ST_WE4;
	    end//NAND_DATA_IN_2 
	    
	    ST_WE4: begin     
	                io_xwe_o = 1'b0;
	                rd_en_o  = 1'b0; 	                
	                if (fifo_empty) 
	                                nxt_st = LAST_1;                                
	                else             
	                                nxt_st = NAND_DATA_IN_1; 
	                                
	    end//ST_WE4
	                                
	    LAST_1: begin
	              io_xwe_o = 1'b1;
	              rd_en_o  = 1'b1; 
	              steed_io_out_o = steed_fifo_out[7:0];
	              nxt_st = ST_WE;
	    end//LAST_1
	    
	    ST_WE: begin 
	               io_xwe_o = 1'b0; 
	               rd_en_o  = 1'b0; 
	               nxt_st  = LAST_2;
	    
	    end//ST_WE        
	    
	    LAST_2: begin 	                          
	              io_xwe_o = 1'b1;
	              rd_en_o  = 1'b1;
	              steed_io_out_o = steed_fifo_out[`FIFO_DATA_WIDTH-1:8]; 
	              nxt_st = NAND_IDLE;
	                 
	                         
	    end//LAST_2                                              
	                                                                                                           

///*************************NAND PRAEPARES THE DATA AND WRITES TO THE FIFO LOGIC****************************	       
	    WAIT_RXB_LO: begin
	                     io_ale_o = 1'b0;
	                     steed_io_oe_o = 1'b0;
	                     if (!io_rxb )begin
	                       io_xre_o = 1'b0;
	                       nxt_st = WAIT_RXB_HI;
	                       end
	                     else
	                       nxt_st = WAIT_RXB_LO;  
	    end//WAIT_RXB_LO    
	    
	    WAIT_RXB_HI: begin 
	                     if (io_rxb) begin                        
	                       io_xre_o = 1'b1; 	                      	                                                 
	                       nxt_st = NAND_DATA_OUT_1;
	                       end
	                     else
	                       nxt_st = WAIT_RXB_HI;
	    end//WAIT_RXB_HI
	    
	 NAND_DATA_OUT_1: begin 
	                      io_xre_o = 1'b0;
	                      wr_cs_o = 1'b1;
	                      wr_en_o = 1'b1; 	  	                      
	                      fifo_in_l_o = io_io_in;            
	                      if (fifo_full)begin                          
	                                        wr_cs_o = 1'b0;            
	                                        wr_en_o = 1'b0;            
	                                        io_xce_o = 1'b1; 
	                                        io_xre_o = 1'b1;          
	                                        drq_o = 1'b1;              
	                                        busy_o = 1'b0;	           
	                                        nxt_st = WAIT_STEED_DD_OE; 
	                                     end                           
	                      else                                         
	                            nxt_st = ST_RE1;
	                      
	 end//DATA_EVEN   
	 
	 ST_RE1: begin 
	             io_xre_o = 1'b1; 	             
	             nxt_st = NAND_DATA_OUT_2;             
	 end//ST_RE1
	 
	 NAND_DATA_OUT_2: begin
	                      io_xre_o = 1'b0;	                      
	                      fifo_in_h_o = io_io_in; //[15:8] 
	                      nxt_st = ST_RE2;                                 
	                       
	 end//DATA_ODD
	 
	 ST_RE2: begin             
	             io_xre_o = 1'b1;
	             nxt_st = NAND_DATA_OUT_1; 
	             	             
	 end//ST_RE2
	  
///*************************HOST READS FROM THE FIFO LOGIC****************************	 
     WAIT_STEED_DD_OE: begin 
                           fifo2host_oe_o = 1'b0;                   
                           rd_en_o = 1'b0;
                           host_nand_o = 1'b1;                          
                           if ( steed_dd_oe && !steed_intrq )
                                 nxt_st = DATA_TO_HOST;
                           else                                
                                 nxt_st = WAIT_STEED_DD_OE;                                            	                                                                                                                    		                	                                                                                                                                   
	 end//WAIT_STEED_DD_OE 
	 
	 	  	   	 
	 DATA_TO_HOST: begin                                                 
		              rd_cs_o = 1'b1;
		              rd_en_o = 1'b1;  
		              fifo2host_oe_o = 1'b1;
		              if (fifo_empty)           
		                    nxt_st = WAIT_OE;   
		              else                        		                  
		              nxt_st = WAIT_STEED_DD_OE;
		                 			              			                           
	 end//DATA_TO_HOST 
	 
	 WAIT_OE: begin 
	              fifo2host_oe_o = 1'b0;
	              rd_en_o = 1'b0;
	              if ( steed_dd_oe && !steed_intrq )
	                    nxt_st = LAST_ONE;      
	              else                              
	                    nxt_st = WAIT_OE;  
	 end// 	
	 
	 LAST_ONE: begin                            	 
	               fifo2host_oe_o = 1'b1; 	  	 
	               rd_en_o = 1'b1;        	  	  	  	 
	               nxt_st = NAND_IDLE;   	 
	 end// 
	 	 	                  
	endcase //cur_st
	end//always @(*) 
	
/////////////  The end of the FSM logic/////////////////////////////////
	
	 // synthesis translate_off
	reg [8*20-1:0] prc_state_ascii;
	always @(cur_st)
	  case(cur_st)
	  
	      NAND_IDLE       : prc_state_ascii = "NAND_IDLE       ";
	      NAND_CMND       : prc_state_ascii = "NAND_CMND       ";
	      NAND_ADDR       : prc_state_ascii = "NAND_ADDR       ";
	      ST_WE2          : prc_state_ascii = "ST_WE2          ";
	      ST_WE1          : prc_state_ascii = "ST_WE1          ";
	      ST_WE3          : prc_state_ascii = "ST_WE3          ";   
	      ST_WE4          : prc_state_ascii = "ST_WE4          ";
	      WAIT_RXB_LO     : prc_state_ascii = "WAIT_RXB_LO     "; 
	      WAIT_RXB_HI     : prc_state_ascii = "WAIT_RXB_HI     ";
	      NAND_DATA_OUT_1 : prc_state_ascii = "NAND_DATA_OUT_1 ";                   
	      NAND_DATA_OUT_2 : prc_state_ascii = "NAND_DATA_OUT_2 ";  
	      NAND_DATA_IN_1  : prc_state_ascii = "NAND_DATA_IN_1  "; 
	      NAND_DATA_IN_2  : prc_state_ascii = "NAND_DATA_IN_2  ";
	      ST_RE1          : prc_state_ascii = "ST_RE1          ";
	      ST_RE2          : prc_state_ascii = "ST_RE2          "; 
	      WAIT_STEED_DD_OE: prc_state_ascii = "WAIT_STEED_DD_OE";
	      DATA_TO_HOST    : prc_state_ascii = "DATA_TO_HOST    ";
	      LAST_ONE        : prc_state_ascii = "LAST_ONE        ";
	      WAIT_OE         : prc_state_ascii = "WAIT_OE         "; 
	      HOST_DATA_IN    : prc_state_ascii = "HOST_DATA_IN    "; 
	      WAIT_STEED_DD_IE: prc_state_ascii = "WAIT_STEED_DD_IE";
	      PREP            : prc_state_ascii = "PREP";
	      ST_WE           : prc_state_ascii = "ST_WE";
	      LAST_1          : prc_state_ascii = "LAST_1";
	      LAST_2          : prc_state_ascii = "LAST_2";            
	      
	      default      : prc_state_ascii = "XXXXX";
	endcase // cur_st
	// synthesis translate_on  
	
	endmodule
	