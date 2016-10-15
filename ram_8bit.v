 	//modified by Luba Tovbin
	//July, 2013   
	
module ram_8bit (
			address, 
			data   , 
			cs     , 
			we     , 
			re       
			);          

input [32:0] address;
input        cs     ;
input        we     ;
input        re     ; 
inout [7:0]  data   ;

reg [7:0]   mem [0:393215];
//reg [7:0]   data_out;

assign data = (cs && re && !we) ? mem[address] : 8'hzz;

initial  $readmemb("memory0.list",mem);

always @(address or data or cs or we )
    if (cs && we) 
                 mem[address] = data; 
                 
                 
//always @ (address or cs or we or re)
//    if (cs && !we && re)  
//             data_out = mem[address];


endmodule 
