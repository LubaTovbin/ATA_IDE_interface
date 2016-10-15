module steed_tb ();
`include "steed.vh"
/*   IDE interface: */
reg            RST_N;
wire    [15:0] DD;
wire           DIOR;
wire           DIOW;
wire           IOCHRDY;
wire     [1:0] CS;
wire     [2:0] DA;
wire           INTRQ;
wire           DMARQ;
wire           DMACL;
wire           CSEL;

/*   NAND interface: (assume 1 lane for now) */
wire [`IO_MSB:0] IO;
wire           RXB;
wire           ALE;
wire           CLE;
wire           xCE;
wire           xRE;
wire           xWE;

initial begin
  RST_N = 1'b0;
  #200;
  RST_N = 1'b1;
end

   steed_top dut (
      .RST_N(RST_N),
      .DD(DD),
      .DIOR(DIOR),
      .DIOW(DIOW),
      .IOCHRDY(IOCHRDY),
      .CS(CS),
      .DA(DA),
      .INTRQ(INTRQ),
      .DMARQ(DMARQ),
      .DMACL(DMACL),
      .CSEL(CSEL),
      
      .IO(IO),
      .RXB(RXB),
      .ALE(ALE),
      .CLE(CLE),
      .xCE(xCE),
      .xRE(xRE),
      .xWE(xWE));

   ide_host ide_host0 (
      .DD(DD),
      .DIOR(DIOR),
      .DIOW(DIOW),
      .IOCHRDY(IOCHRDY),
      .CS(CS),
      .DA(DA),
      .INTRQ(INTRQ),
      .DMARQ(DMARQ),
      .DMACL(DMACL),
      .CSEL(CSEL)
   );
 
   nand_lane nand_lane0 (
      .IO(IO),
      .RXB(RXB),
      .ALE(ALE),
      .CLE(CLE),
      .xCE(xCE),
      .xRE(xRE),
      .xWE(xWE));

endmodule
