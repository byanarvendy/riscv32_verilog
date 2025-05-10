module axi4_lite_master (
    input               iCLK, iRST,

    /* interfaces */
    input               iWRITE_START,
    input               iREAD_START,
    input       [3:0]   iWRITE_STRB,
    input       [31:0]  iWRITE_ADDR,
    input       [31:0]  iWRITE_DATA,
    input       [31:0]  iREAD_ADDR,

    /* write address channel */
    input               m_AWREADY,
    output  reg         m_AWVALID,
    output  reg [2:0]   m_AWPROT,
    output      [31:0]  m_AWADDR,

    /* write data channel */
    input               m_WREADY,
    output  reg         m_WVALID,
    output      [3:0]   m_WSTRB,
    output      [31:0]  m_WDATA,

    /* write response channel */
    input               m_BVALID,
    input       [1:0]   m_BRESP,
    output  reg         m_BREADY,

    /* read address channel */
    input               m_ARREADY,
    output  reg         m_ARVALID,
    output  reg [2:0]   m_ARPROT,
    output      [31:0]  m_ARADDR,

    /* read data channel */
    input               m_RVALID,
    output  reg         m_RREADY,
    input       [1:0]   m_RRESP,
    input       [31:0]  m_RDATA
);

    assign m_AWADDR  = iWRITE_ADDR;
    assign m_WDATA   = iWRITE_DATA;
    assign m_WSTRB   = iWRITE_STRB;
    assign m_ARADDR  = iREAD_ADDR;

    /* write transaction */
    always @(posedge iCLK or negedge iRST) begin
        if (!iRST) begin
            m_AWVALID   <= 1'b0;
            m_WVALID    <= 1'b0;
            m_BREADY    <= 1'b0;
        end else begin
            if (iWRITE_START && !m_AWVALID && !m_WVALID) begin
                m_AWVALID   <= 1'b1;
                m_WVALID    <= 1'b1;
                m_BREADY    <= 1'b1;
            end

            if (m_AWREADY && m_AWVALID) begin
                m_AWVALID   <= 1'b0;
            end
            if (m_WREADY && m_WVALID) begin
                m_WVALID    <= 1'b0;
            end

            if (m_BVALID && m_BREADY) begin
                m_BREADY    <= 1'b0; 
            end
        end
    end

    /* read transaction */
    always @(posedge iCLK or negedge iRST) begin
        if (!iRST) begin
            m_ARVALID   <= 1'b0;
            m_RREADY    <= 1'b0;
        end else begin
            if (iREAD_START && !m_ARVALID && !m_RREADY) begin
                m_ARVALID   <= 1'b1;
                m_RREADY    <= 1'b1;
            end

            if (m_ARVALID && m_ARREADY) begin
                m_ARVALID   <= 1'b0;
            end

            if (m_RVALID && m_RREADY) begin
                m_RREADY    <= 1'b0;
            end
        end
    end

endmodule