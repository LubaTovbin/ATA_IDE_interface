   
   //modified by Luba Tovbin
   //July, 2013
/* a wrapper around the IO and control blocks */
module steed_top(
      RST_N,
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
      xWE);
`include "steed.vh"
/*   IDE interface: */
input          RST_N; 
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

/* internal connects */
wire    [15:0] steed_dd_out;
wire           steed_dd_oe;
wire    [15:0] io_dd_in;
wire           io_dior;
wire           io_diow;
wire     [1:0] io_cs;
wire     [2:0] io_da;
wire           steed_intrq;
wire           steed_dmarq;
wire           io_dmacl;
wire           io_csel;

wire [`IO_MSB:0] io_io_in;
wire [`IO_MSB:0] steed_io_out;
wire             steed_io_oe;
wire             io_rxb;
wire             io_ale;
wire             io_cle;
wire             io_xce;
wire             io_xre;
wire             io_xwe;

wire             clk;

wire     fifo_host_nand;
wire     fifo_wr_cs;
wire     fifo_rd_cs;
wire     fifo_rd_en;
wire     [`FIFO_DATA_WIDTH-1:0] steed_fifo_in;
wire     fifo_wr_en;
wire     fifo_full;
wire     fifo_empty;
wire     [`FIFO_DATA_WIDTH-1:0] steed_fifo_out;
    
assign INTRQ = steed_intrq; 
              
/* sub-blocks */
      ocs_clk  ocs_clk0 (
        .clk_en(1'b1),
        .o_clk(clk)
        );
         
      fifo fifo0 (
        .clk      (clk), 
        .rst_n    (RST_N),
        .host_nand(fifo_host_nand), 
        .wr_cs    (fifo_wr_cs),     
        .rd_cs    (fifo_rd_cs),     
        .data_in  (steed_fifo_in),   
        .rd_en    (fifo_rd_en),     
        .wr_en    (fifo_wr_en),     
        .data_out (steed_fifo_out),  
        .empty    (fifo_empty),    
        .full     (fifo_full)       
        );   
             
   steed_io steed_io0 (
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
               .xWE(xWE),

               .steed_dd_out(steed_dd_out),
               .steed_dd_oe (steed_dd_oe),
               .io_dd_in    (io_dd_in),
               .io_dior     (io_dior),
               .io_diow     (io_diow),
               .io_cs       (io_cs),
               .io_da       (io_da),
               .steed_intrq (steed_intrq),
               .steed_dmarq (steed_dmarq),
               .io_dmacl    (io_dmacl),
               .io_csel     (io_csel),

               .io_io_in (io_io_in),
               .steed_io_out (steed_io_out),
               .steed_io_oe (steed_io_oe),
               .io_rxb (io_rxb),
               .io_ale (io_ale),
               .io_cle (io_cle),
               .io_xce (io_xce),
               .io_xre (io_xre),
               .io_xwe (io_xwe)

    );

    steed steed0(
               .rst_n(RST_N),
               .clk(clk),
               .steed_dd_out(steed_dd_out),
               .steed_dd_oe (steed_dd_oe),
               
               .io_dd_in (io_dd_in),
               .io_dior (io_dior),
               .io_diow (io_diow),
               .io_cs (io_cs),
               .io_da (io_da),
               .steed_intrq (steed_intrq),
               .steed_dmarq (steed_dmarq),
               .io_dmacl (io_dmacl),
               .io_csel  (io_csel),

               .io_io_in     (io_io_in),
               .steed_io_out (steed_io_out),
               .steed_io_oe  (steed_io_oe),
               
               .io_rxb (io_rxb),
               .io_ale (io_ale),
               .io_cle (io_cle),
               .io_xce (io_xce),
               .io_xre (io_xre),
               .io_xwe (io_xwe),
                
               .fifo_host_nand(fifo_host_nand),
               .fifo_wr_cs   (fifo_wr_cs),     
               .fifo_rd_cs   (fifo_rd_cs),     
               .steed_fifo_in (steed_fifo_in),
               .steed_fifo_out(steed_fifo_out),   
               .fifo_rd_en   (fifo_rd_en),     
               .fifo_wr_en   (fifo_wr_en), 
               .fifo_full    (fifo_full),
               .fifo_empty   (fifo_empty)
               
     );

endmodule
