`include "opcodes.v"
module control_path(reset_n,clk,opcode,funct, RegDst,RegWrite,ALUSrcA,ALUSrcB,PCSource,IRWrite,MemtoReg,MemWrite,MemRead,IorD,ALUOp,isWWD,isHalt,isComplete,PCwrite,PCwriteCond);
    input [3:0] opcode; //opcode, instruction[15:12]
    input [5:0] funct; //funct, instruction[5:0]
    input reset_n;
    input clk;
    output [1:0]RegDst; // MuxBeforeRF-0: rt | 1: rd
    output RegWrite;
    output ALUSrcA;
    output [2:0] ALUSrcB;
    output [1:0] PCSource;
    output IRWrite;
    output [1:0] MemtoReg;
    output MemWrite;
    output MemRead;
    output IorD;
    output [3:0] ALUOp; // opcode for ALU
    output isWWD; //to know current inst is WWD
    output isHalt;
    output isComplete;
    output PCwrite; //for pc write control
    output PCwriteCond;
    /////////////////////////////////////////////////////////////////////////////
    //About state_machine
    wire [2:0] stage;
    state_machine sm(
                      .opcode(opcode),
                      .funct(funct),
                      .reset_n(reset_n),
                      .clk(clk),
                      .stage(stage)
                  );
    /////////////////////////////////////////////////////////////////////////////
    //About ROM
    ROM r(
            .opcode(opcode),
            .funct(funct),
            .stage(stage),
            .RegDst(RegDst),
            .RegWrite(RegWrite),
            .ALUSrcA(ALUSrcA),
            .ALUSrcB(ALUSrcB),
            .PCSource(PCSource),
            .IRWrite(IRWrite),
            .MemtoReg(MemtoReg),
            .MemWrite(MemWrite),
            .MemRead(MemRead),
            .IorD(IorD),
            .ALUOp(ALUOp),
            .isWWD(isWWD),
            .isHalt(isHalt),
            .isComplete(isComplete),
            .PCwrite(PCwrite),
            .PCwriteCond(PCwriteCond)
        );


endmodule
