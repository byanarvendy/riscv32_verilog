`include "rtl/core/riscv_32i.v"
`include "rtl/soc/rom/memory_rom.v"
`include "rtl/soc/ram/memory_ram.v"

module riscv_32i_tb;
    reg         iRST, iCLK;
    reg  [1:0]  iMODE;
    reg  [7:0]  iSW;

    wire        oROM_CE, oROM_RD, oRAM_CE, oRAM_RD, oRAM_WR;
    wire [31:0] iROM_DATA, oRAM_DATA, oREG32;
    wire [31:0] iRAM_DATA;
    wire [7:0]  oROM_ADDR, oRAM_ADDR;

    reg [7:0]   iROM_ADDR, iRAM_ADDR;

    reg         iROM_CE, iROM_RD;
    reg         iRAM_CE, iRAM_RD, iRAM_WR;

    integer i;

    initial begin
		iRST = 0;
		iCLK = 0;

        iROM_CE = 1;
        iROM_RD = 1;

        iRAM_CE = 1;
        iRAM_RD = 1;
        iRAM_WR = 0;

		for (i = 0; i < 10; i = i +1 ) begin
            #5 iCLK = 0;
            #5 iCLK = 1;
		end
    end

    riscv_32i u1 (
        .iRST(iRST), .iCLK(iCLK),

        .oROM_CE(oROM_CE), .oROM_RD(oROM_RD),
        .oROM_ADDR(oROM_ADDR), .iROM_DATA(iROM_DATA),

        .oRAM_CE(oRAM_CE), .oRAM_RD(oRAM_RD), .oRAM_WR(oRAM_WR),
        .iRAM_DATA(iRAM_DATA), .oRAM_ADDR(oRAM_ADDR), 
        .oRAM_DATA(oRAM_DATA)
    );

    memory_rom u2 (
        .oROM_DATA(iROM_DATA), .iROM_CE(iROM_CE),
        .iROM_RD(iROM_RD), .iROM_ADDR(oROM_ADDR)
    );
    
    memory_ram u3(
        .oRAM_DATA(iRAM_DATA), .iRAM_DATA(oRAM_DATA),

        .iRAM_CE(iRAM_CE),
        .iRAM_RD(iRAM_RD),
        .iRAM_WR(oRAM_WR),

        .iRAM_ADDR(oRAM_ADDR),

        .iRAM_CLK(iCLK),
        .iRAM_RST(iRST)
    );

endmodule
