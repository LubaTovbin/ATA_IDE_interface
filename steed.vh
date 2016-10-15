//modified by Luba Tovbin
//July, 2013

`define       tPROG  2000
`define       tR  1000
`define      HALF_CYCLE  25
`define      FIFO_DATA_WIDTH 16
`define      FIFO_ADDR_WIDTH  8
`define      FIFO_DEPTH   256

`define      IO_MSB 7    

`define      CS0 2'b01
`define      CS1 2'b10

`define      IDE_DATA 3'h0
`define      IDE_FEATURES 3'h1
`define      IDE_ERROR 3'h1
`define      IDE_SEC_CNT 3'h2
`define      IDE_SEC_NUM 3'h3
`define      IDE_CYL_LO 3'h4
`define      IDE_CYL_HI 3'h5
`define      IDE_HEAD 3'h6
`define      IDE_DRIVE 3'h6
`define      IDE_COMMAND 3'h7
`define      IDE_STATUS 3'h7

/* IDE mandatory: */
`define      IDE_CHK_PM_CMD      8'hE5  // check power mode
`define      IDE_EXEC_DEV_DIAG   8'h90  // excute device diagnostic
`define      IDE_IDENTIFY_DEV    8'hEC  // identify device
`define      IDE_IDLE            8'hE3
`define      IDE_IDLE_IMMEDIATE  8'hE1
`define      IDE_INIT_DEV_PARAM  8'h91
`define      IDE_SEEK            8'h70
`define      IDE_READ_DMA        8'hC8  // retries allowed
`define      IDE_READ_DMA1       8'hC9  // no retries
`define      IDE_READ_MULTIPLE    8'hC4
`define      IDE_READ_SECTORS    8'h20  // retries allowed
`define      IDE_READ_SECTORS1   8'h21  // no retries
`define      IDE_READ_VER_SECS   8'h40
`define      IDE_READ_VER_SECS1  8'h41
`define      IDE_SET_FEATURES    8'hEF
`define      IDE_SET_MULTI_MODE  8'hC6
`define      IDE_SLEEP           8'hE6
`define      IDE_STANDBY         8'hE2
`define      IDE_STDBY_IMMED     8'hE0
`define      IDE_WRITE_DMAS      8'hCA  // retries allowed
`define      IDE_WRITE_DMAS1     8'hCB  // no retries
`define      IDE_WRITE_MULTIPLE  8'hC5
`define      IDE_WRITE_SECTORS   8'h30  // retries allowed
`define      IDE_WRITE_SECTORS1  8'h31  // no retries

/* IDE optional: */
`define      IDE_ERASE_SECS      8'hC0
`define      IDE_REQ_EX_ERR      8'h03  // CFA request extended error
`define      IDE_WRM_WO_ERASE    8'hCD  // CFA write multiple without erase
`define      IDE_WRS_WO_ERASE    8'h38  // CFA write sector without erase
`define      IDE_DEV_RESET       8'h08
`define      IDE_READ_BUF        8'hE4
`define      IDE_WRITE_BUF       8'hE8

`define      NAND_CMD_READ1      8'h00
`define      NAND_CMD_READ2      8'h01
`define      NAND_CMD_READ3      8'h50
`define      NAND_CMD_RESET      8'hFF
`define      NAND_CMD_DATAIN     8'h80
`define      NAND_CMD_PROG       8'h10
`define      NAND_CMD_READSTAT   8'h70
`define      NAND_CMD_READID     8'h90

`define      TB steed_tb
`define      HOST steed_tb.ide_host0
`define      LANE0 tb.nand_lane0
