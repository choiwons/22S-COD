`include "opcodes.v"
module ALU(
        input [15:0] A,
        input [15:0] B,
        input [3:0] OP,
        output reg [15:0] C,
        output reg bcond
    );
    always @(*) begin
        case(OP)
            `OP_ADD: begin
                C=A+B;
                bcond=0;
            end
            `OP_BNE: begin
                C=0;
                bcond = (A!=B);
            end
            `OP_BLZ: begin
                C=0;
                bcond = ($signed(A)<0);
            end
            `OP_BGZ: begin
                C=0;
                bcond = ($signed(A)>0);
            end
            `OP_BEQ: begin
                C=0;
                bcond = (A==B);
            end
            `OP_TCP : begin
                C=~A+1;
            end
            `OP_SUB: begin
                C=A-B;
            end
            `OP_IDA: begin
                C=A;
            end
            `OP_IDB : begin
                C=B;
            end
            `OP_NOT:begin
                C=~A;
            end
            `OP_AND:begin
                C=A&B;
            end
            `OP_OR:begin
                C=A|B;
            end
            `OP_LRS:begin
                C=A>>1;
            end
            `OP_ARS:begin
                C=$signed(A)>>>1;
            end
            `OP_LLS:begin
                C=A<<1;
            end
            `OP_ALS:begin
                C=$signed(A)<<<1;
            end
        endcase
    end
endmodule
