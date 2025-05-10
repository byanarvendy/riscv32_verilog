`timescale 1ps/1ps

`include "rtl/soc/axi4_lite/wrapper/cpu_axi_wrapper.v"
`include "rtl/soc/axi4_lite/wrapper/rom_axi_wrapper.v"
`include "rtl/soc/axi4_lite/wrapper/ram_axi_wrapper.v"
`include "rtl/soc/axi4_lite/axi4_lite_interconnect.v"

module axi4_lite_interconnect_tb;
    reg         iCLK, iRST;

    /* master interfaces */
    reg        iREAD_START, iWRITE_START;
    reg [3:0]  iWRITE_STRB;
    reg [31:0] iREAD_ADDR, iWRITE_ADDR, iWRITE_DATA;

    wire        m_AWVALID, m_AWREADY, m_WVALID, m_WREADY, m_BVALID, m_BREADY;
    wire        m_ARVALID, m_ARREADY, m_RVALID, m_RREADY;
    wire [1:0]  m_BRESP, m_RRESP;
    wire [2:0]  m_AWPROT, m_ARPROT;
    wire [3:0]  m_WSTRB;
    wire [31:0] m_AWADDR, m_WDATA, m_ARADDR, m_RDATA;


    /* slave 0 interfaces */
    wire        s0_AWVALID, s0_AWREADY, s0_WVALID, s0_WREADY, s0_BVALID, s0_BREADY;
    wire        s0_ARVALID, s0_ARREADY, s0_RVALID, s0_RREADY;
    wire [1:0]  s0_BRESP, s0_RRESP;
    wire [2:0]  s0_AWPROT, s0_ARPROT;
    wire [3:0]  s0_WSTRB;
    wire [31:0] s0_AWADDR, s0_WDATA, s0_ARADDR, s0_RDATA;


    /* slave 1 interfaces */
    wire        s1_AWVALID, s1_AWREADY, s1_WVALID, s1_WREADY, s1_BVALID, s1_BREADY;
    wire        s1_ARVALID, s1_ARREADY, s1_RVALID, s1_RREADY;
    wire [1:0]  s1_BRESP, s1_RRESP;
    wire [2:0]  s1_AWPROT, s1_ARPROT;
    wire [3:0]  s1_WSTRB;
    wire [31:0] s1_AWADDR, s1_WDATA, s1_ARADDR, s1_RDATA;


    axi4_lite_interconnect interconnect (
        .iCLK(iCLK), .iRST(iRST), .oSEL(SEL),

        /* master */
        .m_AWVALID(m_AWVALID), .m_AWREADY(m_AWREADY), .m_AWPROT(m_AWPROT), .m_AWADDR(m_AWADDR),
        .m_WVALID(m_WVALID), .m_WREADY(m_WREADY), .m_WSTRB(m_WSTRB), .m_WDATA(m_WDATA),
        .m_BVALID(m_BVALID), .m_BREADY(m_BREADY), .m_BRESP(m_BRESP),
        .m_ARVALID(m_ARVALID), .m_ARREADY(m_ARREADY), .m_ARPROT(m_ARPROT), .m_ARADDR(m_ARADDR),
        .m_RVALID(m_RVALID), .m_RREADY(m_RREADY), .m_RRESP(m_RRESP), .m_RDATA(m_RDATA),

        /* slave 0 */
        .s0_AWVALID(s0_AWVALID), .s0_AWREADY(s0_AWREADY), .s0_AWPROT(s0_AWPROT), .s0_AWADDR(s0_AWADDR),
        .s0_WVALID(s0_WVALID), .s0_WREADY(s0_WREADY), .s0_WSTRB(s0_WSTRB), .s0_WDATA(s0_WDATA),
        .s0_BVALID(s0_BVALID), .s0_BREADY(s0_BREADY), .s0_BRESP(s0_BRESP),
        .s0_ARVALID(s0_ARVALID), .s0_ARREADY(s0_ARREADY), .s0_ARPROT(s0_ARPROT), .s0_ARADDR(s0_ARADDR), 
        .s0_RVALID(s0_RVALID), .s0_RREADY(s0_RREADY), .s0_RRESP(s0_RRESP), .s0_RDATA(s0_RDATA),

        /* slave 1 */
        .s1_AWVALID(s1_AWVALID), .s1_AWREADY(s1_AWREADY), .s1_AWPROT(s1_AWPROT), .s1_AWADDR(s1_AWADDR),
        .s1_WVALID(s1_WVALID), .s1_WREADY(s1_WREADY), .s1_WSTRB(s1_WSTRB), .s1_WDATA(s1_WDATA),
        .s1_BVALID(s1_BVALID), .s1_BREADY(s1_BREADY), .s1_BRESP(s1_BRESP),
        .s1_ARVALID(s1_ARVALID), .s1_ARREADY(s1_ARREADY), .s1_ARPROT(s1_ARPROT), .s1_ARADDR(s1_ARADDR),
        .s1_RVALID(s1_RVALID), .s1_RREADY(s1_RREADY), .s1_RRESP(s1_RRESP), .s1_RDATA(s1_RDATA)
    );

    cpu_axi_wrapper cpu (
        .iCLK(iCLK), .iRST(iRST), .iSEL(SEL),

        /* interfaces */
        // .iREAD_START(iREAD_START), .iREAD_ADDR(iREAD_ADDR),
        // .iWRITE_START(iWRITE_START), .iWRITE_STRB(iWRITE_STRB), .iWRITE_ADDR(iWRITE_ADDR), .iWRITE_DATA(iWRITE_DATA), 

        /* write */
        .m_AWREADY(m_AWREADY), .m_AWVALID(m_AWVALID), .m_AWPROT(m_AWPROT), .m_AWADDR(m_AWADDR),
        .m_WREADY(m_WREADY), .m_WVALID(m_WVALID), .m_WSTRB(m_WSTRB), .m_WDATA(m_WDATA),
        .m_BVALID(m_BVALID), .m_BRESP(m_BRESP), .m_BREADY(m_BREADY),

        /* read */
        .m_ARREADY(m_ARREADY), .m_ARVALID(m_ARVALID), .m_ARADDR(m_ARADDR), .m_ARPROT(m_ARPROT), 
        .m_RVALID(m_RVALID), .m_RDATA(m_RDATA), .m_RRESP(m_RRESP), .m_RREADY(m_RREADY)
    );

    rom_axi_wrapper rom (
        .iCLK(iCLK), .iRST(iRST),

        /* read */
        .s_ARVALID(s0_ARVALID), .s_ARPROT(s0_ARPROT), .s_ARADDR(s0_ARADDR), .s_ARREADY(s0_ARREADY),
        .s_RREADY(s0_RREADY), .s_RVALID(s0_RVALID), .s_RDATA(s0_RDATA), .s_RRESP(s0_RRESP)
    );

    ram_axi_wrapper ram (
        .iCLK(iCLK), .iRST(iRST),
        
        /* write */
        .s_AWREADY(s1_AWREADY), .s_AWVALID(s1_AWVALID), .s_AWPROT(s1_AWPROT), .s_AWADDR(s1_AWADDR),
        .s_WREADY(s1_WREADY), .s_WVALID(s1_WVALID), .s_WSTRB(s1_WSTRB), .s_WDATA(s1_WDATA),
        .s_BVALID(s1_BVALID), .s_BRESP(s1_BRESP), .s_BREADY(s1_BREADY),
        
        /* read */
        .s_ARVALID(s1_ARVALID), .s_ARPROT(s1_ARPROT), .s_ARADDR(s1_ARADDR), .s_ARREADY(s1_ARREADY),
        .s_RREADY(s1_RREADY), .s_RVALID(s1_RVALID), .s_RDATA(s1_RDATA), .s_RRESP(s1_RRESP)
    );

    integer i;

    initial begin
        $dumpfile("sim/axi4_lite_interconnect_tb.vcd");
        $dumpvars(0, axi4_lite_interconnect_tb);

        /* initialize */
        iRST                = 1'b0;
        iCLK                = 1'b0;
        
        #10; iRST           = 1'b1;

		for (i = 0; i < 300; i = i +1 ) begin
            #5 iCLK = 0;
            #5 iCLK = 1;
            i++;
		end

        $display("\n simulasi selesai pada clock ke-%0d", i/2);
        $finish;
    end

endmodule