`include "opcodes.v"
module control_path(opcode,funct, RegDst,Jump,ALUOp,ALUSrc,RegWrite,isWWD,PCwrite);
    input [3:0] opcode; //opcode, instruction[15:12]
    input [5:0] funct; //funct, instruction[5:0]
    output RegDst; // MuxBeforeRF-0: rt | 1: rd
    output Jump; //0: PC + 1 | 1: {PC[15:12], targetAddress}
    output [3:0] ALUOp; // opcode for ALU
    output [1:0] ALUSrc; // 2'b00: {{8{imm[7]}},imm}| 2'b01: imm<<8 | 2'b10: regData2
    output RegWrite; //for register write control
    output isWWD; //to know current inst is WWD
    output PCwrite; //for pc write control
    /////////////////////////////////////////////////////////////////////////////
    reg [10:0] control_bit;
    reg [10:0] RtypeControl;
    assign {RegDst,Jump,ALUOp,ALUSrc,RegWrite,isWWD,PCwrite} = control_bit;
    always @(*) begin
        case(opcode)
            `OPCODE_JMP :
                control_bit = {1'b0,1'b1,`OP_ID,2'd2,1'b0,1'b0,1'b1};
            `OPCODE_LHI :
                control_bit = {1'b1,1'b0,`OP_ID,2'd1,1'b1,1'b0,1'b1};
            `OPCODE_ADI :
                control_bit = {1'b1,1'b0,`OP_ADD,2'd0,1'b1,1'b0,1'b1};
            `OPCODE_R :
                control_bit = RtypeControl;
            default :
                control_bit = {1'b0,1'b0,`OP_ID,2'd0,1'b0,1'b0,1'b0};
        endcase
    end
    always @(*) begin //if instruction is Rtype(WWD,ADD for this lab), RtypeControl will be the control_bit.
        case(funct)
            `FUNC_WWD:
                RtypeControl = {1'b0,1'b0,`OP_ID,2'd2,1'b0,1'b1,1'b1};
            `FUNC_ADD:
                RtypeControl = {1'b0,1'b0,`OP_ADD,2'd2,1'b1,1'b0,1'b1};
            default :
                RtypeControl = {1'b0,1'b0,`OP_ID,2'd0,1'b0,1'b0,1'b0};
        endcase
    end
endmodule
