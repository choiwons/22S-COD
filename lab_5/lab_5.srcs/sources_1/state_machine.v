`include "opcodes.v"
module state_machine(opcode,funct,reset_n,clk,stage);
    input [3:0] opcode;
    input [5:0] funct;
    input reset_n;
    input clk;
    output reg [2:0] stage;
    //////////////////////////////////////////////////////////////////////////////////////////
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            stage <= `ERstage;
        end
        else begin
            case (stage)
                `ERstage :
                    stage <= `IFstage;
                `IFstage :
                    stage <= `IDstage;
                `IDstage : begin
                    case (opcode)
                        `OPCODE_R :
                        case(funct)
                            `FUNC_WWD,
                            `FUNC_JRL,
                            `FUNC_JPR,
                            `FUNC_HLT:
                                stage <=`IFstage;
                            default:
                                stage <=`EXstage;
                        endcase
                        `OPCODE_JMP,
                        `OPCODE_JAL:
                            stage <= `IFstage;
                        default:
                            stage <= `EXstage;
                    endcase
                end
                `EXstage : begin
                    case (opcode)
                        `OPCODE_BNE,
                        `OPCODE_BEQ,
                        `OPCODE_BGZ,
                        `OPCODE_BLZ:
                            stage <= `IFstage;
                        `OPCODE_R:
                        case(funct)
                            `FUNC_ADD,
                            `FUNC_SUB,
                            `FUNC_AND,
                            `FUNC_ORR,
                            `FUNC_NOT,
                            `FUNC_TCP,
                            `FUNC_SHL,
                            `FUNC_SHR:
                                stage <=`WBstage;
                            default:
                                stage<=`IFstage;
                        endcase
                        `OPCODE_ADI ,
                        `OPCODE_ORI ,
                        `OPCODE_LHI :
                            stage <= `WBstage;
                        default:
                            stage <= `MEMstage;
                    endcase
                end
                `MEMstage : begin
                    if(opcode==`OPCODE_SWD)
                        stage <= `IFstage;
                    else
                        stage <= `WBstage;
                end
                `WBstage : begin
                    stage <= `IFstage;
                end
            endcase
        end
    end
endmodule
