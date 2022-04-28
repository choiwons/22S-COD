`include "opcodes.v"
module data_path(clk,reset_n,RegDst,RegWrite,ALUSrcA,ALUSrcB,PCSource,IRWrite,MemtoReg,MemWrite,IorD,ALUOp,isWWD,isComplete, PCwrite,PCwriteCond,data,inputReady,instruction,num_inst,address,output_port);
    input clk;
    input reset_n;
    ///>>
    input [1:0] RegDst;
    input RegWrite;
    input ALUSrcA;
    input [2:0]ALUSrcB;
    input [1:0]PCSource;
    input IRWrite;
    input [1:0] MemtoReg;
    input MemWrite;
    input IorD;
    input [3:0] ALUOp;
    input isWWD;
    input isComplete;
    input PCwrite;
    input PCwriteCond;
    inout [16:0] data;
    input inputReady;
    //<<refer to control path
    output [`WORD_SIZE-1:0] instruction;
    output reg [`WORD_SIZE-1:0] num_inst;
    output [`WORD_SIZE-1:0] address;
    output reg [`WORD_SIZE-1:0] output_port;
    /////////////////////////////////////////
    //Memory write
    wire [`WORD_SIZE-1:0] IorD_Mux;
    assign IorD_Mux = (IorD) ? ALUOut : PC;
    assign data = (MemWrite) ? buffer_B : 16'bz;
    assign address = IorD_Mux;
    /////////////////////////////////////////
    //About IR
    //latch data when posedge inputReady
    reg [`WORD_SIZE-1:0] IR;
    assign instruction = IR;
    always @(negedge reset_n or posedge inputReady) begin
        if(!reset_n) begin
            IR <= 0;
        end
        else begin
            if(IRWrite)
                IR <=data;
        end
    end
    /////////////////////////////////////////
    //About MDR
    //latch data when posedge inputReady
    reg [`WORD_SIZE-1:0] MDR;
    always @(negedge reset_n or posedge inputReady) begin
        if(!reset_n) begin
            MDR <= 0;
        end
        else begin
            MDR <=data;
        end
    end
    //////////////////////////////////////////
    //About RF
    wire [1:0] RegDst_Mux;
    wire [1:0] rs;
    wire [1:0] rt;
    wire [1:0] rd;
    wire [7:0] imm;
    wire [`WORD_SIZE-1:0] buffer_A;
    wire [`WORD_SIZE-1:0] buffer_B;
    wire [`WORD_SIZE-1:0] MemtoReg_Mux;
    assign imm = instruction[7:0];
    assign rs = instruction[11:10];
    assign rt = instruction[9:8];
    assign rd = instruction[7:6];
    assign RegDst_Mux = (RegDst==2'd0) ? rt :
           (RegDst == 2'd1)? rd : 2 ;
    //mux for RF write register
    assign MemtoReg_Mux = (MemtoReg==2'd0) ? resultOfALU :
           (MemtoReg==2'd1) ? MDR :
           (MemtoReg==2'd2) ? ALUOut :
           PC; //(MemtoReg==2'd3)
    // mux for choosing data to write
    RF rf(
           .RegWrite(RegWrite),
           .reset_n(reset_n),
           .clk(clk),
           .addr1(rs),
           .addr2(rt),
           .addr3(RegDst_Mux),
           .data1(buffer_A),
           .data2(buffer_B),
           .data3(MemtoReg_Mux)
       );
    ///////////////////////////////////////////
    //About ALU
    reg [`WORD_SIZE-1:0] ALUOut;
    reg BranchCond;
    wire [`WORD_SIZE-1:0] resultOfALU;
    wire [`WORD_SIZE-1:0] SignExtendedImm;
    wire [`WORD_SIZE-1:0] ZeroExtendedImm;
    wire [`WORD_SIZE-1:0] ALUSrcA_Mux;
    wire [`WORD_SIZE-1:0] ALUSrcB_Mux;
    wire condout;
    wire [`WORD_SIZE-1:0] PCwire;
    assign SignExtendedImm = {{8{imm[7]}},imm};
    assign ZeroExtendedImm = {{8{1'b0}},imm};
    assign ShiftedImm = imm<<8;
    assign PCwire = PC;
    assign    ALUSrcA_Mux = (ALUSrcA) ? buffer_A : PC;  // mux for ALU second input
    assign    ALUSrcB_Mux = (ALUSrcB==3'd0) ? buffer_B :  // mux for ALU second input
              (ALUSrcB==3'd1) ? 1'b1  :
              (ALUSrcB==3'd2) ? ShiftedImm :
              (ALUSrcB==3'd3) ? SignExtendedImm :
              ZeroExtendedImm; //(ALUSrcB==2'd4)
    always @(posedge clk) begin
        ALUOut <= resultOfALU;
        BranchCond <= condout;
    end
    ALU alu(
            .A(ALUSrcA_Mux),
            .B(ALUSrcB_Mux),
            .OP(ALUOp),
            .C(resultOfALU),
            .bcond(condout)
        );
    //////////////////////////////////////////
    //About PC
    reg [`WORD_SIZE-1:0] PC;
    wire [`WORD_SIZE-1:0] PCSource_Mux;
    wire [11:0] targetAddress;
    wire PCcond;
    assign PCcond = (BranchCond & PCwriteCond);
    assign targetAddress = {PC[15:12],IR[11:0]};
    assign PCSource_Mux = (PCSource==2'd0) ? resultOfALU :
           (PCSource==2'd1) ? ALUOut:
           targetAddress;  //(PCSource==2'd2)
    always @(negedge reset_n  or posedge clk) begin //every posedge clk, if PCwrite is on, update PC.
        if(!reset_n) begin
            PC <= 0;
        end
        else if(PCwrite|PCcond)begin
            PC <= PCSource_Mux;
        end
    end
    /////////////////////////////////////////
    //About output
    //num_inst : if PCwrite is high, +1 to num_inst
    //output_port : if isWWD is high, operate output_port <- $rt
    always @(negedge reset_n or posedge clk) begin
        if(!reset_n) begin
            output_port <=0;
            num_inst <= 0;
        end
        else begin
            if(isWWD) begin
                output_port <= buffer_A;
            end
            if(isComplete) begin
                num_inst <= num_inst +1;
            end
        end
    end
endmodule
