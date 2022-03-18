`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/16 12:58:31
// Design Name: 
// Module Name: ALUControl
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

`define OP_ADD 4'b0000
`define OP_SUB 4'b0001
//  Bitwise Boolean operation
`define OP_ID 4'b0010
`define OP_NAND 4'b0011
`define OP_NOR 4'b0100
`define OP_XNOR 4'b0101
`define OP_NOT 4'b0110
`define OP_AND 4'b0111
`define OP_OR 4'b1000
`define OP_XOR 4'b1001
// Shifting
`define OP_LRS 4'b1010
`define OP_ARS 4'b1011
`define OP_RR 4'b1100
`define OP_LLS 4'b1101
`define OP_ALS 4'b1110
`define OP_RL 4'b1111
// Instruction
`define INST_R
`define INST_LW
`define INST_SW
`define INST_I
`define INST_J
`define INST_CB
module ALUControl(
    input reset_n,
    input clk,
    input [6:0] ALUOp,
    input [5:0] inst,
    output [3:0] ALUoperation
    );
    reg [3:0] ALUoperation;
    always @(posedge clk) begin
        case(ALUOp) begin
            `INST_R : begin
                case(inst) begin
                    
                end
            end
            `INST_I : begin
                ALUoperation = `OP_ADD;
            end
            `INST_LW :
                ALUoperation = `OP_ADD;
            `INST_SW : 
                ALUoperation = `OP_ADD;
            `INST_J :
                ALUoperation = `OP_ADD;
            `INST_CB :
                ALUoperation = `OP_SUB;
        end
    end
endmodule
