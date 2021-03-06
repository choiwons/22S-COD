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
    reg [`kCoinBits - 1:0] next_num_coins [`kNumCoins - 1:0]; // use if needed
    reg [`kTotalBits - 1:0] current_total;
    reg [`kNumItems - 1:0] output_item;

    always @(*) begin
        output_item =i_select_item & o_available_item; //o_available_item은 update되기 전이기에 현재 물건을 구매했는지 나타내준다.
        next_num_coins[2] = (i_input_coin==3'b100) ? num_coins[2] + 1 :
                      (i_input_coin==3'b010&&num_coins[1]==1) ? num_coins[2] + 1 :
                      (i_input_coin==3'b001&&num_coins[0]==4&&num_coins[1]==1) ? num_coins[2] + 1 :
                      (output_item==4'b1000) ? num_coins[2] -2 :
                      (output_item==4'b0100) ? num_coins[2] -1 :
                      (output_item==4'b0010&&num_coins[1]==0) ? num_coins[2]-1:
                      (output_item==4'b0001&&num_coins[1]==0&&num_coins[0]!=4) ? num_coins[2]-1:num_coins[2];
        next_num_coins[1] = (i_input_coin==3'b010&&num_coins[1]==0) ? num_coins[1] + 1 :
                      (i_input_coin==3'b010&&num_coins[1]==1) ? num_coins[1] - 1 :
                      (i_input_coin==3'b001&&num_coins[0]==4&&num_coins[1]==0) ? num_coins[1] + 1 :
                      (i_input_coin==3'b001&&num_coins[0]==4&&num_coins[1]==1) ? num_coins[1] - 1 :
                      (output_item==4'b0010&&num_coins[1]==1) ? num_coins[1]-1  :
                      (output_item==4'b0010&&num_coins[1]==0) ? num_coins[1] + 1 :
                      (output_item==4'b0001&&num_coins[0]<4&&num_coins[1]==1) ? num_coins[1] -1 :
                      (output_item==4'b0001&&num_coins[0]<4&&num_coins[1]==0) ? num_coins[1] + 1 : num_coins[1];
        next_num_coins[0] = (i_input_coin==3'b001&&num_coins[0]!=4) ? num_coins[0]+1 :
                      (i_input_coin==3'b001&&num_coins[0]==4) ? num_coins[0] - 4:
                      (output_item==4'b0001&&num_coins[0]==4) ? num_coins[0]-4  :
                      (output_item==4'b0001&&num_coins[0]<4&&num_coins[1]==1) ? num_coins[0]+1  :
                      (output_item==4'b0001&&num_coins[0]<4&&num_coins[1]==0) ? num_coins[0]+1  : num_coins[0];
        //current_total은 물건을 구매하거나 동전을 넣는 input을 고려해준 전체 돈입니다.
        current_total = next_num_coins[0] * kkCoinValue[0] + next_num_coins[1] * kkCoinValue[1] + next_num_coins[2] * kkCoinValue[2];
        //앞서 선언한 next_num_coins와 동일한 내용입니다. 가독성을 위해 첨부합니다.
        // if (i_input_coin) begin
        //     case (i_input_coin) // input
        //         3'b001 : begin
        //             if(num_coins[0]==4) begin
        //                 if(num_coins[1]==0) begin
        //                     next_num_coins[2] <= num_coins[2];
        //                     next_num_coins[1] <= num_coins[1] + 1;
        //                     next_num_coins[0] <= num_coins[0] - 4;
        //                 end
        //                 else begin
        //                     next_num_coins[2] <= num_coins[2] + 1;
        //                     next_num_coins[1] <= num_coins[1] - 1;
        //                     next_num_coins[0] <= num_coins[0] - 4;
        //                 end
        //             end
        //             else begin
        //                 next_num_coins[2] <= num_coins[2];
        //                 next_num_coins[1] <= num_coins[1];
        //                 next_num_coins[0] <= num_coins[0] + 1;
        //             end
        //         end
        //         3'b010 : begin
        //             if(num_coins[1] == 1) begin
        //                 next_num_coins[2] <= num_coins[2] + 1;
        //                 next_num_coins[1] <= num_coins[1] - 1;
        //                 next_num_coins[0] <= num_coins[0];
        //             end
        //             else begin
        //                 next_num_coins[2] <= num_coins[2];
        //                 next_num_coins[1] <= num_coins[1] + 1;
        //                 next_num_coins[0] <= num_coins[0];
        //             end
        //         end
        //         3'b100 : begin
        //             next_num_coins[2] <= num_coins[2] + 1;
        //             next_num_coins[1] <= num_coins[1];
        //             next_num_coins[0] <= num_coins[0];
        //         end
        //         defalut : begin
        //             next_num_coins[2] <= num_coins[2];
        //             next_num_coins[1] <= num_coins[1];
        //             next_num_coins[0] <= num_coins[0];
        //         end
        //     endcase
        // end
        // else begin
        //     case (output_item) // output
        //         4'b0001 : begin
        //             if (num_coins[0] < 4) begin
        //                 if (num_coins[1] == 1) begin
        //                     next_num_coins[2] <= num_coins[2];
        //                     next_num_coins[1] <= num_coins[1] - 1;
        //                     next_num_coins[0] <= num_coins[0] + 1;
        //                 end
        //                 else begin
        //                     next_num_coins[2] <= num_coins[2] - 1;
        //                     next_num_coins[1] <= num_coins[1] + 1;
        //                     next_num_coins[0] <= num_coins[0] + 1;
        //                 end
        //             end
        //             else begin
        //                 next_num_coins[2] <= num_coins[2];
        //                 next_num_coins[1] <= num_coins[1];
        //                 next_num_coins[0] <= num_coins[0] - 4;
        //             end
        //         end
        //         4'b0010 : begin
        //             if (num_coins[1] == 0) begin
        //                 next_num_coins[2] <= num_coins[2] - 1;
        //                 next_num_coins[1] <= num_coins[1] + 1;
        //                 next_num_coins[0] <= num_coins[0];
        //             end
        //             else begin
        //                 next_num_coins[2] <= num_coins[2];
        //                 next_num_coins[1] <= num_coins[1] - 1;
        //                 next_num_coins[0] <= num_coins[0];
        //             end
        //         end
        //         4'b0100 : begin
        //             next_num_coins[2] <= num_coins[2] - 1;
        //             next_num_coins[1] <= num_coins[1];
        //             next_num_coins[0] <= num_coins[0];
        //         end
        //         4'b1000 : begin
        //             next_num_coins[2] <= num_coins[2] - 2;
        //             next_num_coins[1] <= num_coins[1];
        //             next_num_coins[0] <= num_coins[0];
        //         end
        //     endcase
        // end
    end

    // Sequential circuit to reset or update the states
    always @(posedge clk) begin
        if (!reset_n) begin
            o_return_coin <= 0;
            o_current_total <=0;
            o_output_item <=0;
            o_available_item <= 0;
            num_coins[0] <=0;
            num_coins[1] <=0;
            num_coins[2] <=0;
        end
        else begin
            if (i_trigger_return) begin
                o_return_coin <= num_coins[0] + num_coins[1] + num_coins[2];
                o_current_total <=0;
                o_output_item <=0;
                o_available_item <=0;
                num_coins[0] <=0;
                num_coins[1] <=0;
                num_coins[2] <=0;
            end
            else begin
                o_return_coin <= 0;
                o_current_total <= current_total;
                o_output_item <= output_item;
                o_available_item[3] <= (current_total >= kkItemPrice[3]) ? 1 : 0;
                o_available_item[2] <= (current_total >= kkItemPrice[2]) ? 1 : 0;
                o_available_item[1] <= (current_total >= kkItemPrice[1]) ? 1 : 0;
                o_available_item[0] <= (current_total >= kkItemPrice[0]) ? 1 : 0;
                num_coins[0] <=next_num_coins[0];
                num_coins[1] <=next_num_coins[1];
                num_coins[2] <=next_num_coins[2];
            end
        end
    end
endmodule
