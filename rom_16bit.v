
 //by Luba Tovbin
 //July, 2013
 
module rom_16bit (
		ce      , 
		read_en , 
		address ,
	    data          
); 

input        ce;
input        read_en;
input  [7:0] address;
output [15:0] data;   
  
reg [15:0]    mem [0:255] ; 

assign data = (ce && read_en) ? mem[address] : 16'h0000;

initial begin
  $readmemb("memory1.list",mem);
end

endmodule



