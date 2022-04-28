`timescale 1ns/100ps

`include "opcodes.v"
`include "constants.v"

module cpu (
        output readM, // read from memory
        output writeM, // write to memory
        output [`WORD_SIZE-1:0] address, // current address for data
        inout [`WORD_SIZE-1:0] data, // data being input or output
        input inputReady, // indicates that data is ready from the input port
        input reset_n, // active-low RESET signal
        input clk, // clock signal

        // for debuging/testing purpose
        output [`WORD_SIZE-1:0] num_inst, // number of instruction during execution
        output [`WORD_SIZE-1:0] output_port, // this will be used for a "WWD" instruction
        output is_halted // 1 if the cpu is halted
    );
    wire [1:0] RegDst;
    wire RegWrite;
    wire ALUSrcA;
    wire [2:0]ALUSrcB;
    wire [1:0]PCSource;
    wire IRWrite;
    wire [1:0] MemtoReg;
    wire MemWrite;
    wire MemRead;
    wire IorD ;
    wire [3:0] ALUOp;
    wire isWWD;
    wire isHalt;
    wire isComplete;
    wire PCwrite;
    wire PCwriteCond;
    wire [`WORD_SIZE-1:0] inst;

    control_path cp(
                     .reset_n(reset_n),
                     .clk(clk),
                     .opcode(inst[15:12]),
                     .funct(inst[5:0]),
                     .RegDst(RegDst),
                     .RegWrite(RegWrite),
                     .ALUSrcA(ALUSrcA),
                     .ALUSrcB(ALUSrcB),
                     .PCSource(PCSource),
                     .IRWrite(IRWrite),
                     .MemtoReg(MemtoReg),
                     .MemWrite(writeM),
                     .MemRead(readM),
                     .IorD(IorD),
                     .ALUOp(ALUOp),
                     .isWWD(isWWD),
                     .isHalt(is_halted),
                     .isComplete(isComplete),
                     .PCwrite(PCwrite),
                     .PCwriteCond(PCwriteCond)
                 );
    data_path dp(
                  .reset_n(reset_n),
                  .instruction(inst),
                  .clk(clk),
                  .data(data),
                  .address(address),
                  .inputReady(inputReady),
                  .num_inst(num_inst),
                  .output_port(output_port),
                  .RegDst(RegDst),
                  .RegWrite(RegWrite),
                  .ALUSrcA(ALUSrcA),
                  .ALUSrcB(ALUSrcB),
                  .PCSource(PCSource),
                  .IRWrite(IRWrite),
                  .MemtoReg(MemtoReg),
                  .MemWrite(writeM),
                  .IorD(IorD),
                  .ALUOp(ALUOp),
                  .isWWD(isWWD),
                  .isComplete(isComplete),
                  .PCwrite(PCwrite),
                  .PCwriteCond(PCwriteCond)
              );
endmodule
