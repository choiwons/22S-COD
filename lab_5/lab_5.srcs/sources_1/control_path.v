`include "opcodes.v"
module control_path(reset_n,clk,opcode,funct, RegDst,RegWrite,ALUSrcA,ALUSrcB,PCSource,IRWrite,MemtoReg,MemWrite,MemRead,IorD,ALUOp,isWWD,isHalt,isComplete,PCwrite,PCwriteCond);
    input [3:0] opcode; //opcode, instruction[15:12]
    input [5:0] funct; //funct, instruction[5:0]
    input reset_n;
    input clk;
    output [1:0]RegDst; // MuxBeforeRF-0: rt | 1: rd
    output RegWrite; //RF enable
    output ALUSrcA; //first input to ALU | 0:PC | 1:buffer_A
    output [2:0] ALUSrcB; //0:buffer_B | 1:1 | 2:imm<<8 | 3:signExtendedImm | 4:ZeroExtendedImm
    output [1:0] PCSource; //mux for choose input to PC| 0:ALUresult |1:ALUout
    output IRWrite; //control for IR to latch data
    output [1:0] MemtoReg; //mux control bit to RF write data
    output MemWrite; //write enable bit
    output MemRead; //read enable bit
    output IorD; //choose between PC and ALUOut
    output [3:0] ALUOp; //opcode for ALU
    output isWWD; //to know current inst is WWD
    output isHalt; // for HLT
    output isComplete;//for update num_inst
    output PCwrite; //for pc write control
    output PCwriteCond;//for branch inst
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
