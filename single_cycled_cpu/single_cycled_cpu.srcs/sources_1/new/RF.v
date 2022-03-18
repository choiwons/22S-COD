`timescale 100ps / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2022/03/15 12:28:06
// Design Name:
// Module Name: RF
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


module RF(
    input RegWrite,
    input clk,
    input reset_n,
    input [5:0] addr1,
    input [5:0] addr2,
    input [5:0] addr3,
    output [31:0] data1,
    output [31:0] data2,
    input [31:0] data3
    );
    reg [31:0] register [31:0];
    reg [31:0] data1;
    reg [31:0] data2;
    integer i;
    always @(posedge clk) begin
        data1<=register[addr1];
        data2<=register[addr2];
        if(RegWrite == 1) begin
            register[addr3]= data3;
        end
        if(reset_n==0) begin
            for( i = 0 ; i < 32 ; i = i + 1) begin
                register [i] <= 0;
            end
        end
    end
endmodule
