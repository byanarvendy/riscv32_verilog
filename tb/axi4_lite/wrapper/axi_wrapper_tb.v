`timescale 1ps/1ps

`include "rtl/soc/axi4_lite/wrapper/cpu_axi_wrapper.v"
`include "rtl/soc/axi4_lite/wrapper/ram_axi_wrapper.v"

module axi_wrapper_tb;
    reg                 iRST, iCLK;

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
    
    wire                ARREADY;
    wire                ARVALID;
    wire    [2:0]       ARPROT;
    wire    [31:0]      ARADDR;
    
    wire                RVALID;
    wire                RREADY;
    wire    [1:0]       RRESP;
    wire    [31:0]      RDATA;

    integer i;

    initial begin
        $dumpfile("sim/axi_wrapper_tb.vcd");
    	$dumpvars(0, axi_wrapper_tb);
        
        iRST                = 1'b0;
        iCLK                = 1'b0;
        
        #5; iRST           = 1'b1;

		for (i = 0; i < 50; i = i +1 ) begin
            #5 iCLK = 1;
            #5 iCLK = 0;
		end

            $finish;
    end

    cpu_axi_wrapper cpu (
        .iCLK(iCLK), .iRST(iRST),

        /* interfaces */
        .iREAD_START(iREAD_START), .iREAD_ADDR(iREAD_ADDR),
        .iWRITE_START(iWRITE_START), .iWRITE_STRB(iWRITE_STRB), .iWRITE_ADDR(iWRITE_ADDR), .iWRITE_DATA(iWRITE_DATA), 

        /* write */
        .m_AWREADY(AWREADY), .m_AWVALID(AWVALID), .m_AWPROT(AWPROT), .m_AWADDR(AWADDR),
        .m_WREADY(WREADY), .m_WVALID(WVALID), .m_WSTRB(WSTRB), .m_WDATA(WDATA),
        .m_BVALID(BVALID), .m_BRESP(BRESP), .m_BREADY(BREADY),

        /* read */
        .m_ARREADY(ARREADY), .m_ARVALID(ARVALID), .m_ARADDR(ARADDR), .m_ARPROT(ARPROT), 
        .m_RVALID(RVALID), .m_RDATA(RDATA), .m_RRESP(RRESP), .m_RREADY(RREADY)
    );

    ram_axi_wrapper ram (
        .iCLK(iCLK), .iRST(iRST),

        .s_ARVALID(ARVALID), .s_ARPROT(ARPROT), .s_ARADDR(ARADDR), .s_ARREADY(ARREADY),
        .s_RREADY(RREADY), .s_RVALID(RVALID), .s_RDATA(RDATA), .s_RRESP(RRESP)
    );

endmodule