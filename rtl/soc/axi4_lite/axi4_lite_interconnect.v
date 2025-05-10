module axi4_lite_interconnect (
    input               iCLK, iRST,
    output              oSEL,

    /* master interface */
        /* write address channel */
        input               m_AWVALID,
        input       [2:0]   m_AWPROT,
        input       [31:0]  m_AWADDR,
        output              m_AWREADY,

        /* write data channel */
        input               m_WVALID,
        input       [3:0]   m_WSTRB,
        input       [31:0]  m_WDATA,

        output              m_WREADY,

        /* write request channel */
        input               m_BREADY,
        output              m_BVALID,
        output      [1:0]   m_BRESP,

        /* read address channel */
        input               m_ARVALID,
        input       [2:0]   m_ARPROT,
        input       [31:0]  m_ARADDR,
        output              m_ARREADY,

        /* read data channel */
        input               m_RREADY,
        output              m_RVALID,
        output      [1:0]   m_RRESP,
        output      [31:0]  m_RDATA,

    /* slave 0 interfcae -> ROM */
        /* write address channel */
        input               s0_AWREADY,
        output              s0_AWVALID,
        output      [2:0]   s0_AWPROT,
        output      [31:0]  s0_AWADDR,

        /* write data channel */
        input               s0_WREADY,
        output              s0_WVALID,
        output      [3:0]   s0_WSTRB,
        output      [31:0]  s0_WDATA,

        /* write response channel */
        input               s0_BVALID,
        input       [1:0]   s0_BRESP,
        output              s0_BREADY,

        /* read address channel */
        input               s0_ARREADY,
        output              s0_ARVALID,
        output      [2:0]   s0_ARPROT,
        output      [31:0]  s0_ARADDR,

        /* read data channel */
        input               s0_RVALID,
        input       [1:0]   s0_RRESP,
        input       [31:0]  s0_RDATA,
        output              s0_RREADY,

    /* slvae 1 interfcae -> RAM */
        /* write address channel */
        input               s1_AWREADY,
        output              s1_AWVALID,
        output      [2:0]   s1_AWPROT,
        output      [31:0]  s1_AWADDR,

        /* write data channel */
        input               s1_WREADY,
        output              s1_WVALID,
        output      [3:0]   s1_WSTRB,
        output      [31:0]  s1_WDATA,

        /* write response channel */
        input               s1_BVALID,
        input       [1:0]   s1_BRESP,
        output              s1_BREADY,

        /* read address channel */
        input               s1_ARREADY,
        output              s1_ARVALID,
        output      [2:0]   s1_ARPROT,
        output      [31:0]  s1_ARADDR,

        /* read data channel */
        input               s1_RVALID,
        input       [1:0]   s1_RRESP,
        input       [31:0]  s1_RDATA,
        output              s1_RREADY
);

    wire    [1:0]   SEL;
    wire            rROM, rRAM, wRAM;


    /* transaction tracking */
    reg     active_sel;
    reg     transaction_active;
    wire    transaction_start   = m_AWVALID || m_ARVALID;
    wire    transaction_end     = (m_BREADY && !m_AWVALID) || (m_RREADY && !m_ARVALID);

    always @(posedge iCLK or negedge iRST) begin
        if (!iRST) begin
            transaction_active      <= 1'b0;
            active_sel              <= 1'bx;
        end else begin
            if (transaction_start) begin
                transaction_active  <= 1'b1;
            end
            if (transaction_active) begin
                active_sel          <= (m_AWADDR[31] === 1'b1) ? 1'b1 :
                                       (m_ARADDR[31] === 1'b1) ? 1'b1 :
                                       1'b0;
            end
            if (transaction_end) begin
                transaction_active  <= 1'b0;
            end

        end
    end

    assign oSEL         = SEL[0];
    assign SEL          = (m_AWADDR[31] === 1'b1 || m_ARADDR[31] === 1'b1) ? 2'b01   :    /* ram */
                          (m_ARADDR[31] === 1'b0)                          ? 2'b00   :    /* rom */
                          2'b10;

    /* assign transaction */
    assign rROM         = ((SEL === 2'b00) && (m_RREADY === 1'b1)) ? 1'b1 : 1'b0;
    assign rRAM         = ((SEL === 2'b01) && (m_RREADY === 1'b1)) ? 1'b1 : 1'b0;
    assign wRAM         = ((active_sel == 1'b1)) ? 1'b1 : 1'b0;
    // assign rROM         = ((active_sel == 1'b0) && (m_RREADY === 1'b1)) ? 1'b1 : 1'b0;
    // assign rRAM         = ((active_sel == 1'b1) && (m_RREADY === 1'b1)) ? 1'b1 : 1'b0;
    // assign wRAM         = ((active_sel == 1'b1) && (m_BREADY === 1'b1)) ? 1'b1 : 1'b0;


    /* write address channel */
    assign m_AWREADY    = (wRAM) ? s1_AWREADY       : 1'b0;  
    assign s1_AWVALID   = (wRAM) ? m_AWVALID        : 1'b0;
    assign s1_AWPROT    = (wRAM) ? m_AWPROT         : 1'b0;
    assign s1_AWADDR    = (wRAM) ? m_AWADDR[30:0]   : 32'hx;


    /* write data channel */
    assign m_WREADY     = (wRAM) ? s1_WREADY        : 1'b0;  
    assign s1_WVALID    = (wRAM) ? m_WVALID         : 1'b0;
    assign s1_WSTRB     = (wRAM) ? m_WSTRB          : 1'b0;
    assign s1_WDATA     = (wRAM) ? m_WDATA          : 32'hx;


    /* write response channel */
    assign m_BVALID     = (wRAM) ? s1_BVALID        : 1'b0;  
    assign m_BRESP      = (wRAM) ? s1_BRESP         : 2'b00;  
    assign s1_BREADY    = (wRAM) ? m_BREADY         : 1'b0; 
    // assign m_BVALID     = (active_sel == 1'b1) ? s1_BVALID        : 1'b0;  
    // assign m_BRESP      = (wRAM) ? s1_BRESP         : 2'b00;  
    // assign s1_BREADY    = (active_sel == 1'b1) ? m_BREADY         : 1'b0; 


    /* read address channel */
    assign m_ARREADY    = (rROM) ? s0_ARREADY       : 
                          (rRAM) ? s1_ARREADY       :
                          1'b0;  

    assign s0_ARVALID   = (rROM) ? m_ARVALID        : 1'b0;
    assign s1_ARVALID   = (rRAM) ? m_ARVALID        : 1'b0;

    assign s0_ARPROT    = (rROM) ? m_ARPROT         : 1'b0;
    assign s1_ARPROT    = (rRAM) ? m_ARPROT         : 1'b0;

    assign s0_ARADDR    = (rROM) ? m_ARADDR[30:0]   : 1'b0;
    assign s1_ARADDR    = (rRAM) ? m_ARADDR[30:0]   : 1'b0;


    /* read data channel */
    assign m_RVALID     = (rROM) ? s0_RVALID        : 
                          (rRAM) ? s1_RVALID        :
                          1'b0;  

    assign m_RRESP      = (rROM) ? s0_RRESP         : 
                          (rRAM) ? s1_RRESP         :
                          2'b0; 

    assign m_RDATA      = (rROM) ? s0_RDATA         : 
                          (rRAM) ? s1_RDATA         :
                          32'hx;

    assign s0_RREADY    = (rROM) ? m_RREADY         : 1'b0;
    assign s1_RREADY    = (rRAM) ? m_RREADY         : 1'b0;


endmodule