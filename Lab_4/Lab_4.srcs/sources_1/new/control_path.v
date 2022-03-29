module control_path(instruction,inputReady, isReady, control_bit);
    input [15:0] instruction;
    input inputReady;
    output reg isReady;
    output reg [12:0] control_bit;
    always @(*) begin
        control_bit[0] = (instruction[15:12] == 4'd6 || (instruction[15:12]== 4'd11 && instruction[5:0] != 28)) ? 1 : 0;
        control_bit[1] = (instruction[15:12] == 4'b1001) ? 1 : 0;
        control_bit[2] = 0;
        control_bit[3] =0;
        control_bit[4] =0;
        control_bit[8:5] = (instruction[15:12] == 4'd4 || (instruction[15:12]== 4'd11 && instruction[5:0] != 28)) ? 4'b0000 : 4'b0010;
        control_bit[9] = 0;
        control_bit[10] = (instruction[15:12] == 4'd4) ? 1 : 0;
        control_bit[11] = (instruction[15:12] == 4'd6 || instruction[15:12] == 4'd4|| (instruction[15:12]== 4'd11 && instruction[5:0] != 28)) ? 1 : 0;
        control_bit[12] = (instruction[5:0]==28) ? 1 : 0;
        isReady = 1;
    end
    always @(negedge inputReady) begin
        isReady <= 0;
    end
endmodule
