`timescale 1ns/1ns

`include "rtl/axi4_lite_master.v"

module axi4_lite_master_tb;
    reg         iCLK;
    reg         iRST;

    reg         iWRITE_START;
    reg         iREAD_START;
    reg  [31:0] iWRITE_ADDR;
    reg  [31:0] iWRITE_DATA;
    reg  [3:0]  iWRITE_STRB;
    reg  [31:0] iREAD_ADDR;

    wire [31:0] m_AWADDR, m_WDATA;
    wire [3:0]  m_WSTRB;

    wire        m_AWVALID;
    wire [2:0]  m_AWPROT;
    wire        m_WVALID;
    wire        m_BREADY;
    wire        m_ARVALID;
    wire [31:0] m_ARADDR;
    wire [2:0]  m_ARPROT;
    wire        m_RREADY;

    reg         m_AWREADY;
    reg         m_WREADY;
    reg         m_BVALID;
    reg  [1:0]  m_BRESP;
    reg         m_ARREADY;
    reg         m_RVALID;
    reg  [31:0] m_RDATA;
    reg  [1:0]  m_RRESP;

    axi4_lite_master uut (
        .iCLK(iCLK), .iRST(iRST),

        /* interfaces */
        .iWRITE_START(iWRITE_START), .iWRITE_ADDR(iWRITE_ADDR), .iWRITE_DATA(iWRITE_DATA), .iWRITE_STRB(iWRITE_STRB),
        .iREAD_START(iREAD_START), .iREAD_ADDR(iREAD_ADDR),

        /* write */
        .m_AWREADY(m_AWREADY), .m_AWVALID(m_AWVALID), .m_AWPROT(m_AWPROT), .m_AWADDR(m_AWADDR),
        .m_WREADY(m_WREADY), .m_WVALID(m_WVALID), .m_WDATA(m_WDATA), .m_WSTRB(m_WSTRB),
        .m_BVALID(m_BVALID), .m_BREADY(m_BREADY), .m_BRESP(m_BRESP),

        /* read */
        .m_ARREADY(m_ARREADY), .m_ARVALID(m_ARVALID), .m_ARADDR(m_ARADDR), .m_ARPROT(m_ARPROT),
        .m_RVALID(m_RVALID), .m_RDATA(m_RDATA), .m_RRESP(m_RRESP), .m_RREADY(m_RREADY)
    );

    task display();
        begin
            $display("# Write Address Channel     -> AWVALID: 0x%x, AWREADY: 0x%x, AWADDR: 0x%x", m_AWVALID, m_AWREADY, m_AWADDR);
            $display("# Write Data Channel        -> WVALID: 0x%x, WREADY: 0x%x, WDATA: 0x%x, WSTRB: 0x%x", m_WVALID, m_WREADY, m_WDATA, m_WSTRB);
            $display("# Write Response Channel    -> BVALID: 0x%x, BREADY: 0x%x, BRESP: 0x%x", m_BVALID, m_BREADY, m_BRESP);

            $display("# Read Address Channel      -> ARVALID: 0x%x, ARREADY: 0x%x, ARADDR: 0x%x", m_ARVALID, m_ARREADY, m_ARADDR);
            $display("# Read Data Channel         -> RVALID: 0x%x, RREADY: 0x%x, RDATA: 0x%x, RRESP: 0x%x", m_RVALID, m_RREADY, m_RDATA, m_RRESP);
        end
    endtask

    initial begin
        iCLK = 1;
        forever #5 iCLK = ~iCLK;
    end

    initial begin
        iRST          = 1'b0;
        iWRITE_START  = 1'b0;
        iREAD_START   = 1'b0;
        iWRITE_ADDR   = 32'h0;
        iWRITE_DATA   = 32'h0;
        iWRITE_STRB   = 4'b0;
        iREAD_ADDR    = 32'h0;
        m_AWREADY     = 1'b0;
        m_WREADY      = 1'b0;
        m_BVALID      = 1'b0;
        m_BRESP       = 2'b00;
        m_ARREADY     = 1'b0;
        m_RVALID      = 1'b0;
        m_RDATA       = 32'h0;
        m_RRESP       = 2'b00;

        #10; iRST = 1'b1;


        /* === WRITE TRANSACTION === */

            iWRITE_START    = 1'b1;
            iWRITE_ADDR     = 32'h00001000;
            iWRITE_DATA     = 32'hDEADBEEF;
            iWRITE_STRB     = 4'b1111;

            $display("\n# initial");
            display();

            #30; 
                m_AWREADY       = 1'b1;
                m_WREADY        = 1'b1;

            #10;
                iWRITE_START    = 1'b0;
                iWRITE_ADDR     = 32'h0;
                iWRITE_DATA     = 32'h0;
                iWRITE_STRB     = 4'b0;
                m_AWREADY       = 1'b0;
                m_WREADY        = 1'b0;
                m_BVALID        = 1'b1;

            #10;
                m_BVALID        = 1'b0;
            
            display();


        /* === READ TRANSACTION === */

            iREAD_START     = 1'b1;
            iREAD_ADDR      = 32'h00001000;

            $display("\n# initial");
            display();

            #30; 
                m_ARREADY       = 1'b1;

            #10;
                iREAD_START     = 1'b0;
                iREAD_ADDR      = 32'h0;
                m_ARREADY       = 1'b0;
                m_RVALID        = 1'b1;
                m_RDATA         = 32'hCAFEBABE;

            #10;
                m_RVALID        = 1'b0;
                            
            display();


        #100; $display("Simulation finished.");
        $finish;
    end

    initial begin
        $dumpfile("sim/axi4_lite_master_tb.vcd");
        $dumpvars(1, iCLK, iWRITE_START, iWRITE_ADDR, iWRITE_DATA, iWRITE_STRB, m_AWVALID, m_AWREADY, m_AWADDR, m_WVALID, m_WREADY, m_WDATA, m_WSTRB, m_BVALID, m_BREADY, m_BRESP);
        $dumpvars(1, iCLK, iREAD_START, iREAD_ADDR, m_ARVALID, m_ARREADY, m_ARADDR, m_RVALID, m_RREADY, m_RDATA, m_RRESP);
    end

endmodule
