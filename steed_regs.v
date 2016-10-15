/* the registers block */
module steed_regs (
               io_dd_in,
               io_dior,
               io_diow,
               io_cs,
               io_da,
               rst_n,
               reg_status,
               reg_data,
               reg_features,
               reg_sector_count,
               reg_sector_number,
               reg_cylinder_low,
               reg_cylinder_high,
               reg_head,
               reg_dev_control,
               reg_command,
               reg_dd_out,
               reg_lba,
               reg_cmdin_tgl,
               rd_status
);
`include "steed.vh"               
input   [15:0] io_dd_in;
input          io_dior;
input          io_diow;
input    [1:0] io_cs;
input    [2:0] io_da;
input          rst_n;
input  [7:0]   reg_status;

output [15:0]  reg_data;
output [7:0]   reg_features;
output [7:0]   reg_sector_count;
output [7:0]   reg_sector_number;
output [7:0]   reg_cylinder_low;
output [7:0]   reg_cylinder_high;
output [7:0]   reg_head;
output [7:0]   reg_dev_control;
output [7:0]   reg_command;
output [15:0]  reg_dd_out;
output [27:0]  reg_lba;
output         reg_cmdin_tgl; 
output         rd_status;

reg            steed_intrq;
reg [15:0]     reg_data;
reg [7:0]      reg_features;
reg [7:0]      reg_sector_count;
reg [7:0]      reg_sector_number;
reg [7:0]      reg_cylinder_low;
reg [7:0]      reg_cylinder_high;
reg [7:0]      reg_head;
reg [7:0]      reg_dev_control;
reg [7:0]      reg_command;
reg            reg_cmdin_tgl;
reg [15:0]     reg_dd_out; 
reg            rd_status;


//when host writes to the drive:
    always @(posedge io_diow or negedge rst_n)
      if (!rst_n) begin
        reg_data          <= #1 16'h0000;
        reg_sector_count  <= #1 8'h00;
        reg_sector_number <= #1 8'h00;
        reg_cylinder_low  <= #1 8'h00;
        reg_cylinder_high <= #1 8'h00;
        reg_head          <= #1 8'h00;
        reg_dev_control   <= #1 8'h00;
        reg_cmdin_tgl     <= #1 1'b0;
      end
    else begin
        if (io_cs[0])
          case (io_da)
            `IDE_DATA     : reg_data          <= #1  io_dd_in;
            `IDE_FEATURES : reg_features      <= #1  io_dd_in[7:0];
            `IDE_SEC_CNT  : reg_sector_count  <= #1  io_dd_in[7:0];
            `IDE_SEC_NUM  : reg_sector_number <= #1  io_dd_in[7:0];
            `IDE_CYL_LO   : reg_cylinder_low  <= #1  io_dd_in[7:0];
            `IDE_CYL_HI   : reg_cylinder_high <= #1  io_dd_in[7:0];
            `IDE_HEAD     : reg_head          <= #1  io_dd_in[7:0];
            `IDE_COMMAND  : begin
                              reg_command   <= #1  io_dd_in[7:0];
                              reg_cmdin_tgl <= #1 ~reg_cmdin_tgl;
                            end
          endcase
        else if (io_cs[1] && (io_da == 3'b110))
          reg_dev_control <= #1 io_dd_in[7:0];
      end
      

//when host reads from the drive:
  always @(negedge io_dior or negedge rst_n)
    if (!rst_n) begin  
      reg_dd_out <= 16'h0000;
      rd_status  <= 1'b0;
    end 
    else
     if (reg_status[3])                    
	    case ({io_cs, io_da})
	      {`CS0, `IDE_DATA}     : reg_dd_out <= reg_data;
	      {`CS0, `IDE_FEATURES} : reg_dd_out <= {8'b0, reg_features};
	      {`CS0, `IDE_SEC_CNT}  : reg_dd_out <= {8'b0, reg_sector_count};
	      {`CS0, `IDE_SEC_NUM}  : reg_dd_out <= {8'b0, reg_sector_number};
	      {`CS0, `IDE_CYL_LO}   : reg_dd_out <= {8'b0, reg_cylinder_low};
	      {`CS0, `IDE_CYL_HI}   : reg_dd_out <= {8'b0, reg_cylinder_high};
	      {`CS0, `IDE_HEAD}     : reg_dd_out <= {8'b0, reg_head};
	      {`CS0, `IDE_STATUS}   : if (!reg_status[7]) begin 
                                               	          rd_status <= ~rd_status; 
	                                                      reg_dd_out <= {8'b0, reg_status};
	                                                  end 
    endcase

wire lba_mode = reg_head[6];

/* LBA is in units of sectors (512B/sector) */
/* IDE has a limit of 128GB */
wire  [27:0]       reg_lba = lba_mode ? {reg_head[3:0], reg_cylinder_high,reg_cylinder_low, reg_sector_number} :
                                        {reg_cylinder_high, reg_cylinder_low, reg_head[3:0], reg_sector_number} ;

endmodule

//  always @(io_cs            or io_da             or 
//           reg_data         or reg_features      or 
//           reg_sector_count or reg_sector_number or 
//           reg_cylinder_low or reg_cylinder_high or 
//           reg_head         or reg_status
//           )  