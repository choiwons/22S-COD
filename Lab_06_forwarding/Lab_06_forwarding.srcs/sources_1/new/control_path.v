`include <opcodes.v>
module control_path(
        input [3:0] opcode,
        input [5:0] funct,
        input reset_n,
        input clk,
        output RegWrite, //RF enable
        output [1:0] ALUSrc, //0:buffer_B | 1:imm<<8 | 2:signExtendedImm | 3:ZeroExtendedImm
        output [3:0] ALUOp, // opcode for ALU
        output Branch,//for branch inst
        output Jump,
        output MemWrite, //write enable bit
        output MemRead, //read enable bit
        output [1:0] RegDst, // index of reg WB reg dest | 0:rt |1:rd |2:2
        output [1:0] MemtoReg, //mux control bit to RF write data | 0:memory data | 1:ALUout | 2:pc_buffer_WB
        output isWWD, //to know current inst is WWD
        output isHalt, // for HLT
        output use_rs,
        output use_rt,
        output PCSrc, // 0:PCSrc_MUX | 1:$rs
        output isComplete
    );
    reg [20:0] control_bit;
    reg [20:0] RtypeControl;
    assign {MemtoReg,RegWrite,isWWD,MemRead,MemWrite,Branch,Jump,ALUSrc,ALUOp,RegDst,isHalt,use_rs,use_rt,isComplete,PCSrc} = control_bit;
    //WB:MemtoReg,RegWrite,isWWD,isComplete | M:MemRead,MemWrite | EX: Branch,Jump,ALUSrc,ALUOp,RegDst | ID:isHalt,use_rs,use_rt
    always @(*) begin
        case(opcode)
            `OPCODE_ADI:
                control_bit = {2'd1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,2'd2,`OP_ADD,2'd0,1'b0,1'b1,1'b0,1'b1,1'b0};
            `OPCODE_ORI:
                control_bit = {2'd1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,2'd3,`OP_OR,2'd0,1'b0,1'b1,1'b0,1'b1,1'b0};
            `OPCODE_LHI:
                control_bit = {2'd1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,2'd1,`OP_IDB,2'd0,1'b0,1'b0,1'b0,1'b1,1'b0};
            `OPCODE_LWD:
                control_bit = {2'd0,1'b1,1'b0,1'b1,1'b0,1'b0,1'b0,2'd2,`OP_ADD,2'd0,1'b0,1'b1,1'b0,1'b1,1'b0};
            `OPCODE_SWD:
                control_bit = {2'd1,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,2'd2,`OP_ADD,2'd0,1'b0,1'b1,1'b1,1'b1,1'b0};
            `OPCODE_BNE:
                control_bit = {2'd1,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,2'd0,`OP_BNE,2'd0,1'b0,1'b1,1'b1,1'b1,1'b0};
            `OPCODE_BEQ:
                control_bit = {2'd1,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,2'd0,`OP_BEQ,2'd0,1'b0,1'b1,1'b1,1'b1,1'b0};
            `OPCODE_BGZ:
                control_bit = {2'd1,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,2'd0,`OP_BGZ,2'd0,1'b0,1'b1,1'b1,1'b1,1'b0};
            `OPCODE_BLZ:
                control_bit = {2'd1,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,2'd0,`OP_BLZ,2'd0,1'b0,1'b1,1'b1,1'b1,1'b0};
            `OPCODE_JMP:
                control_bit = {2'd1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,2'd2,`OP_ADD,2'd0,1'b0,1'b0,1'b0,1'b1,1'b0};
            `OPCODE_JAL:
                control_bit = {2'd2,1'b1,1'b0,1'b0,1'b0,1'b0,1'b1,2'd2,`OP_IDA,2'd2,1'b0,1'b0,1'b0,1'b1,1'b0};
            `OPCODE_R:
                control_bit = RtypeControl;
            default: //bubble
                control_bit = {2'd1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,2'd2,`OP_ADD,2'd0,1'b0,1'b0,1'b0,1'b0,1'b0};
        endcase
    end
    always @(*) begin
        case(funct)
            `FUNC_ADD:
                RtypeControl = {2'd1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,2'd0,`OP_ADD,2'd1,1'b0,1'b1,1'b1,1'b1,1'b0};
            `FUNC_AND:
                RtypeControl = {2'd1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,2'd0,`OP_AND,2'd1,1'b0,1'b1,1'b1,1'b1,1'b0};
            `FUNC_HLT:
                RtypeControl = {2'd1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,2'd0,`OP_ADD,2'd0,1'b1,1'b0,1'b0,1'b1,1'b0};
            `FUNC_JPR:
                RtypeControl = {2'd1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,2'd2,`OP_IDA,2'd0,1'b0,1'b1,1'b0,1'b1,1'b1};
            `FUNC_JRL:
                RtypeControl = {2'd2,1'b1,1'b0,1'b0,1'b0,1'b0,1'b1,2'd2,`OP_IDA,2'd2,1'b0,1'b1,1'b0,1'b1,1'b1};
            `FUNC_NOT:
                RtypeControl = {2'd1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,2'd0,`OP_NOT,2'd1,1'b0,1'b1,1'b0,1'b1,1'b0};
            `FUNC_ORR:
                RtypeControl = {2'd1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,2'd0,`OP_OR,2'd1,1'b0,1'b1,1'b1,1'b1,1'b0};
            `FUNC_SHL:
                RtypeControl = {2'd1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,2'd0,`OP_ALS,2'd1,1'b0,1'b1,1'b0,1'b1,1'b0};
            `FUNC_SHR:
                RtypeControl = {2'd1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,2'd0,`OP_ARS,2'd1,1'b0,1'b1,1'b0,1'b1,1'b0};
            `FUNC_SUB:
                RtypeControl = {2'd1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,2'd0,`OP_SUB,2'd1,1'b0,1'b1,1'b1,1'b1,1'b0};
            `FUNC_TCP:
                RtypeControl = {2'd1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,2'd0,`OP_TCP,2'd1,1'b0,1'b1,1'b0,1'b1,1'b0};
            `FUNC_WWD:
                RtypeControl = {2'd1,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,2'd0,`OP_ADD,2'd0,1'b0,1'b1,1'b0,1'b1,1'b0};
            default:
                RtypeControl = {2'd1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,2'd2,`OP_ADD,2'd0,1'b0,1'b0,1'b0,1'b0,1'b0};
        endcase
    end
endmodule
