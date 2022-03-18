`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/16 12:03:27
// Design Name: 
// Module Name: Control
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
`define INST_R
`define INST_LW
`define INST_SW
`define INST_I
`define INST_J
`define INST_CB


module Control(
    input [6:0] inst,
    output RegDst,
    output Jump,
    output Branch,
    output MemRead,
    output MemtoReg,
    output ALUOp,
    output MemWrite,
    output ALUSrc,
    output RegWrite,
    input clk,
    input reset_n
    );
    reg RegDst;
    reg Jump;
    reg Branch;
    reg MemRead;
    reg MemtoReg;
    reg ALUOp;
    reg MemWrite;
    reg ALUSrc;
    reg RegWrite;

    always @(posedge clk) begin
        case(inst) begin
            `INST_R : begin
                RegDst = 1;
                Jump = 0;
                Branch=0;
                MemRead=0;
                MemtoReg=0;
                ALUOp=1;
                MemWrite=0;
                ALUSrc = 0;
                RegWrite = 1;
            end
            `INST_I : begin
                RegDst = 0;
                Jump = 0;
                Branch=0;
                MemRead=0;
                MemtoReg=0;
                ALUOp=1;
                MemWrite=0;
                ALUSrc = 1;
                RegWrite = 1;
            end
            `INST_LW : begin
                RegDst = 0;
                Jump = 0;
                Branch=0;
                MemRead=1;
                MemtoReg=1;
                ALUOp=1;
                MemWrite=0;
                ALUSrc = 1;
                RegWrite = 1;
              
            end
            `INST_SW : begin
                RegDst = 0;
                Jump = 0;
                Branch=0;
                MemRead=0;
                MemtoReg=0;
                ALUOp = 1;
                MemWrite = 1;
                ALUSrc = 1;
                RegWrite = 0;
                
            end
            `INST_J : begin
                RegDst = 0;
                Jump = 1;
                Branch=0;
                MemRead=0;
                MemtoReg=0;
                ALUOp=0;
                MemWrite=0;
                ALUSrc = 0;
                RegWrite = 0;
            end
            `INST_CB : begin
                RegDst = 0;
                Jump = 0;
                Branch = 1;
                MemRead=0;
                MemtoReg=0;
                ALUOp=1;
                MemWrite=0;
                ALUSrc = 0;
                RegWrite = 0;
            end
        end
    end
endmodule
