
module ram_mux (
    input   [6:0]   OPCODE, OPC,

	input 			iRAM_CE_I, iRAM_RD_I, iRAM_WR_I,
	input 	[31:0]	iRAM_ADDR_I,  iRAM_DATA_WR_I,
	output	[31:0]	oRAM_DATA_RD_I,

	input 			iRAM_CE_S, iRAM_RD_S, iRAM_WR_S,
	input 	[31:0]	iRAM_ADDR_S, iRAM_ADDR_S_RAM, iRAM_DATA_WR_S,
	output	[31:0]	oRAM_DATA_RD_S,

	input	[31:0]	iRAM_DATA_RD,
	output			oRAM_CE, oRAM_RD, oRAM_WR,
	output	[31:0]	oRAM_ADDR, oRAM_ADDR_RAM, oRAM_DATA_WR
);

	wire 	[31:0] RAM_DATA;

	assign RAM_DATA			= (oRAM_RD === 1'bx) ? 32'hx 			   : iRAM_DATA_RD;

	assign oRAM_CE 			= (OPCODE == 7'b0000011) ? iRAM_CE_I       :
					          (OPCODE == 7'b0100011) ? iRAM_CE_S       :
					   		  1'b0;     
     
	assign oRAM_RD 			= (OPCODE == 7'b0000011) ? iRAM_RD_I       :
					          (OPCODE == 7'b0100011) ? iRAM_RD_S       :
					   		  1'b0;     
							        
	assign oRAM_WR 			= iRAM_WR_S;             /* =========== !!! =========== */
   
	assign oRAM_ADDR 		= (OPCODE == 7'b0000011) ? iRAM_ADDR_I     :
					          (OPCODE == 7'b0100011) ? iRAM_ADDR_S     :
							  (  OPC  == 7'b0100011) ? iRAM_ADDR_S_RAM :
							  32'hx;

	assign oRAM_ADDR_RAM	= (  OPC  == 7'b0100011) ? iRAM_ADDR_S_RAM : 32'hx;
	
	assign oRAM_DATA_WR 	= (  OPC  == 7'b0100011) ? iRAM_DATA_WR_S  : 32'h0;
	
	assign oRAM_DATA_RD_I	= (  OPC  == 7'b0000011) ? iRAM_DATA_RD    : 32'hx;
	assign oRAM_DATA_RD_S	= (  OPC  == 7'b0100011) ? iRAM_DATA_RD    : 32'hx;

endmodule


