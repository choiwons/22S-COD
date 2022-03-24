// Title         : vending_machine.v
// Author      : Hunjun Lee (hunjunlee7515@snu.ac.kr), Suheon Bae (suheon.bae@snu.ac.kr)

`include "vending_machine_def.v"

module vending_machine(

        clk,     // Clock signal
        reset_n, // Reset signal (active-low)

        i_input_coin,     // coin is inserted.
        i_select_item,    // item is selected.
        i_trigger_return, // change-return is triggered

        o_available_item, // Sign of the item availability
        o_output_item,    // Sign of the item withdrawal
        o_return_coin,    // Sign of the coin return
        o_current_total);

    // Ports Declaration
    input clk;
    input reset_n;

    input [`kNumCoins - 1:0] i_input_coin;
    input [`kNumItems - 1:0] i_select_item;
    input i_trigger_return;

    output reg [`kNumItems - 1:0] o_available_item;
    output reg [`kNumItems - 1:0] o_output_item;
    output reg [`kReturnCoins - 1:0] o_return_coin;
    output reg [`kTotalBits - 1:0] o_current_total;

    // Net constant values (prefix kk & CamelCase)
    wire [31:0] kkItemPrice [`kNumItems - 1:0]; // Price of each item
    wire [31:0] kkCoinValue [`kNumCoins - 1:0]; // Value of each coin
    assign kkItemPrice[0] = 400;
    assign kkItemPrice[1] = 500;
    assign kkItemPrice[2] = 1000;
    assign kkItemPrice[3] = 2000;
    assign kkCoinValue[0] = 100;
    assign kkCoinValue[1] = 500;
    assign kkCoinValue[2] = 1000;

    // Internal states. You may add your own reg variables.
    reg [`kCoinBits - 1:0] num_coins [`kNumCoins - 1:0]; // use if needed
    // Combinational circuit for the next states
    always @(*) begin
        o_current_total = num_coins[0] * kkCoinValue[0] + num_coins[1] * kkCoinValue[1] + num_coins[2] * kkCoinValue[2];
    end
    // Combinational circuit for the output
    always @(*) begin
        o_output_item = i_select_item & o_available_item;
        o_available_item[0] = (o_current_total >= kkItemPrice[0]) ? 1 : 0;
        o_available_item[1] = (o_current_total >= kkItemPrice[1]) ? 1 : 0;
        o_available_item[2] = (o_current_total >= kkItemPrice[2]) ? 1 : 0;
        o_available_item[3] = (o_current_total >= kkItemPrice[3]) ? 1 : 0;
    end

    // Sequential circuit to reset or update the states
    always @(posedge clk) begin
        if (!reset_n) begin
            o_return_coin <= 0;
            num_coins[0] <= 0;
            num_coins[1] <= 0;
            num_coins[2] <= 0;
        end
        else begin
            if (i_trigger_return) begin
                o_return_coin <= num_coins[0] + num_coins[1] + num_coins[2];
                num_coins[0] <= 0;
                num_coins[1] <= 0;
                num_coins[2] <= 0;
            end
            else begin
                if(num_coins[0]>=5&&num_coins[1]==1)begin
                    num_coins[0]<=num_coins[0]-5;
                    num_coins[1]<=num_coins[1]-1;
                    num_coins[2]<=num_coins[2]+1;
                end
                else if(num_coins[0]>=5) begin
                    num_coins[1]<=num_coins[1]+1;
                    num_coins[0]<=num_coins[0]-5;
                end
                else if(num_coins[1]>=2) begin
                    num_coins[2]<=num_coins[2]+1;
                    num_coins[1]<= num_coins[1]-2;
                end
                else if(i_input_coin) begin
                    case (i_input_coin) //input
                        3'b001 :
                            num_coins[0] <= num_coins[0] +1;
                        3'b010 :
                            num_coins[1] <= num_coins[1] +1;
                        3'b100 :
                            num_coins[2] <= num_coins[2] +1;
                    endcase
                end
                else begin
                    case (o_output_item) //output
                        4'b0001 : begin
                            if(num_coins[0]<4) begin
                                if(num_coins[1]==1) begin
                                    num_coins[1]<=num_coins[1]-1;
                                    num_coins[0] <= num_coins[0]+1;
                                end
                                else begin
                                    num_coins[2] <= num_coins[2] -1;
                                    num_coins[1] <= num_coins[1] + 1;
                                    num_coins[0] <= num_coins[0] + 1;
                                end
                            end
                            else begin
                                num_coins[0] <= num_coins[0] - 4;
                            end
                        end
                        4'b0010 : begin
                            if(num_coins[1]==0) begin
                                num_coins[2] <= num_coins[2] - 1;
                                num_coins[1] <= num_coins[1] + 1;
                            end
                            else begin
                                num_coins[1] <= num_coins[1]-1;
                            end
                        end
                        4'b0100 : begin
                            num_coins[2] <= num_coins[2] - 1;
                        end
                        4'b1000 : begin
                            num_coins[2] <= num_coins[2] - 2;
                        end
                    endcase
                end
            end
        end
    end
endmodule
