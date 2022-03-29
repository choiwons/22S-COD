`define OP_ADD 4'b0000
`define OP_SUB 4'b0001
//  Bitwise Boolean operation
`define OP_ID 4'b0010
`define OP_NAND 4'b0011
`define OP_NOR 4'b0100
`define OP_XNOR 4'b0101
`define OP_NOT 4'b0110
`define OP_AND 4'b0111
`define OP_OR 4'b1000
`define OP_XOR 4'b1001
// Shifting
`define OP_LRS 4'b1010
`define OP_ARS 4'b1011
`define OP_RR 4'b1100
`define OP_LLS 4'b1101
`define OP_ALS 4'b1110
`define OP_RL 4'b1111
module ALU(
        input [15:0] A,
        input [15:0] B,
        input Cin,
        input [3:0] OP,
        input isReady,
        output reg [15:0] C,
        output reg Cout,
        output reg writeReady
    );
    always @(*) begin
        if(isReady) begin
            case(OP)
                `OP_ADD: begin
                    {Cout,C}=Cin+A+B;
                end
                `OP_SUB: begin
                    {Cout,C}=A-B-Cin;
                end
                `OP_ID: begin
                    C=B;
                    Cout=0;
                end
                `OP_NAND:begin
                    C=~(A&B);
                    Cout=0;
                end
                `OP_NOR:begin
                    C=~(A|B);
                    Cout=0;
                end
                `OP_XNOR:begin
                    C=~(A^B);
                    Cout=0;
                end
                `OP_NOT:begin
                    C=~A;
                    Cout=0;
                end
                `OP_AND:begin
                    C=A&B;
                    Cout=0;
                end
                `OP_OR:begin
                    C=A|B;
                    Cout=0;
                end
                `OP_XOR:begin
                    C=A^B;
                    Cout=0;
                end
                `OP_LRS:begin
                    C=A>>1;
                    Cout=0;
                end
                `OP_ARS:begin
                    C=$signed(A)>>>1;
                    Cout=0;
                end
                `OP_RR:begin
                    C={A[0], A[15:1]};
                    Cout=0;
                end
                `OP_LLS:begin
                    C=A<<1;
                    Cout=0;
                end
                `OP_ALS:begin
                    C=$signed(A)<<<1;
                    Cout=0;
                end
                `OP_RL: begin
                    C={A[14:0],A[15]};
                    Cout=0;
                end
            endcase
            writeReady = 1;
        end
        else begin
            writeReady = 0;
        end
    end
endmodule
