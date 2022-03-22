`timescale 100ps / 100ps

module RF(write, clk, reset_n, addr1, addr2, addr3, data1, data2, data3);
    input write;
    input clk;
    input reset_n;
    input [1:0] addr1;
    input [1:0] addr2;
    input [1:0] addr3;
    output reg [15:0] data1;
    output reg [15:0] data2;
    input [15:0] data3;

    reg [15:0] register [3:0];

    always @(*) begin
        data1 = register[addr1];
        data2 = register[addr2];
    end

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            register [0] <= 16'b0;
            register [1] <= 16'b0;
            register [2] <= 16'b0;
            register [3] <= 16'b0;
        end
        else begin
            if(write) begin
                register[addr3] <= data3;
            end
        end
    end
endmodule
