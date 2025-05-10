`timescale 1ps/1ps

`include "rtl/axi4_lite_master.v"
`include "rtl/axi4_lite_slave.v"

module axi4_lite_master_slave_tb;
    reg                 iCLK, iRST;

    reg                 iWRITE_START, iREAD_START;
    reg     [3:0]       iWRITE_STRB;
    reg     [31:0]      iWRITE_ADDR, iWRITE_DATA, iREAD_ADDR;
    wire    [31:0]      oREAD_DATA;

    wire                AWREADY, AWVALID;
    wire    [2:0]       AWPROT;
    wire    [31:0]      AWADDR;
    
    wire                WREADY, WVALID;
    wire    [3:0]       WSTRB;
    wire    [31:0]      WDATA;
    
    wire                BVALID, BREADY;
    wire    [1:0]       BRESP;
    
    wire                ARREADY, ARVALID;
    wire    [2:0]       ARPROT;
    wire    [31:0]      ARADDR;
    
    wire                RVALID, RREADY;
    wire    [1:0]       RRESP;
    wire    [31:0]      RDATA;

    axi4_lite_master master (
        .iCLK(iCLK), .iRST(iRST),
        
        /* interfaces */
        .iWRITE_START(iWRITE_START), .iWRITE_STRB(iWRITE_STRB), .iWRITE_ADDR(iWRITE_ADDR), .iWRITE_DATA(iWRITE_DATA),
        .iREAD_START(iREAD_START), .iREAD_ADDR(iREAD_ADDR),

        /* write */
        .m_AWREADY(AWREADY), .m_AWVALID(AWVALID), .m_AWPROT(AWPROT), .m_AWADDR(AWADDR),
        .m_WREADY(WREADY), .m_WVALID(WVALID), .m_WSTRB(WSTRB), .m_WDATA(WDATA),
        .m_BVALID(BVALID), .m_BRESP(BRESP), .m_BREADY(BREADY),

        /* read */
        .m_ARREADY(ARREADY), .m_ARVALID(ARVALID), .m_ARPROT(ARPROT), .m_ARADDR(ARADDR),
        .m_RVALID(RVALID), .m_RREADY(RREADY), .m_RRESP(RRESP), .m_RDATA(RDATA)
    );
    
    axi4_lite_slave slave (
        .iCLK(iCLK), .iRST(iRST),

        /* write */
        .s_AWVALID(AWVALID), .s_AWPROT(AWPROT), .s_AWADDR(AWADDR), .s_AWREADY(AWREADY),
        .s_WVALID(WVALID), .s_WSTRB(WSTRB), .s_WDATA(WDATA), .s_WREADY(WREADY),
        .s_BREADY(BREADY), .s_BVALID(BVALID), .s_BRESP(BRESP),

        /* read */
        .s_ARVALID(ARVALID), .s_ARPROT(ARPROT), .s_ARADDR(ARADDR), .s_ARREADY(ARREADY),
        .s_RREADY(RREADY), .s_RVALID(RVALID), .s_RDATA(RDATA), .s_RRESP(RRESP)
    );
    
    assign oREAD_DATA = RDATA;
    
    initial begin
        iCLK = 1;
        forever #5 iCLK = ~iCLK;
    end

    initial begin
        $dumpfile("sim/axi4_lite_master_slave_tb.vcd");
        // $dumpvars(0, axi4_lite_master_slave_tb);
        $dumpvars(1, iCLK, iRST);
        $dumpvars(1, master.m_AWVALID, master.m_AWREADY, master.m_AWADDR, master.m_WVALID, master.m_WREADY, master.m_WDATA, master.m_WSTRB, master.m_BVALID, master.m_BREADY, master.m_BRESP);
        $dumpvars(1, slave.s_AWVALID, slave.s_AWREADY, slave.s_AWADDR, slave.s_WVALID, slave.s_WREADY, slave.s_WDATA, slave.s_WSTRB, slave.s_BVALID, slave.s_BREADY, slave.s_BRESP);
        $dumpvars(1, iREAD_START, iREAD_ADDR, master.m_ARVALID, master.m_ARREADY, master.m_ARADDR, master.m_RVALID, master.m_RREADY, master.m_RDATA, master.m_RRESP);
        $dumpvars(1, slave.s_ARVALID, slave.s_ARREADY, slave.s_ARADDR, slave.s_RVALID, slave.s_RREADY, slave.s_RDATA);
        
        
        iRST          = 1'b0;
        iWRITE_START  = 1'b0;
        iREAD_START   = 1'b0;
        iWRITE_ADDR   = 32'h0;
        iWRITE_DATA   = 32'h0;
        iWRITE_STRB   = 4'b0;
        iREAD_ADDR    = 32'h0;

        #10; iRST = 1'b1;

            iWRITE_START    = 1'b1;
            iWRITE_ADDR     = 32;
            iWRITE_DATA     = 8080;
            iWRITE_STRB     = 4'b1111;

        #20;
            iWRITE_START    = 1'b0;
            iWRITE_ADDR     = 32'h0;
            iWRITE_DATA     = 32'h0;
        #20;
            iWRITE_START    = 1'b1;
            iWRITE_ADDR     = 15;
            iWRITE_DATA     = 106;
            iWRITE_STRB     = 4'b1111;

        #20;
            iWRITE_START    = 1'b0;
            iWRITE_ADDR     = 32'h0;
            iWRITE_DATA     = 32'h0;
        
        #10;
            iREAD_START     = 1'b1;
            iREAD_ADDR      = 32;

        #20;
            iREAD_START     = 1'b0;
            iREAD_ADDR      = 32'h0;

        #20;
            iREAD_START     = 1'b1;
            iREAD_ADDR      = 32'h00000010;

        #20;
            iREAD_START     = 1'b0;
            iREAD_ADDR      = 32'h0;

        #400;
        $finish;
    end
endmodule