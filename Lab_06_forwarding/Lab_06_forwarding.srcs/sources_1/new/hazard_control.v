`include <opcodes.v>
module hazard_control(
        input [`WORD_SIZE-1:0] NextPC,
        input [`WORD_SIZE-1:0] predicted_address_MEM,
        input [1:0] rs_ID,
        input [1:0] rt_ID,
        input [1:0] dest_EX,
        input [1:0] dest_MEM,
        input [1:0] dest_WB,
        input use_rs_ID,
        input use_rt_ID,
        input RegWrite_EX,
        input RegWrite_MEM,
        input RegWrite_WB,
        input MemRead_EX,
        input Jump_MEM,
        input Branch_MEM,
        output reg flush_enable,
        output reg stall_enable
    );
    always @(*) begin
        flush_enable = (Jump_MEM||Branch_MEM)&&(predicted_address_MEM!=NextPC);
        stall_enable = (!flush_enable)?(rs_ID == dest_EX)&&use_rs_ID&&MemRead_EX : 1'b0;
    end
endmodule
