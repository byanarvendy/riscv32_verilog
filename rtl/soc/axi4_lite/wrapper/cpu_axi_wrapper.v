`include "rtl/core/riscv_32i.v"
`include "rtl/soc/axi4_lite/axi4_lite_master.v"

module cpu_axi_wrapper (
    input               iCLK, iRST, iSEL,
    output              WR_DONE,

    /* input */
    input               iWRITE_START,
    input               iREAD_START,
    input       [3:0]   iWRITE_STRB,
    input       [31:0]  iWRITE_ADDR,
    input       [31:0]  iWRITE_DATA,
    input       [31:0]  iREAD_ADDR,

    /* write address channel */
    input               m_AWREADY,
    output              m_AWVALID,
    output      [2:0]   m_AWPROT,
    output      [31:0]  m_AWADDR,

    /* write data channel */
    input               m_WREADY,
    output              m_WVALID,
    output      [3:0]   m_WSTRB,
    output      [31:0]  m_WDATA,

    /* write response channel */
    input               m_BVALID,
    input       [1:0]   m_BRESP,
    output              m_BREADY,

    /* read address channel */
    input               m_ARREADY,
    output              m_ARVALID,
    output      [2:0]   m_ARPROT,
    output      [31:0]  m_ARADDR,

    /* read data channel */
    input               m_RVALID,
    output              m_RREADY,
    input       [1:0]   m_RRESP,
    input       [31:0]  m_RDATA
);

    reg                 RAM;
    wire                IDDLE;
    wire                ROM_READ, RAM_READ, RAM_WRITE;
    wire        [31:0]  ROM_DATA, READ_ADDR, WRITE_ADDR, ROM_ADDR, RAM_ADDR, oRAM_ADDR, RAM_ADDR_RAM, oRAM_DATA, RAM_DATA;

    assign IDDLE            = !(w_TRANS || r_TRANS || RAM);
    assign ROM_DATA         = (iSEL) ? ROM_VALUE : m_RDATA;
    assign READ_ADDR        = (r_TRANS) ? ((READ_LATCH)  ? SAVED_RAM_ADDR : ROM_ADDR) : 32'hx;
    assign WRITE_ADDR       = (w_TRANS) ? ((m_AWVALID) ? SAVED_RAM_ADDR : 32'hx) : 32'hx;
    // assign WRITE_ADDR       = (w_TRANS) ? ((WRITE_LATCH) ? SAVED_RAM_ADDR : 32'hx) : 32'hx;
    assign oRAM_ADDR        = (READ_VALID)  ? RAM_READ_ADDR  :
                              (WRITE_VALID) ? RAM_WRITE_ADDR :
                              32'hx;
    assign RAM_DATA         = (w_TRANS) ? ((m_AWVALID) ? SAVED_RAM_DATA : 32'hx) : 32'hx;
    assign WR_DONE          = (w_TRANS) ? ((!m_AWVALID) ? 1'b1 : 1'b0) : 1'b0;

    /* address */
    reg         [31:0]  ROM_VALUE, RAM_READ_ADDR, RAM_WRITE_ADDR, RAM_WRITE_DATA, SAVED_RAM_ADDR, SAVED_RAM_DATA;
    reg                 READ_VALID, WRITE_VALID, READ_LATCH, WRITE_LATCH;

    always @(posedge iCLK or negedge iRST) begin
        if (!iRST) begin
            ROM_VALUE           <= 32'h0;
            RAM_READ_ADDR       <= 32'b0;
            READ_VALID          <= 1'b0;
            SAVED_RAM_ADDR      <= 32'bx;
            READ_LATCH          <= 1'b0;
            WRITE_LATCH         <= 1'b0;
        end
        else begin
            // if (m_RVALID && RAM_READ) begin
            //     ROM_VALUE       <= m_RDATA;
            // end

            if (r_TRANS && READ_ADDR[1] == 1'b0) begin
                ROM_VALUE       <= m_RDATA;
            end else begin
                ROM_VALUE       <= 32'hx;
            end

            if (RAM_READ) begin
                RAM_READ_ADDR   <= {1'b1, RAM_ADDR[30:0]};  
                READ_VALID      <= 1'b1;
            end else begin
                READ_VALID      <= 1'b0;     
            end

            if (RAM_WRITE) begin
                RAM_WRITE_ADDR  <= {1'b1, RAM_ADDR_RAM[30:0]};  
                WRITE_VALID     <= 1'b1;
                RAM_WRITE_DATA  <= oRAM_DATA;
            end else begin
                WRITE_VALID     <= 1'b0;     
            end

            if (READ_VALID) begin
                SAVED_RAM_ADDR  <= oRAM_ADDR;
                READ_LATCH      <= 1'b1;
            end else if (!r_TRANS) begin
                READ_LATCH      <= 1'b0;
            end

            if (WRITE_VALID) begin
                SAVED_RAM_ADDR  <= RAM_WRITE_ADDR;
                WRITE_LATCH     <= 1'b1;
                SAVED_RAM_DATA  <= RAM_WRITE_DATA;
            end else if (!w_TRANS) begin
                WRITE_LATCH     <= 1'b0;
            end
        end
    end
                   

    /* transaction track */
    reg w_TRANS, r_TRANS;

    initial begin
        w_TRANS     = 1'b0;
        r_TRANS     = 1'b0;
        RAM         = 1'b0;
    end

    always @(posedge iCLK or negedge iRST) begin
        if (!iRST) begin
            w_TRANS             <= 1'b0;
            r_TRANS             <= 1'b0;
            RAM                 <= 1'b0;
        end else begin
            /* write */
            if (WRITE_VALID) begin
                w_TRANS         <= 1'b1;
            end else if (m_AWVALID && m_WVALID && m_BREADY) begin
                w_TRANS         <= 1'b1;
            end else w_TRANS    <= 1'b0;


            /* read */
            // if (!m_AWVALID && m_WREADY && !m_AWREADY) begin
            //     r_TRANS         <= 1'b0;
            // end else r_TRANS    <= 1'b1;

            if ((!m_ARVALID && m_RREADY && !m_ARREADY) || (w_TRANS) || (WRITE_VALID)) begin
                r_TRANS         <= 1'b0;
            end else r_TRANS    <= 1'b1;


            /* ram */
            RAM                 <= RAM_READ || RAM_WRITE;
        end
    end


    riscv_32i cpu (
        .iRST(iRST), .iCLK(iCLK), .WR_DONE(WR_DONE),
        
        /* rom */
        .iROM_VALID(m_RVALID && !iSEL),
        .oROM_READ(ROM_READ),
        .oROM_ADDR(ROM_ADDR), .iROM_DATA(ROM_DATA),

        /* ram */
        .oRAM_RD(RAM_READ), .oRAM_WR(RAM_WRITE),
        .oRAM_ADDR(RAM_ADDR), .oRAM_ADDR_RAM(RAM_ADDR_RAM), .oRAM_DATA(oRAM_DATA), 
        .iRAM_DATA(m_RDATA), .iRAM_VALID(RAM),

        .iIDDLE(IDDLE)
    );

    axi4_lite_master axi_master (
        .iCLK(iCLK), .iRST(iRST),

        /* interfaces */
        .iWRITE_START(WRITE_VALID), .iWRITE_STRB(iWRITE_STRB), .iWRITE_ADDR(WRITE_ADDR), .iWRITE_DATA(RAM_DATA),
        .iREAD_START(ROM_READ || READ_VALID), .iREAD_ADDR(READ_ADDR),

        /* write */
        .m_AWREADY(m_AWREADY), .m_AWVALID(m_AWVALID), .m_AWPROT(m_AWPROT), .m_AWADDR(m_AWADDR),
        .m_WREADY(m_WREADY), .m_WVALID(m_WVALID), .m_WSTRB(m_WSTRB), .m_WDATA(m_WDATA),
        .m_BVALID(m_BVALID), .m_BRESP(m_BRESP), .m_BREADY(m_BREADY),

        /* read */
        .m_ARREADY(m_ARREADY), .m_ARVALID(m_ARVALID), .m_ARPROT(m_ARPROT), .m_ARADDR(m_ARADDR),
        .m_RVALID(m_RVALID), .m_RDATA(m_RDATA), .m_RRESP(m_RRESP), .m_RREADY(m_RREADY)
    );

endmodule