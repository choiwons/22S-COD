`define RegDst control_bit[0]
`define Jump control_bit[1]
`define Branch control_bit[2]
`define MemRead  control_bit[3]
`define MemtoReg control_bit[4]
`define ALUOp  control_bit[8:5]
`define ALUSrc control_bit[10:9]
`define RegWrite control_bit[11]
`define isWWD control_bit[12]

module control_path(inst,inputReady, isReady, control_bit);
    input [15:0] inst;
    input inputReady;
    output reg isReady;
    output reg [12:0] control_bit;

    always @(*) begin
        if(inputReady) begin
            `RegDst = (inst[15:12] == 4'd6 ||inst[15:12] == 4'd4)  ? 1 : 0; //1 if rt
            `Jump= (inst[15:12] == 4'b1001) ? 1 : 0;
            `Branch = 0;
            `MemRead=0;
            `MemtoReg=0;
            `ALUOp = (inst[15:12] == 4'd4 || (inst[15:12]== 4'd15 && inst[5:0] ==0)) ? 4'b0000 : 4'b0010;
            `ALUSrc = (inst[15:12] == 4'd4) ? 2'b00 :
                    (inst[15:12] == 4'd6) ? 2'b01 : 2'b10;
            `RegWrite = (inst[15:12] == 4'd6 || inst[15:12] == 4'd4|| (inst[15:12]== 4'd15 && inst[5:0] == 0)) ? 1 : 0;
            `isWWD = (inst[5:0]==28) ? 1 : 0;
            isReady = 1;
        end
        else begin
            control_bit = control_bit;
            isReady = 0;
        end
    end
endmodule
