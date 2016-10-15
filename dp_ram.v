  //by Luba Tovbin
	//July, 2013
 module dp_ram (
	address_0 , 
	data_0    ,    
	cs_0      , 
	we_0      , 
	oe_0      , 
	address_1 , 
	data_1    ,    
	cs_1      , 
	we_1      , 
	oe_1        
	); 
 
`include "steed.vh"

 input [`FIFO_ADDR_WIDTH-1:0] address_0 ;
 input cs_0 ;
 input we_0 ;
 input oe_0 ; 
 input [`FIFO_ADDR_WIDTH-1:0] address_1 ;
 input cs_1 ;
 input we_1 ;
 input oe_1 ; 

 inout [`FIFO_DATA_WIDTH-1:0] data_0; 
 inout [`FIFO_DATA_WIDTH-1:0] data_1;
 
 reg [`FIFO_DATA_WIDTH-1:0] data_0_out ; 
 reg [`FIFO_DATA_WIDTH-1:0] data_1_out ;
 reg [`FIFO_DATA_WIDTH-1:0] mem [0:`FIFO_DEPTH - 1];

assign data_0 = (cs_0 && oe_0 && !we_0) ? data_0_out : `FIFO_DATA_WIDTH'dz;
assign data_1 = (cs_1 && oe_1 && !we_1) ? data_1_out : `FIFO_DATA_WIDTH'dz;

///write to memory
 always @ (address_0 or cs_0 or we_0 or data_0 or address_1 or cs_1 or we_1 or data_1)
   if ( cs_0 && we_0 ) 
      mem[address_0] <= data_0;
   else 
    if  (cs_1 && we_1)
      mem[address_1] <= data_1;

//read from memory 
 always @ (address_0 or cs_0 or we_0 or oe_0)
   if (cs_0 &&  ! we_0 && oe_0)
     data_0_out <= mem[address_0]; 
   else 
     data_0_out <= 0; 
 
 always @ (address_1 or cs_1 or we_1 or oe_1)
   if (cs_1 &&  ! we_1 && oe_1) 
     data_1_out <= mem[address_1]; 
   else 
     data_1_out <= 0; 
 
endmodule
