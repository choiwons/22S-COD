`define MEMORY_SIZE 256
`define WORD_SIZE 16
module predictor(
        input [7:0] pc,
        input [7:0] write_address,
        input [7:0] write_btb,
        input [7:0] NextPC,
        input Jump,
        input Branch,
        input BranchCond,
        input reset_n,
        input clk,
        output [`WORD_SIZE-1:0] predicted_address
    );
    reg [7:0] BTB [`MEMORY_SIZE-1:0] ;
    reg [1:0] BHT [`MEMORY_SIZE-1:0] ;
    reg [`MEMORY_SIZE-1:0] enable;
    integer i;
    wire [1:0] update_counter_plus;
    wire [1:0] update_counter_minus;
    assign predicted_address = enable[pc]&&(BHT[pc][1]==1'b1) ? BTB[pc] : pc+1;
    assign update_counter_plus = (BHT[write_address] == 2'd0) ? 2'd1 : (BHT[write_address] == 2'd1) ? 2'd2 : 2'd3;
    assign update_counter_minus = (BHT[write_address] == 2'd3) ? 2'd2 : (BHT[write_address] == 2'd2) ? 2'd1 : 2'd0;
    always @(negedge reset_n or posedge clk) begin
        if(!reset_n) begin
            enable <= `MEMORY_SIZE'b0;
            for(i=0 ; i<`MEMORY_SIZE; i=i+1) begin
                BTB[i] <= 7'b0;
                BHT[i] <= 2'b10;
            end
        end
        else if(Jump||Branch) begin
            if(Branch&&BranchCond) begin
                BHT[write_address] <= update_counter_plus;
            end
            if(Branch&&!BranchCond) begin
                BHT[write_address] <= update_counter_minus;
            end
            BTB[write_address]  <= write_btb;
            enable[write_address] <= 1'b1;
        end
    end
endmodule
