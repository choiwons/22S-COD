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
    reg [`kTotalBits - 1:0] current_total;
    reg [`kCoinBits - 1:0] num_coins [`kNumCoins - 1:0]; // use if needed
    reg [`kTotalBits - 1:0] UsedUp;
    // Combinational circuit for the next states
    always @(*) begin
        current_total = num_coins[0] * kkCoinValue[0] + num_coins[1] * kkCoinValue[1] + num_coins[2] * kkCoinValue[2] -UsedUp;
    end
    // Combinational circuit for the output
    always @(*) begin
        o_current_total = current_total;
        o_output_item = i_select_item & o_available_item;
        o_available_item[0] = (current_total >= kkItemPrice[0]) ? 1 : 0;
        o_available_item[1] = (current_total >= kkItemPrice[1]) ? 1 : 0;
        o_available_item[2] = (current_total >= kkItemPrice[2]) ? 1 : 0;
        o_available_item[3] = (current_total >= kkItemPrice[3]) ? 1 : 0;
    end

    // Sequential circuit to reset or update the states
    always @(posedge clk) begin
        if (!reset_n) begin
            o_available_item <= 0;
            o_current_total <= 0;
            o_output_item <= 0;
            o_return_coin <= 0;
            UsedUp <= 0;
            num_coins[0] <= 0;
            num_coins[1] <= 0;
            num_coins[2] <= 0;
        end
        else begin
            if (i_trigger_return) begin
                o_return_coin <= (current_total) / 1000 + (current_total - (current_total) / 1000 * 1000) / 500 + (current_total - (current_total) / 1000 * 1000 - (current_total - (current_total) / 1000 * 1000) / 500 * 500) / 100;
                num_coins[0] <= 0;
                num_coins[1] <= 0;
                num_coins[2] <= 0;
                UsedUp <= 0;
            end
            else begin
                if (i_input_coin & 3'b001) begin
                    num_coins[0] <= num_coins[0] + 1;
                end
                if (i_input_coin & 3'b010) begin
                    num_coins[1] <= num_coins[1] + 1;
                end
                if (i_input_coin & 3'b100) begin
                    num_coins[2] <= num_coins[2] + 1;
                end
                UsedUp <= (i_select_item&4'b0001 && o_available_item[0]) ? UsedUp + kkItemPrice[0] :
                       (i_select_item&4'b0010 && o_available_item[1]) ? UsedUp + kkItemPrice[1] :
                       (i_select_item&4'b0100 && o_available_item[2]) ? UsedUp + kkItemPrice[2] :
                       (i_select_item&4'b1000 && o_available_item[3]) ? UsedUp + kkItemPrice[3] : UsedUp;
            end
        end
    end
endmodule