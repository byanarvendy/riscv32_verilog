module instruction_s (
    input           iCLK, iRST,
    input   [31:0]  iIR, iREG_OUT1, iREG_OUT2,
    output  [4:0]   oRD, oRS1, oRS2,
    output  [31:0]  oREG_IN,

    input   [31:0]  iRAM_DATA,
    output          oRAM_CE, oRAM_RD, oRAM_WR,
    output  [31:0]  oRAM_ADDR, oRAM_ADDR_RAM, oRAM_DATA
);

    reg             ram_wr, rSTAL;
    reg     [2:0]   func3_ram;
    reg     [4:0]   RD_RAM;
    reg     [31:0]  ram_address_ram, ram_addr, alu_in2_ram, alu_out_ram;
    wire    [31:0]  ram_data;

    wire            RAM_DONE;

    wire    [2:0]   func3;
    wire    [11:0]  imm;
    wire    [31:0]  alu_in1, alu_in2, alu_out, ram_address, ram_data_rd;
    wire    [31:0]  ram_data_byte_wr, ram_data_half_wr, ram_data_word_wr;
    wire    [15:0]  ram_data_half;

    assign oRD              = 5'h00;
    assign oRS1             = iIR[19:15];
    assign oRS2             = iIR[24:20];

    assign imm              = {iIR[31:25], iIR[11:7]};
    assign func3            = iIR[14:12];

    assign alu_in1          = iREG_OUT1;
    assign alu_in2          = iREG_OUT2;

    assign oRAM_WR          = (alu_out_ram !== 32'hx) ? 1'b1 : 1'b0;
    // assign oRAM_CE      = 1'b1;
    // assign oRAM_RD      = 1'b1;

    assign oRAM_CE          = (iIR[6:0] == 7'b0100011) ? 1'b1 : 1'b0;
    assign oRAM_RD          = (iIR[6:0] == 7'b0100011) ? 1'b1 : 1'b0;

    assign ram_address      = alu_in1 + imm;
    assign oRAM_ADDR        = ram_address >> 2;
    assign oRAM_ADDR_RAM    = ram_addr;

    // assign ram_data_rd  = iRAM_DATA;

    // assign ram_data_byte_wr = (ram_address[1:0] == 2'b00) ? (alu_in2[7:0] | (ram_data_rd & 32'hffffff00)) :
    //                           (ram_address[1:0] == 2'b01) ? ((alu_in2[7:0] << 8) | (ram_data_rd & 32'hffff00ff)) :
    //                           (ram_address[1:0] == 2'b10) ? ((alu_in2[7:0] << 16) | (ram_data_rd & 32'hff00ffff)) :
    //                           (ram_address[1:0] == 2'b11) ? ((alu_in2[7:0] << 24) | (ram_data_rd & 32'h00ffffff)) :
    //                           32'h00;
    
    // assign ram_data_half_wr = (ram_address[1] == 1'b0) ? ((alu_in2[15:0]) | (ram_data_rd & 32'hffff0000)) :
    //                           (ram_address[1] == 1'b1) ? ((alu_in2[15:0] << 16) | (ram_data_rd & 32'h0000ffff)) :
    //                           32'h00;

    // assign ram_data_word_wr = alu_in2;

    assign ram_data         = iRAM_DATA;

    assign ram_data_byte_wr = (ram_address_ram[1:0] == 2'b00) ? (alu_in2_ram[7:0] | (ram_data & 32'hffffff00)) :
                              (ram_address_ram[1:0] == 2'b01) ? ((alu_in2_ram[7:0] << 8) | (ram_data & 32'hffff00ff)) :
                              (ram_address_ram[1:0] == 2'b10) ? ((alu_in2_ram[7:0] << 16) | (ram_data & 32'hff00ffff)) :
                              (ram_address_ram[1:0] == 2'b11) ? ((alu_in2_ram[7:0] << 24) | (ram_data & 32'h00ffffff)) :
                              32'h00;
    
    assign ram_data_half_wr = (ram_address_ram[1] == 1'b0) ? ((alu_in2_ram[15:0]) | (ram_data & 32'hffff0000)) :
                              (ram_address_ram[1] == 1'b1) ? ((alu_in2_ram[15:0] << 16) | (ram_data & 32'h0000ffff)) :
                              32'h00;

    assign ram_data_word_wr = alu_in2_ram;

    // assign oRAM_DATA    = (func3 == {3'h0}) ? ram_data_byte_wr :       /* store byte */
    //                       (func3 == {3'h1}) ? ram_data_half_wr :       /* store half */
    //                       (func3 == {3'h2}) ? ram_data_word_wr :       /* store word */
    //                       32'h00000000;

    assign oRAM_DATA        = alu_out_ram;

    assign oREG_IN      = 32'h00;
    
    assign RAM_DONE = (alu_out_ram !== 32'hx) ? 1'b1 : 1'b0;

    /* ram */
    always @(posedge iCLK or negedge iRST) begin
        if (!iRST) begin
            rSTAL           <= 1'b0;
            ram_wr          <= 1'b0;
        end

        if ((iIR[6:0] == 7'b0100011)) begin
            ram_address_ram <= ram_address;
            rSTAL           <= 1'b1;
            alu_in2_ram     <= alu_in2;
            func3_ram       <= func3;
            ram_wr          <= 1'b0;
            RD_RAM          <= oRD;             /* =========== !!! =========== */
        end 
        else if (alu_out_ram !== 32'hx) begin
            ram_address_ram <= 32'hx;
            rSTAL           <= 1'b0;
            func3_ram       <= 3'hx;
            RD_RAM          <= 5'hx;
            alu_in2_ram     <= 32'hx;
            alu_out_ram     <= 32'hx;
            ram_wr          <= 1'b1;
        end
    end

    /* load operations */
    always @(*) begin
        if (rSTAL && (ram_data !== 32'hx)) begin
            case (func3_ram)
                3'h0: alu_out_ram = ram_data_byte_wr;           /* store byte */
                3'h1: alu_out_ram = ram_data_half_wr;           /* store half */
                3'h2: alu_out_ram = ram_data_word_wr;           /* store word */

                default: alu_out_ram = 32'hx;
            endcase
            ram_addr <= ram_address_ram >> 2;
            // $display("oRAM_DATA: 0x%x, alu_out_ram: 0x%x, oRAM_ADDR_RAM: 0x%x", oRAM_DATA, alu_out_ram, oRAM_ADDR_RAM);
        end
    end

endmodule
