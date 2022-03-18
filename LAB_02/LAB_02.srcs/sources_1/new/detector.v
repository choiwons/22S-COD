`timescale 100ps / 100ps

module detector(clk, reset_n, in, out);
    input clk;
    input reset_n;
    input in;
    output reg out;
    reg [1:0] state; //처음에는 x로 값을 가지고 잇음. reset_n을 3클럭정도 줘서 init

    always @(posedge clk or negedge reset_n) begin // undeterminastic fuctionality
        if(!reset_n) begin
            out <= 0;
            state <= 2'b10;
        end
        // non-blocking은 tmp에 모든 값읓 넣어주고 거기서 계산을 모두 수행한다고 생각.
        else begin  //리셋이 왕
            out <= (state == 2'b00 && in == 0) ? 0 : // 전 state에 depend 1클럭 밀림(밀리의 특징)
                (state == 2'b00 && in == 1) ? 0 :
                (state == 2'b01 && in == 0) ? 1 :
                (state == 2'b01 && in == 1) ? 0 :
                (state == 2'b10 && in == 0) ? 0 :
                (state == 2'b10 && in == 1) ? 0 :
                (state == 2'b11 && in == 0) ? 0 : 0;

            state <= (state == 2'b00 && in == 0) ? 2'b00 :
                  (state == 2'b00 && in == 1) ? 2'b01 :
                  (state == 2'b01 && in == 0) ? 2'b00 :
                  (state == 2'b01 && in == 1) ? 2'b11 :
                  (state == 2'b10 && in == 0) ? 2'b00 :
                  (state == 2'b10 && in == 1) ? 2'b11 :
                  (state == 2'b11 && in == 0) ? 2'b00 : 2'b11;
        end
    end
endmodule
//in은 async input
//무어는 input이 async, state는 sync하게 해주고 out을 state에 comb logic으로 해줄 수 있음.
