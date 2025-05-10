`include "rtl/soc/axi4_lite/axi4_lite_slave.v"
`include "rtl/soc/rom/memory_rom.v"

module rom_axi_wrapper (
    input               iCLK, iRST,

    /* interfaces */
    input       [31:0]  iREAD_DATA,
    output              iCE,
    output              iRD,
    output      [31:0]  oADDR,

    /* write address channel */
    input               s_AWVALID,

    /* read address channel */
    input               s_ARVALID,
    input       [2:0]   s_ARPROT,
    input       [31:0]  s_ARADDR,
    output              s_ARREADY,

    /* read data channel */
    input               s_RREADY,
    output              s_RVALID,
    output      [31:0]  s_RDATA,
    output      [1:0]   s_RRESP
);

    wire                CE, RD;
    wire        [31:0]  DATA, ADDR;

    assign      CE          = 1'b1;
    assign      RD          = 1'b1;
    assign      s_AWVALID   = 1'b0;

    memory_rom rom(
        .iROM_CE(CE), .iROM_RD(RD),
        .iROM_ADDR(ADDR), .oROM_DATA(DATA)	
    );

    axi4_lite_slave slave (
        .iCLK(iCLK), .iRST(iRST),

        /* interfaces */
        .iREAD_DATA(DATA),
        .iCE(CE), .iRD(RD), .oADDR(ADDR),
        
        /* write address channel -> made false write */ 
        .s_AWVALID(s_AWVALID),

        /* read */
        .s_ARVALID(s_ARVALID), .s_ARPROT(s_ARPROT), .s_ARADDR(s_ARADDR), .s_ARREADY(s_ARREADY),
        .s_RREADY(s_RREADY), .s_RVALID(s_RVALID), .s_RDATA(s_RDATA), .s_RRESP(s_RRESP)
    );

endmodule