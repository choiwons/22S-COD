`include <opcodes.v>
module hazard_control(
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
        input Branch,
        input Jump,
        input Jump_MEM,
        input Jump_EX,
        input Branch_EX,
        input Branch_MEM,
        input [`WORD_SIZE-1:0] predicted_address_MEM,
        input [`WORD_SIZE-1:0] NextPC,
        output reg stall_enable,
        output reg flush
    );
    always @(*) begin
        flush = (Jump_MEM||Branch_MEM)&&(predicted_address_MEM!=NextPC);
        stall_enable = (!flush) ? (rs_ID==dest_EX&&use_rs_ID&&RegWrite_EX)
                     || (rt_ID==dest_EX&&use_rt_ID&&RegWrite_EX)
                     || (rs_ID==dest_MEM&&use_rs_ID&&RegWrite_MEM)
                     || (rt_ID==dest_MEM&&use_rt_ID&&RegWrite_MEM)
                     || (rs_ID==dest_WB&&use_rs_ID&&RegWrite_WB)
                     || (rt_ID==dest_WB&&use_rt_ID&&RegWrite_WB) :0;
    end
endmodule
