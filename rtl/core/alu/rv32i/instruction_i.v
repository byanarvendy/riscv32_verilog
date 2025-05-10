module instruction_i (
    input           iCLK, iRST,
    input   [7:0]   iPC,
    input   [31:0]  iIR, iREG_OUT1, iREG_OUT2,

    input   [31:0]  iRAM_DATA,
    output          oRAM_CE, oRAM_RD, oRAM_WR,
    output  [31:0]  oRAM_ADDR, oALU_RAM_DATA,

    output          RAM_DONE,
    output  [4:0]   oRD, oRD_RAM, oRS1, oRS2,
    output  [31:0]  oREG_IN, oPC
);

    reg             rSTAL;
    reg     [2:0]   func3_ram;
    reg     [4:0]   RD_RAM;
    reg     [31:0]  ram_address, alu_out_ram;

    wire    [2:0]   func3;
    wire    [6:0]   opcode;
    wire    [11:0]  imm;

    wire    [31:0]  alu_in1, alu_in2, alu_out;
    wire    [31:0]  ram_data;
    wire    [7:0]   ram_data_byte;
    wire    [15:0]  ram_data_half;

    assign opcode           = iIR[6:0];
    assign oRD              = (rSTAL) ? oRD_RAM : iIR[11:7];
    assign oRS1             = iIR[19:15];
    assign oRS2             = 5'h00;
    assign imm              = iIR[31:20];
    assign func3            = iIR[14:12];

    assign alu_in1          = iREG_OUT1;
    assign alu_in2          = imm;

    /* ram */
    assign oRAM_ADDR        = (alu_in1 + alu_in2) >> 2;
    assign ram_data         = iRAM_DATA;
    assign oRD_RAM          = RD_RAM;
    assign oALU_RAM_DATA    = alu_out_ram;

    assign ram_data_byte    = (ram_address[1:0] == 2'b00) ? ram_data[7:0]   :
                              (ram_address[1:0] == 2'b01) ? ram_data[15:8]  :
                              (ram_address[1:0] == 2'b10) ? ram_data[23:16] :
                              (ram_address[1:0] == 2'b11) ? ram_data[31:24] :
                              8'h00;

    assign ram_data_half    = (ram_address[1] == 1'b0) ? ram_data[15:0]  :
                              (ram_address[1] == 1'b1) ? ram_data[31:16] :
                              16'h0000;

    assign alu_out  = (opcode == 7'b0010011) ?                                                   /* I1: immediate operations */
                        ((func3 == 3'h0) ? alu_in1 + alu_in2                                    :       /* add immediate */
                         (func3 == 3'h4) ? alu_in1 ^ alu_in2                                    :       /* xor immediate */
                         (func3 == 3'h6) ? alu_in1 | alu_in2                                    :       /* or immediate */
                         (func3 == 3'h7) ? alu_in1 & alu_in2                                    :       /* and immediate */
                         (func3 == 3'h1) ? alu_in1 << alu_in2[4:0]                              :       /* shift left logical immediate */
                         (func3 == 3'h5 && alu_in2[11:5] == 7'h00) ? alu_in1 >> alu_in2[4:0]    :       /* shift right logical */
                         (func3 == 3'h5 && alu_in2[11:5] == 7'h20) ? alu_in1 >>> alu_in2[4:0]   :       /* shift right arithmetic */
                         (func3 == 3'h2) ? ($signed(alu_in1) < $signed(alu_in2[4:0]) ? 1 : 0)   :       /* set less than, signed */
                         (func3 == 3'h3) ? (alu_in1 < alu_in2[4:0] ? 1 : 0)                     :       /* set less than, unsigned */
                         32'h00000000) :

                    //   ((opcode == 7'b0000011)) ?                                                   /* I2: load operations */
                    //     ((func3_ram == 3'h0) ? $signed(ram_data_byte)                               :       /* load byte */
                    //      (func3_ram == 3'h1) ? $signed(ram_data_half)                               :       /* load half */
                    //      (func3_ram == 3'h2) ? ram_data                                             :       /* load word */
                    //      (func3_ram == 3'h4) ? ram_data_byte                                        :       /* load byte (unsigned) */
                    //      (func3_ram == 3'h5) ? ram_data_half                                        :       /* load half (unsigned) */
                    //      32'h00000000) :

                     (opcode == 7'b1100111) ?                                                   /* I3: jump and link register */
                        ((func3 == 3'h0) ? alu_in1 + alu_in2 : 32'h00000000) :
                         32'h00000000;

    assign oREG_IN  = (opcode == 7'b1100111 && func3 == 3'h0) ? iPC + 4 : alu_out;
    assign oPC      = (opcode == 7'b1100111 && func3 == 3'h0) ? alu_in1 + alu_in2 : 32'h00000000;

    assign oRAM_CE  = (opcode == 7'b0000011) ? 1'b1 : 1'b0;
    assign oRAM_RD  = (opcode == 7'b0000011) ? 1'b1 : 1'b0;

    assign RAM_DONE = (alu_out_ram !== 32'hx) ? 1'b1 : 1'b0;

    /* ram */
    always @(posedge iCLK or negedge iRST) begin
        if (!iRST) begin
            rSTAL           <= 1'b0;
        end

        if ((opcode == 7'b0000011)) begin
            ram_address     <= alu_in1 + alu_in2;
            rSTAL           <= 1'b1;
            func3_ram       <= func3;
            RD_RAM          <= oRD;
        end 
        else if (alu_out_ram !== 32'hx) begin
            ram_address     <= 32'hx;
            rSTAL           <= 1'b0;
            func3_ram       <= 3'hx;
            RD_RAM          <= 5'hx;
            alu_out_ram     <= 32'hx;
        end
    end

    /* I2: load operations */
    always @(*) begin
        if (rSTAL && (ram_data !== 32'hx)) begin
            case (func3_ram)
                3'h0: alu_out_ram = $signed(ram_data_byte);     /* load byte */
                3'h1: alu_out_ram = $signed(ram_data_half);     /* load half */
                3'h2: alu_out_ram = ram_data;                   /* load word */
                3'h4: alu_out_ram = ram_data_byte;              /* load byte (unsigned) */
                3'h5: alu_out_ram = ram_data_half;              /* load half (unsigned) */

                default: alu_out_ram = 32'hx;
            endcase
        end
    end

endmodule
