`timescale 100ps / 100ps

module detector(clk, reset_n, in, out);
    input clk;
    input reset_n;
    input in;
    output reg out;
    reg [1:0] state;

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            out <= 0;
            state <= 2'b11;
        end
        else begin
            out <= (state == 2'b00 && in == 0) ? 0 :
                (state == 2'b00 && in == 1) ? 0 :
                (state == 2'b01 && in == 0) ? 1 :
                (state == 2'b01 && in == 1) ? 0 :
                (state == 2'b11 && in == 0) ? 0 : 0;

            state <= (state == 2'b00 && in == 0) ? 2'b00 :
                  (state == 2'b00 && in == 1) ? 2'b01 :
                  (state == 2'b01 && in == 0) ? 2'b00 :
                  (state == 2'b01 && in == 1) ? 2'b11 :
                  (state == 2'b11 && in == 0) ? 2'b00 : 2'b11;
        end
    end
endmodule
