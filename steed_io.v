/* IO block model */
module steed_io (
      DD,
      DIOR,
      DIOW,
      IOCHRDY,
      CS,
      DA,
      INTRQ,
      DMARQ,
      DMACL,
      CSEL,
      
      IO,
      RXB,
      ALE,
      CLE,
      xCE,
      xRE,
      xWE,

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
      io_xwe
    );  
`include "steed.vh"    
/*   IDE interface: */
inout   [15:0] DD;
input          DIOR;
input          DIOW;
output         IOCHRDY;
input    [1:0] CS;
input    [2:0] DA;
output         INTRQ;
output         DMARQ;
input          DMACL;
input          CSEL;

/*   NAND interface: (assume 1 lane for now) */
inout [`IO_MSB:0] IO;
input           RXB;
output          ALE;
output          CLE;
output          xCE;
output          xRE;
output          xWE;
              
input    [15:0] steed_dd_out;
input           steed_dd_oe;
output   [15:0] io_dd_in;
output          io_dior;
output          io_diow;
output    [1:0] io_cs;
output    [2:0] io_da;
input           steed_intrq;
input           steed_dmarq;
output          io_dmacl;
output          io_csel;

output  [`IO_MSB:0] io_io_in;
input   [`IO_MSB:0] steed_io_out;
input               steed_io_oe;
output              io_rxb;
input              io_ale;
input              io_cle;
input              io_xce;
input              io_xre;
input              io_xwe;

wire [15:0] DD_drv = (steed_dd_oe) ? steed_dd_out : 16'hzzzz;
assign   DD = DD_drv;             //#2   #2
assign   io_dd_in = DD;           //#2   #2
assign   io_dior = DIOR;          //#2   #2
assign   io_diow = DIOW;          //#2   #2
assign   io_cs = CS;              //#2   #2
assign   io_da = DA;              //#2   #2
assign   INTRQ = steed_intrq;     //#2   #2
assign   DMARQ = steed_dmarq;     //#2   #2
assign   io_dmacl = DMACL;        //#2
assign   io_csel  = CSEL;         //#2

wire [`IO_MSB:0] IO_drv = (steed_io_oe) ? steed_io_out : 8'hzz;
assign   IO = IO_drv;
assign   io_io_in = IO;
assign   io_rxb = RXB;
assign   ALE = io_ale;
assign   CLE = io_cle;
assign   xCE = io_xce;
assign   xRE = io_xre;
assign   xWE = io_xwe;

endmodule