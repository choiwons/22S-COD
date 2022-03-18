`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/16 12:08:54
// Design Name: 
// Module Name: single_cycled_cpu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module single_cycled_cpu(

    );
    reg [31:0] PC;
    reg clk;
    
    wire RegDst;
    
    wire Jump;
    wire Branch;
    wire MemRead;
    wire ALUOp;
    wire MemWrite;
    wire ALUSrc;
    wire RegWrite;
    wire PCplusFour;
    wire [3:0] ALUoperation;
    wire [31:0] RegData [2:0];
    wire [31:0] RegWriteData;
    wire [15:0] CB_BeforeSignExtended;
    wire [31:0] CB_AfterSignExtended;
    wire [31:0] CB_TargetPCAddress;
    wire [31:0] Instruction;
    wire [31:0] JumpAddress;
    wire [31:0] CB_TakenOrNot;
    wire [31:0] nextPC;
    wire [31:0] ALUSecondInput;
    
    SignExtend(.in(CB_BeforeSignExtended),.out(CB_AfterSignExtended));

    32ADDER(.A(PC), .B(CB_AfterSignExtended << 2), .out(CB_TargetPCAddress));
    32ADDER(.A(PC),.B(4),.out(PCplusFour));
    
    32MUX(.control(Branch), .A(PCplusFour), .B(CB_TargetPCAddress), .out(CB_TakenOrNot));
    32MUX(.control(Jump), .A(CB_TakenOrNot), .B(JumpAddress), .out(nextPC));
    32MUX(.control(ALUSrc), .A(RegData[1]), .B(CB_AfterSignExtended), .out(ALUSecondInput));

    GenJumpAddr(.Inst(Instruction[25:0], .HeadOfPCPlusFour(PCplusFour[31:28]), .JumpAddress(JumpAddress));

    control(.inst(Instruction[31:26], .RegDst(RegDst), .Jump(Jump), .Branch(Branch),
            .MemRead(MemRead), .MemtoReg(MemtoReg), .ALUOp(ALUOp), .MemWrite(MemWrite),
            .ALUSrc(ALUSrc), .RegWrite(RegWrite), .clk(clk), .reset_n(reset_n));

    32ALU(.clk(clk), .reset_n(reset_n), .A(RegData[0]), .B(ALUSecondInput), .OP(ALUoperation), .C(), .bcond());
    ALUControl(.ALUOp(ALUOp), .inst(Instruction[5:0], .ALUoperation(ALU)))

    RF(.addr1(Instruction[25:21]), .addr2(Instruction[20:16], addr3(Instruction[15:11]),
       .data1(RegData[0]), .data2(RegData[1]), .data3(RegWriteData),
       .clk(clk), .reset_n(reset_n));

    always @(posedge clk) begin
        PC <= nextPC;
    end
endmodule