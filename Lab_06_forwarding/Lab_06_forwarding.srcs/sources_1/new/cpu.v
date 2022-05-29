`timescale 1ns/1ns
`define WORD_SIZE 16    // data and address word size

`include "opcodes.v"

module cpu(
        input Clk,
        input Reset_N,

        // Instruction memory interface
        output i_readM,
        output i_writeM,
        output [`WORD_SIZE-1:0] i_address,
        inout [`WORD_SIZE-1:0] i_data,

        // Data memory interface
        output d_readM,
        output d_writeM,
        output [`WORD_SIZE-1:0] d_address,
        inout [`WORD_SIZE-1:0] d_data,

        output [`WORD_SIZE-1:0] num_inst,
        output [`WORD_SIZE-1:0] output_port,
        output is_halted
    );

    // TODO : Implement your multi-cycle CPU!
    wire [1:0] RegDst;
    wire RegWrite;
    wire [1:0]ALUSrc;
    wire [1:0] MemtoReg;
    wire [3:0] ALUOp;
    wire Branch;
    wire Jump;
    wire use_rs;
    wire use_rt;
    wire isWWD;
    wire isComplete;
    wire MemWrite;
    wire MemRead;
    wire PCSrc;
    wire isHalt;
    wire isJAL;
    wire [`WORD_SIZE-1:0] inst;
    assign i_readM =1;
    assign i_writeM = 0;
    control_path cp(
                     .reset_n(Reset_N),
                     .clk(Clk),
                     .opcode(inst[15:12]),
                     .funct(inst[5:0]),
                     .RegDst(RegDst),
                     .RegWrite(RegWrite),
                     .ALUSrc(ALUSrc),
                     .Branch(Branch),
                     .Jump(Jump),
                     .MemtoReg(MemtoReg),
                     .MemWrite(MemWrite),
                     .MemRead(MemRead),
                     .ALUOp(ALUOp),
                     .isWWD(isWWD),
                     .isHalt(isHalt),
                     .isComplete(isComplete),
                     .use_rs(use_rs),
                     .PCSrc(PCSrc),
                     .use_rt(use_rt)
                 );
    data_path dp(
                  .reset_n(Reset_N),
                  .instruction(inst),
                  .clk(Clk),
                  .i_data(i_data),
                  .d_data(d_data),
                  .RegDst(RegDst),
                  .RegWrite(RegWrite),
                  .ALUSrc(ALUSrc),
                  .Branch(Branch),
                  .Jump(Jump),
                  .MemtoReg(MemtoReg),
                  .MemWrite(MemWrite),
                  .MemRead(MemRead),
                  .ALUOp(ALUOp),
                  .isWWD(isWWD),
                  .isHalt(isHalt),
                  .isComplete(isComplete),
                  .PCSrc(PCSrc),
                  .use_rs(use_rs),
                  .use_rt(use_rt),
                  .d_readM(d_readM),
                  .d_writeM(d_writeM),
                  .i_address(i_address),
                  .d_address(d_address),
                  .num_inst(num_inst),
                  .output_port(output_port),
                  .is_halted(is_halted)
              );
endmodule
