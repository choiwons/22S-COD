module forwarding_control (
        input [1:0] dest_EX,
        input [1:0] dest_MEM,
        input [1:0] dest_WB,
        input RegWrite_MEM,
        input RegWrite_WB,
        input RegWrite_EX,
        input use_rs,
        input use_rt,
        input [1:0] rs,
        input [1:0] rt,
        output reg [1:0] ALUSrc_A,
        output reg [1:0] ALUSrc_B
    );
    always @(*) begin
        ALUSrc_A = (use_rs&&(rs==dest_EX)&&RegWrite_EX) ? 2'd1 :
                 (use_rs&&(rs==dest_MEM)&&RegWrite_MEM) ? 2'd2 :
                 (use_rs&&(rs==dest_WB)&&RegWrite_WB) ? 2'd3 : 0;
        ALUSrc_B = (use_rt&&(rt==dest_EX)&&RegWrite_EX) ? 2'd1 :
                 (use_rt&&(rt==dest_MEM)&&RegWrite_MEM) ? 2'd2 :
                 (use_rt&&(rt==dest_WB)&&RegWrite_WB) ? 2'd3 : 0;
    end
endmodule
