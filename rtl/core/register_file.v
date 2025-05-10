module register_file (
    input           iCLK, iRST,
    input           iROM_VALID, iRAM_READ, iRAM_DONE,
    input   [4:0]   iRD, iRD_RAM, iRS1, iRS2,
    input   [31:0]  iALU_OUT, iALU_RAM_DATA,
    output  [31:0]  oALU_IN1, oALU_IN2
);

    integer i;

    reg [31:0] regfile [0:31];

    assign oALU_IN1 = regfile[iRS1];
    assign oALU_IN2 = regfile[iRS2];

    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            regfile[i] = i;
        end
    end

    always @(posedge iCLK or negedge iRST) begin
        if (!iRST) begin
            for (i = 0; i < 32; i = i + 1) begin
                regfile[i] = i;
            end
            
            $display("\n === INITIAL REGISTER VALUE === ");
            for (i = 0; i < 32; i = i + 8) begin
                $display("#REG: [0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x]", regfile[i+0], regfile[i+1], regfile[i+2], regfile[i+3], regfile[i+4], regfile[i+5], regfile[i+6], regfile[i+7]);
            end
        end

        if ((iROM_VALID && !iRAM_READ) || iRAM_DONE) begin
            if (!iRAM_READ && iRD != 5'b00000) begin
                regfile[iRD] = iALU_OUT;
            end 
            else if (iRAM_DONE && iRD_RAM != 5'b00000) begin
                regfile[iRD_RAM] = iALU_RAM_DATA;
            end

            #1; 
                $display("#REGISTERS:");
                for (i = 0; i < 32; i = i + 8) begin
                    $display("#REG: [0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x]", regfile[i+0], regfile[i+1], regfile[i+2], regfile[i+3], regfile[i+4], regfile[i+5], regfile[i+6], regfile[i+7]);
                end

        end
       
    end

endmodule