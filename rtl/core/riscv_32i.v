`include "rtl/core/register_file.v"
`include "rtl/core/alu/alu.v"
`include "rtl/soc/ram/ram_mux.v"

module riscv_32i (
    input               iRST, iCLK, iSEL, WR_DONE,

    /* rom */
    output              oROM_CE, oROM_RD, 
    output              oROM_READ,
    output  reg [31:0]  oROM_ADDR,
    input               iROM_VALID,
    input       [31:0]  iROM_DATA,

    /* ram */
    output              oRAM_CE, oRAM_RD, oRAM_WR,
    output      [31:0]  oRAM_DATA, oRAM_ADDR, oRAM_ADDR_RAM,
    input       [31:0]  iRAM_DATA,
    input               iRAM_VALID,

    input           iIDDLE
);

    integer i;
    reg             RAM, NEXT_PC;

    reg     [7:0]   PC, iRAM_ADDR;

    /* register file */
    wire    [4:0]   RD, RD_RAM, RS1, RS2;
    wire    [31:0]  ALU_IN1, ALU_IN2, ALU_OUT;

    /* branch */
    wire    [31:0]  BR_B, BR_J, BR_I;

    /* rom */
    wire    [31:0]  iROM_DATA, IR, BR;
    wire    [6:0]   OPCODE;

    /* ram */
    reg     [31:0]  IR_RAM;
    wire            RAM_DONE;

    assign oROM_CE      = 1;
    assign oROM_RD      = 1;
    assign oROM_READ    = iIDDLE || NEXT_PC;

    assign OPCODE       = iROM_DATA[6:0];
    assign IR           = iROM_DATA;

    /* ram */
    reg     [31:0]  RAM_DATA;
    wire    [31:0]  ALU_RAM_DATA;
    wire            RAM_CE_I, RAM_RD_I, RAM_WR_I;       /* instrucion i */
    wire    [31:0]  RAM_DATA_WR_I, RAM_DATA_RD_I;
    wire    [31:0]  RAM_ADDR_I, oRAM_ADDR_I;
    wire            RAM_CE_S, RAM_RD_S, RAM_WR_S;       /* instrucion s */
    wire    [31:0]  RAM_DATA_WR_S, RAM_DATA_RD_S;
    wire    [31:0]  RAM_ADDR_S, RAM_ADDR_S_RAM, oRAM_ADDR_S;

    /* instance */
    register_file reg_file (
        .iCLK(iCLK), .iRST(iRST), .iRAM_READ(oRAM_RD),

        .iRD(RD), .iRD_RAM(RD_RAM), .iRS1(RS1), .iRS2(RS2),
        .oALU_IN1(ALU_IN1), .oALU_IN2(ALU_IN2), .iALU_OUT(ALU_OUT),

        .iRAM_DONE(RAM_DONE || WR_DONE), .iROM_VALID(iROM_VALID),
        .iALU_RAM_DATA(ALU_RAM_DATA)
    );
        
    alu alu (
        .iCLK(iCLK), .iRST(iRST), .OPCODE(OPCODE), .IR(iROM_DATA),

        .ALU_IN1(ALU_IN1), .ALU_IN2(ALU_IN2), .PC(PC),
        .ALU_OUT(ALU_OUT), .BR_B(BR_B), .BR_J(BR_J), .BR_I(BR_I),

        .RD(RD), .oRD_RAM(RD_RAM), .RS1(RS1), .RS2(RS2),

        .RAM_CE_I(RAM_CE_I), .RAM_RD_I(RAM_RD_I), .RAM_WR_I(RAM_WR_I),
        .RAM_ADDR_I(RAM_ADDR_I), .RAM_DATA_WR_I(RAM_DATA_WR_I),

        .RAM_CE_S(RAM_CE_S), .RAM_RD_S(RAM_RD_S), .RAM_WR_S(RAM_WR_S),
        .RAM_ADDR_S(RAM_ADDR_S), .RAM_ADDR_S_RAM(RAM_ADDR_S_RAM), .RAM_DATA_WR_S(RAM_DATA_WR_S),

        .RAM_DATA_RD_I(RAM_DATA_RD_I), .RAM_DATA_RD_S(RAM_DATA_RD_S),
        .RAM_DONE(RAM_DONE), .oALU_RAM_DATA(ALU_RAM_DATA), .oRAM_DATA(oRAM_DATA)
    );

    ram_mux ram_mux (
        .OPCODE(OPCODE), .OPC(IR_RAM[6:0]),

        .iRAM_CE_I(RAM_CE_I), .iRAM_RD_I(RAM_RD_I), .iRAM_WR_I(RAM_WR_I),
        .iRAM_ADDR_I(RAM_ADDR_I), .iRAM_DATA_WR_I(RAM_DATA_WR_I),
        .oRAM_DATA_RD_I(RAM_DATA_RD_I),

        .iRAM_CE_S(RAM_CE_S), .iRAM_RD_S(RAM_RD_S), .iRAM_WR_S(RAM_WR_S),
        .iRAM_ADDR_S(RAM_ADDR_S), .iRAM_ADDR_S_RAM(RAM_ADDR_S_RAM), .iRAM_DATA_WR_S(RAM_DATA_WR_S),
        .oRAM_DATA_RD_S(RAM_DATA_RD_S),

        .oRAM_CE(oRAM_CE), .oRAM_RD(oRAM_RD), .oRAM_WR(oRAM_WR),
        .oRAM_ADDR(oRAM_ADDR), .oRAM_ADDR_RAM(oRAM_ADDR_RAM), .oRAM_DATA_WR(oRAM_DATA),
        
        .iRAM_DATA_RD(RAM_DATA)
    );


    /* logic */
	initial begin
		i           = 0;
        PC          = 0;
        NEXT_PC     = 0;        
	end

    always @(posedge iCLK or negedge iRST) begin
        if (!iRST) begin
            PC          <= 8'b0;
            NEXT_PC     <= 1'b0;
            i           <= 0;
        end else begin
            if (iROM_VALID && !oRAM_RD) begin
                $display("\n ~ CLOCK: %0d", i);

                case (OPCODE)
                    7'b0110011:                         $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: R", PC, IR, OPCODE);      
                    7'b0010011, 7'b0000011, 7'b1100111: $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: I", PC, IR, OPCODE);
                    7'b0100011:                         $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: S", PC, IR, OPCODE);
                    7'b0110111, 7'b0010111:             $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: U", PC, IR, OPCODE);
                    7'b1100011:                         $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: B", PC, IR, OPCODE);
                    7'b1101111:                         $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: J", PC, IR, OPCODE);
                endcase

                PC <= (OPCODE == 7'b1100011) ? (BR_B) : 
                      (OPCODE == 7'b1101111) ? (BR_J) :
                      (OPCODE == 7'b1100111) ? (BR_I) :
                      PC + 4;
            end

            if ((OPCODE == 7'b0000011) || (OPCODE == 7'b0100011)) begin
                IR_RAM          <= IR;
            end

            if (RAM_DONE || WR_DONE) begin
                $display("\n ~ CLOCK: %0d", i);

                case (IR_RAM[6:0])
                    7'b0000011:                         $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: I", PC, IR_RAM, IR_RAM[6:0]);
                    7'b0100011:                         $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: S", PC, IR_RAM, IR_RAM[6:0]);
                endcase

                PC              <= PC + 4;
                IR_RAM          <= 7'hx;
                NEXT_PC         <= 1'b1;
            end else begin
                NEXT_PC         <= 1'b0;
            end
        end

        i <= i + 1;

        if (oROM_READ) begin
            oROM_ADDR           <= (PC >> 2);
        end
    end

    always @(*) begin
        if (oRAM_RD) begin
            RAM                 <= 1'b1;
        end else if (RAM) begin
            if(iRAM_DATA !== 32'hx) begin
                RAM_DATA        <= iRAM_DATA; 
                RAM             <= 1'b0;
            end
        end 
        else RAM_DATA       <= 32'hx;
    end

endmodule
