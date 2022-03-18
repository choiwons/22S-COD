`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/16 15:47:14
// Design Name: 
// Module Name: GenJumpAddr
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


module GenJumpAddr(
    input [25:0] Inst;
    input [3:0] HeadOfPCPlusFour;
    output reg [31:0] JumpAddress
    );
    assign JumpAddress = {HeadOfPCPlusFour, Inst << 2};
endmodule
