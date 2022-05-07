
`define MEMORY_SIZE 256
module predictor(
        input [7:0] pc,
        input [7:0] write_address,
        input [7:0] write_btb,
        input [7:0] NextPC,
        input Jump,
        input Branch,
        input BranchCond,
        input [7:0] predicted_address_EX,
        input reset_n,
        input clk,
        output flush,
        output [`WORD_SIZE-1:0] predicted_address
    );
    reg [7:0] BTB [`MEMORY_SIZE-1:0] ;
    reg [`MEMORY_SIZE-1:0] enable;
    integer i;
    wire BranchFail;
    wire JumpFail;
    assign BranchFail = (Branch&&BranchCond&&(NextPC != predicted_address_EX))
           ||(Branch&&!BranchCond&&(predicted_address_EX != write_address+1'b1));
    assign JumpFail = (Jump&&(NextPC != predicted_address_EX));
    assign flush = (BranchFail||JumpFail);
    assign predicted_address = (enable[pc]) ? BTB[pc] : pc+1;
    always @(negedge reset_n or posedge clk) begin
        if(!reset_n) begin
            enable <= `MEMORY_SIZE'b0;
            for(i=0 ; i<`MEMORY_SIZE; i=i+1)
                BTB[i] <= 7'b0;
        end
        else if(Jump||Branch) begin
            BTB[write_address]  <= write_btb;
            enable[write_address] <= 1'b1;
        end
    end
endmodule
