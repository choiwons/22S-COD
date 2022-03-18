`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/16 13:09:41
// Design Name: 
// Module Name: MUX
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


module 32MUX(
    input control,
    input [31:0] A,
    input [31:0] B,
    output [31:0] out
    );
    wire [31:0] out;
    assign out = (control == 0) ? A : B;
endmodule
