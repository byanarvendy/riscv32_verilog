// `include "rtl/soc/axi4_lite/axi4_lite_slave.v"
`include "rtl/soc/ram/memory_ram.v"

module ram_axi_wrapper (
    input               iCLK, iRST,

    /* interfaces */
    input       [31:0]  iREAD_DATA,
    output              iCE,
    output              iRD,
    output      [31:0]  oADDR,

    /* write address channel */
    input               s_AWVALID,
    input       [2:0]   s_AWPROT,
    input       [31:0]  s_AWADDR,
    output              s_AWREADY,

    /* write data channel */
    input               s_WVALID,
    input       [3:0]   s_WSTRB,
    input       [31:0]  s_WDATA,
    output              s_WREADY,

    /* write response channel */
    input               s_BREADY,
    output              s_BVALID,
    output      [1:0]   s_BRESP,

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
    wire        [31:0]  ADDR, READ, WRITE;

    assign      CE          = 1'b1;
    assign      RD          = 1'b1;

    memory_ram ram(
        .iCLK(iCLK),
        .iRAM_CE(CE), .iRAM_RD(RD), .iRAM_WR(WR),
        .iRAM_ADDR(ADDR), .iRAM_DATA(WRITE),
        .oRAM_DATA(READ)
    );

    axi4_lite_slave slave (
        .iCLK(iCLK), .iRST(iRST),

        /* interfaces */
        .iREAD_DATA(READ),
        .iCE(CE), .iRD(RD), .iWR(WR),
        .oADDR(ADDR), .oWRITE_DATA(WRITE),

        /* write */
        .s_AWVALID(s_AWVALID), .s_AWPROT(s_AWPROT), .s_AWADDR(s_AWADDR), .s_AWREADY(s_AWREADY),
        .s_WVALID(s_WVALID), .s_WSTRB(s_WSTRB), .s_WDATA(s_WDATA), .s_WREADY(s_WREADY),
        .s_BREADY(s_BREADY), .s_BVALID(s_BVALID), .s_BRESP(s_BRESP),

        /* read */
        .s_ARVALID(s_ARVALID), .s_ARPROT(s_ARPROT), .s_ARADDR(s_ARADDR), .s_ARREADY(s_ARREADY),
        .s_RREADY(s_RREADY), .s_RVALID(s_RVALID), .s_RDATA(s_RDATA), .s_RRESP(s_RRESP)
    );

endmodule