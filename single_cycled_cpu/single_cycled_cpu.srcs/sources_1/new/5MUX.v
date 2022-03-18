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


module 5MUX(
    input control,
    input [5:0] A,
    input [5:0] B,
    output [5:0] C
    );
    wire [5:0] C;
    assign C = (control == 0) ? A : B;
endmodule
