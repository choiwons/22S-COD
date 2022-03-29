
module RF(RegWrite, clk, reset_n, addr1, addr2, addr3, data1, data2, readyToRead, data3,isReady,ALUReady);
    input RegWrite;
    input clk;
    input reset_n;
    input [1:0] addr1;
    input [1:0] addr2;
    input [1:0] addr3;
    output reg [15:0] data1;
    output reg [15:0] data2;
    output reg readyToRead;
    input [15:0] data3;
    input isReady;
    input ALUReady;

    reg [15:0] register [3:0];

    always @(*) begin
        if(isReady) begin
            data1 = register[addr1];
            data2 = register[addr2];
            readyToRead=1;
        end
        else begin
            readyToRead =0;
        end
    end

    always @(posedge ALUReady or negedge reset_n) begin
        if(!reset_n) begin
            register [0] <= 16'b0;
            register [1] <= 16'b0;
            register [2] <= 16'b0;
            register [3] <= 16'b0;
        end
        else begin
            if(ALUReady) begin
                if(RegWrite) begin
                    $display("Write! %h to %b", data3, addr3);
                    $display("regData : %h %h %h %h", register[0], register[1],register[2],register[3]);
                    register[addr3] <= data3;
                end
            end
        end
    end
endmodule
