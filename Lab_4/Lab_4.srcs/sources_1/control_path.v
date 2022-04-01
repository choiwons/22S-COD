`include "opcodes.v"
`define OPCODE inst[15:12]
`define funct inst[5:0]
module control_path(inst, control_bit);
    input [15:0] inst;
    output [13:0] control_bit;

    assign    `RegDst = (`OPCODE == `OPCODE_LHI ||`OPCODE == `OPCODE_ADI)  ? 1 : 0; //1 if rt
    assign    `Jump= (`OPCODE == `OPCODE_JMP) ? 1 : 0;
    assign    `Branch = 0;
    assign    `MemRead=0;
    assign    `MemtoReg=0;
    assign    `ALUOp = (`OPCODE == `OPCODE_ADI || (`OPCODE== `OPCODE_ADD && `funct ==0)) ? 4'b0000 : 4'b0010;
    assign    `ALUSrc = (`OPCODE == `OPCODE_ADI) ? 2'b00 :
              (`OPCODE == `OPCODE_LHI) ? 2'b01 : 2'b10;
    assign    `RegWrite = (`OPCODE == `OPCODE_LHI || `OPCODE == `OPCODE_ADI|| (`OPCODE== `OPCODE_ADD && `funct == 0)) ? 1 : 0;
    assign    `isWWD = (`funct==28) ? 1 : 0;
    assign    `PCwrite = (`OPCODE == `OPCODE_LHI ||`OPCODE == `OPCODE_JMP||`OPCODE == `OPCODE_ADD||`OPCODE==`OPCODE_ADI) ? 1 : 0;
endmodule
