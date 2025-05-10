module memory_rom (
	output	[31:0]	oROM_DATA,
	input			iROM_CE,
	input			iROM_RD,
	input	[31:0]	iROM_ADDR	
);

	reg [31:0] mem [0:255];

	assign oROM_DATA = (iROM_CE && iROM_RD) ? mem[iROM_ADDR] : 32'h00000000;

	initial begin
		$readmemh("rtl/soc/rom/memory_rom_init.hex", mem, 0, 52);
	end

endmodule