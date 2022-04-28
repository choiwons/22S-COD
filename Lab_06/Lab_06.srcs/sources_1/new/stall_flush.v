`include <opcodes.v>
module stall_flush(
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
        input isJAL,
        input Jump,
        input Branch,
        output reg flush_enable,
        output reg stall_enable
    );
    always @(*) begin
        if(Jump||Branch) begin
            stall_enable = 0;
        end
        else begin
            stall_enable = (rs_ID==dest_EX&&use_rs_ID&&RegWrite_EX)
                         || (rs_ID==dest_MEM&&use_rs_ID&&RegWrite_MEM)
                         || (rs_ID==dest_WB&&use_rs_ID&&RegWrite_WB)
                         || (rt_ID==dest_EX&&use_rs_ID&&RegWrite_EX)
                         || (rt_ID==dest_MEM&&use_rs_ID&&RegWrite_MEM)
                         || (rt_ID==dest_WB&&use_rs_ID&&RegWrite_WB);
        end
    end
endmodule
