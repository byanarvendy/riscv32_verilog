module memory_ram (
	input			iCLK,
    input           iRAM_CE, iRAM_RD, iRAM_WR,
	input   [31:0]  iRAM_ADDR, iRAM_DATA,
    output  [31:0]  oRAM_DATA
	);

	reg [31:0] mem [0:255];

	assign oRAM_DATA = (iRAM_CE && iRAM_RD) ? mem[iRAM_ADDR] : 32'h00000000;

	initial begin
		$readmemh("rtl/soc/ram/memory_ram_init.hex", mem, 0, 255);
	end

	always @(posedge iCLK) begin
		if (iRAM_WR) begin
			mem[iRAM_ADDR] = iRAM_DATA;
			// $display("mem[0x%x] = 0x%x", iRAM_ADDR, iRAM_DATA);
		end
	end

endmodule
