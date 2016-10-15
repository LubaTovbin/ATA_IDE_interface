 //by Luba Tovbin
	//July, 2013          
module fifo (
	clk, 
	rst_n,
	host_nand, // "1" when host writes to fifo or host reads from fifo; "0" when nand writes to fifo or reads from fifo;
	wr_cs,
	rd_cs,
	data_in,
	rd_en,
	wr_en,
	data_out,
	empty,
	full
);    

`include "steed.vh"
 
input                        clk       ;
input                        rst_n     ; 
input                        host_nand ; 
input                        wr_cs     ;
input                        rd_cs     ;
input                        rd_en     ;
input                        wr_en     ;
input [`FIFO_DATA_WIDTH-1:0] data_in   ;

output                       full      ;
output                       empty     ;
output[`FIFO_DATA_WIDTH-1:0] data_out  ;

reg [`FIFO_ADDR_WIDTH-1:0] wr_pointer;
reg [`FIFO_ADDR_WIDTH-1:0] rd_pointer;
reg [`FIFO_ADDR_WIDTH-1:0] status_cnt;
reg [`FIFO_DATA_WIDTH-1:0] data_out  ; 

reg full_by_nand, full_o;     
reg [1:0] nx_st, cr_st;
reg [1:0] cntr; 

wire[`FIFO_DATA_WIDTH-1:0] data_ram;

assign empty = (status_cnt == 0); 
assign full = (host_nand) ? (status_cnt == `FIFO_DEPTH - 1) : full_by_nand;         

//fifo flags FSM
always @(posedge clk or negedge rst_n)
  if (!rst_n) begin   
                  full_by_nand  <= 1'b0;
                  cr_st <= 0;
              end
  else begin
           full_by_nand  <= full_o; 
           cr_st <= nx_st;      
       end
       
always @(*) begin
                full_o = full_by_nand;
                nx_st = cr_st;
                
                case (cr_st)
                0: begin 
                          if (status_cnt == `FIFO_DEPTH - 1)
                                    nx_st = 1;
                          else             
                                    nx_st = 0;
                end
                
                1: begin
                          if (cntr == 2'b10) begin
                                                 nx_st = 2; 
                                                 full_o =1'b1;
                                             end    
                          else
                                    nx_st = 1;           
                end
                 
                2: begin
                          if (status_cnt == `FIFO_DEPTH - 1)
                                    nx_st = 2;
                          else begin
                                    nx_st = 0;
                                    full_o = 1'b0;
                               end               
                end
                endcase
             end//(*)   
                              
always @(posedge clk or negedge rst_n)
  if (!rst_n) begin
    wr_pointer <= 0;
    rd_pointer <= 0;
    data_out   <= 0;
    status_cnt <= 0;
    cntr       <= 0;
    end
  else begin  
            if (rd_cs && rd_en)  data_out <= data_ram;
            
            if (wr_cs && wr_en || rd_cs && rd_en)  cntr <= cntr + 1;       
                       
            if (wr_cs && wr_en && (((cntr == 2'b11) && !host_nand) || host_nand) )      //write to fifo
                       wr_pointer <= wr_pointer + 1;  
                       
            if (rd_cs && rd_en && (((cntr[0] == 1'b1) && !host_nand) || host_nand)  )  //read from fifo
                                     rd_pointer <= rd_pointer + 1;
                                    // data_out <= data_ram;
                            
            else if (!rd_cs)  
                           rd_pointer <= `FIFO_ADDR_WIDTH'd0;                                    
                                 
            if ((rd_cs && rd_en) && !(wr_cs && wr_en) && (status_cnt != 0) && ((cntr[0] == 1'b1) || host_nand))
                     status_cnt <= status_cnt - 1;
            else
                 if ((wr_cs && wr_en) && !(rd_cs && rd_en) && (status_cnt != `FIFO_DEPTH - 1) && ((cntr == 2'b11) || host_nand))   
                                      //it takes 4 clock cycles to load data from nand
                          status_cnt <= status_cnt + 1;                        
  end
  
dp_ram ram (
.address_0 (wr_pointer) , // address_0 input 
.data_0    (data_in)    , // data_0 bi-directional
.cs_0      (wr_cs)      , // chip select
.we_0      (wr_en)      , // write enable
.oe_0      (1'b0)       , // output enable
.address_1 (rd_pointer) , // address_q input
.data_1    (data_ram)   , // data_1 bi-directional
.cs_1      (rd_cs)      , // chip select
.we_1      (1'b0)       , // Read enable
.oe_1      (rd_en)        // output enable
);     

endmodule
