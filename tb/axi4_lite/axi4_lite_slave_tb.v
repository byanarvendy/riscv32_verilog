`timescale 1ns/1ns

`include "rtl/axi4_lite_slave.v"

module axi4_lite_slave_tb;
    reg         iCLK;
    reg         iRST;

    reg         s_AWVALID;
    reg  [31:0] s_AWADDR;
    reg         s_WVALID;
    reg  [31:0] s_WDATA;
    reg  [3:0]  s_WSTRB;
    reg         s_BREADY;
    reg         s_ARVALID;
    reg  [31:0] s_ARADDR;
    reg         s_RREADY;

    // wire [7:0]  addr;

    wire        s_AWREADY;
    wire        s_WREADY;
    wire        s_BVALID;
    wire [1:0]  s_BRESP;
    wire        s_ARREADY;
    wire        s_RVALID;
    wire [31:0] s_RDATA;
    wire [1:0]  s_RRESP;

    axi4_lite_slave uut (
        .iCLK(iCLK), .iRST(iRST),

        /* write */
        .s_AWVALID(s_AWVALID), .s_AWREADY(s_AWREADY), .s_AWADDR(s_AWADDR),
        .s_WVALID(s_WVALID), .s_WREADY(s_WREADY), .s_WSTRB(s_WSTRB), .s_WDATA(s_WDATA),
        .s_BVALID(s_BVALID), .s_BREADY(s_BREADY), .s_BRESP(s_BRESP),

        /* read */
        .s_ARVALID(s_ARVALID), .s_ARREADY(s_ARREADY), .s_ARADDR(s_ARADDR),
        .s_RVALID(s_RVALID), .s_RREADY(s_RREADY), .s_RDATA(s_RDATA), .s_RRESP(s_RRESP)
    );

    task display();
        begin
            $display("# Write Address Channel     -> AWVALID: 0x%x, AWREADY: 0x%x, AWADDR: 0x%x", s_AWVALID, s_AWREADY, s_AWADDR);
            $display("# Write Data Channel        -> WVALID: 0x%x, WREADY: 0x%x, WDATA: 0x%x, WSTRB: 0x%x", s_WVALID, s_WREADY, s_WDATA, s_WSTRB);
            $display("# Write Response Channel    -> BVALID: 0x%x, BREADY: 0x%x, BRESP: 0x%x", s_BVALID, s_BREADY, s_BRESP);

            $display("# Read Address Channel      -> ARVALID: 0x%x, ARREADY: 0x%x, ARADDR: 0x%x", s_ARVALID, s_ARREADY, s_ARADDR);
            $display("# Read Data Channel         -> RVALID: 0x%x, RREADY: 0x%x, RDATA: 0x%x, RRESP: 0x%x", s_RVALID, s_RREADY, s_RDATA, s_RRESP);
        end
    endtask

    initial begin
        iCLK = 1;
        forever #5 iCLK = ~iCLK;
    end

    initial begin
        iRST      = 1'b0;
        s_AWVALID = 1'b0;
        s_AWADDR  = 32'h0;
        s_WVALID  = 1'b0;
        s_WDATA   = 32'h0;
        s_WSTRB   = 4'b0;
        s_BREADY  = 1'b0;
        s_ARVALID = 1'b0;
        s_ARADDR  = 32'h0;
        s_RREADY  = 1'b0;

        #10; iRST = 1'b1;


        // /* === WRITE TRANSACTION === */

            s_AWVALID = 1'b1;
            s_AWADDR  = 32'h00000001;
            s_WVALID  = 1'b1;
            s_WDATA   = 32'hDEADBEEF;
            s_WSTRB   = 4'b1111;
            s_BREADY  = 1'b1;

            display();

            #40; 
                s_AWVALID = 1'b0;
                s_AWADDR  = 32'h0;
                s_WVALID  = 1'b0;
                s_WDATA   = 32'h0;
                s_WSTRB   = 4'b0;

            #10;
                s_BREADY  = 1'b0;

            display();


        /* === READ TRANSACTION === */

            s_ARVALID = 1'b1;
            s_ARADDR  = 32'h2;
            s_RREADY  = 1'b1;

            display();

            #40; 
                s_ARVALID = 1'b0;
                s_ARADDR  = 32'h0;

            #10;
                s_RREADY  = 1'b0;
            
            display();

        // /* === WRITE TRANSACTION === */

            s_AWVALID = 1'b1;
            s_AWADDR  = 32'h00000001;
            s_WVALID  = 1'b1;
            s_WDATA   = 32'hDEADBEEF;
            s_WSTRB   = 4'b1111;
            s_BREADY  = 1'b1;

            display();

            #40; 
                s_AWVALID = 1'b0;
                s_AWADDR  = 32'h0;
                s_WVALID  = 1'b0;
                s_WDATA   = 32'h0;
                s_WSTRB   = 4'b0;

            #10;
                s_BREADY  = 1'b0;

            display();


        /* === READ TRANSACTION === */

            s_ARVALID = 1'b1;
            s_ARADDR  = 32'h2;
            s_RREADY  = 1'b1;

            display();

            #40; 
                s_ARVALID = 1'b0;
                s_ARADDR  = 32'h0;

            #10;
                s_RREADY  = 1'b0;
            
            display();


        #250; $display("Simulation finished.");
        $finish;
    end

    initial begin
        $dumpfile("sim/axi4_lite_slave_tb.vcd");
        $dumpvars(1, iCLK, s_AWVALID, s_AWREADY, s_AWADDR, s_WVALID, s_WREADY, s_WDATA, s_WSTRB, s_BVALID, s_BREADY, s_BRESP);
        $dumpvars(1, iCLK, s_ARVALID, s_ARREADY, s_ARADDR, s_RVALID, s_RREADY, s_RDATA);
    end

endmodule
