`define MEMORY_SIZE 256
module btb(
        input [7:0] pc,
        input [7:0] write_address,
        input [7:0] write_btb,
        input writeB,
        input reset_n,
        input clk,
        output flush,
        output [`WORD_SIZE-1:0] predicted_address
    );
    reg [7:0] BTB [`MEMORY_SIZE-1:0] ;
    reg [`MEMORY_SIZE-1:0] enable;
    integer i;
    assign flush = (writeB&&(BTB[write_address] != write_btb)) ? 1 : 0;
    assign predicted_address = (enable[pc]) ? BTB[pc] : pc+1;
    always @(negedge reset_n or posedge clk) begin
        if(!reset_n) begin
            enable <= `WORD_SIZE'b0;
            for(i=0 ; i<`MEMORY_SIZE; i=i+1)
                BTB[i] <= 7'b0;
        end
        else if(writeB) begin
            BTB[write_address]  <= write_btb;
            enable[write_address] <= 1'b1;
        end
    end
endmodule
