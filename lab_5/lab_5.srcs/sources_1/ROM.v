`include "opcodes.v"
module ROM(opcode,funct,stage,RegDst,RegWrite,ALUSrcA,ALUSrcB,PCSource,IRWrite,MemtoReg,MemWrite,MemRead,IorD,ALUOp,isWWD,isHalt,isComplete, PCwrite,PCwriteCond);
    input [3:0] opcode; //instruction[15:12]
    input [5:0] funct;  //instruction[5:0]
    input [2:0] stage;  //result of state_machine
    output [1:0]RegDst; // MuxBeforeRF-0: rt | 1: rd | 2: 2
    output RegWrite; //RF enable
    output ALUSrcA; //first input to ALU | 0:PC | 1:buffer_A
    output [2:0] ALUSrcB; //0:buffer_B | 1:1 | 2:imm<<8 | 3:signExtendedImm | 4:ZeroExtendedImm
    output [1:0] PCSource;//0:ALUresult | 1:ALUout | 2:targetAddress | 3:$rs
    output IRWrite;//IR latching enable signal
    output [1:0] MemtoReg; //mux control bit to RF write data | 0:resultOfALU | 1:MDR | 2:ALUOut | 3:PC
    output MemWrite; //write enable bit
    output MemRead; //read enable bit
    output IorD; // 0 : for Inst | 1 : for data
    output [3:0] ALUOp; // opcode for ALU
    output isWWD; //to know current inst is WWD
    output isHalt; // for HLT
    output isComplete;//for update num_inst
    output PCwrite; //for pc write control
    output PCwriteCond;//for branch inst
    reg [23:0] control_bit;
    assign {RegDst,RegWrite,ALUSrcA,ALUSrcB,PCSource,IRWrite,MemtoReg,MemWrite,MemRead,IorD,ALUOp,isWWD,isHalt,isComplete,PCwrite,PCwriteCond} = control_bit;

    always @(*) begin
        if(stage == `ERstage)
            control_bit = {2'd0,1'b0,1'b0,3'd1,2'd0,1'b1,2'd0,1'b0,1'b1,1'b0,`OP_ADD,1'b0,1'b0,1'b0,1'b0,1'b0};
        //IR <= Mem[address]
        else if(stage == `IFstage)
            control_bit = {2'd0,1'b0,1'b0,3'd1,2'd0,1'b1,2'd0,1'b0,1'b1,1'b0,`OP_ADD,1'b0,1'b0,1'b0,1'b1,1'b0};
        //IR <= Mem[address]
        //PC <= PC+1
        else if(stage == `IDstage)
        case(opcode)
            `OPCODE_JMP:
                control_bit = {2'd0,1'b0,1'b0,3'd0,2'd2,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_IDA,1'b0,1'b0,1'b1,1'b1,1'b0};
            //PC<={PC[15:12],targetAddress}
            `OPCODE_JAL:
                control_bit = {2'd2,1'b1,1'b0,3'd0,2'd2,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_IDA,1'b0,1'b0,1'b1,1'b1,1'b0};
            //$2 <= PC
            //PC<={PC[15:12],targetAddress}
            `OPCODE_BNE:
                control_bit = {2'd0,1'b0,1'b1,3'd0,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_BNE,1'b0,1'b0,1'b0,1'b0,1'b0};
            //bcond <= ($rs!=$rt)
            `OPCODE_BEQ:
                control_bit = {2'd0,1'b0,1'b1,3'd0,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_BEQ,1'b0,1'b0,1'b0,1'b0,1'b0};
            //bcond <= ($rs==$rt)
            `OPCODE_BGZ:
                control_bit = {2'd0,1'b0,1'b1,3'd0,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_BGZ,1'b0,1'b0,1'b0,1'b0,1'b0};
            //bcond <= ($rs>0)
            `OPCODE_BLZ:
                control_bit = {2'd0,1'b0,1'b1,3'd0,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_BLZ,1'b0,1'b0,1'b0,1'b0,1'b0};
            //bcond <= ($rs<0)
            `OPCODE_R:
            case (funct)
                `FUNC_WWD:
                    control_bit = {2'd0,1'b0,1'b0,3'd1,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_ADD,1'b1,1'b0,1'b1,1'b0,1'b0};
                //isWWD=1;
                `FUNC_HLT:
                    control_bit = {2'd0,1'b0,1'b0,3'd1,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b1,1'b0,1'b0,1'b0};
                //isHalt==1
                `FUNC_JPR:
                    control_bit = {2'd0,1'b0,1'b1,3'd0,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_IDA,1'b0,1'b0,1'b1,1'b1,1'b0};
                //PC<=$rs
                `FUNC_JRL:
                    control_bit = {2'd2,1'b1,1'b1,3'd0,2'd0,1'b0,2'd3,1'b0,1'b0,1'b0,`OP_IDA,1'b0,1'b0,1'b1,1'b1,1'b0};
                //$2 <= PC;
                //PC <= $rs
                default :
                    control_bit = {2'd0,1'b0,1'b0,3'd0,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_IDA,1'b0,1'b0,1'b0,1'b0,1'b0};
            endcase
            default :
                control_bit = {2'd0,1'b0,1'b0,3'd0,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_IDA,1'b0,1'b0,1'b0,1'b0,1'b0};
        endcase
        else if(stage == `EXstage)
        case (opcode)
            `OPCODE_LHI:
                control_bit = {2'd0,1'b0,1'b0,3'd2,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_IDB,1'b0,1'b0,1'b0,1'b0,1'b0};
            //$ALUout <= imm<<8
            `OPCODE_ADI:
                control_bit = {2'd0,1'b0,1'b1,3'd3,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b0,1'b0,1'b0,1'b0};
            //ALUout <= $rs + SE(imm)
            `OPCODE_ORI:
                control_bit = {2'd0,1'b0,1'b1,3'd4,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_OR,1'b0,1'b0,1'b0,1'b0,1'b0};
            //ALUout <= $rs | ZE(imm)
            `OPCODE_LWD:
                control_bit = {2'd0,1'b0,1'b1,3'd3,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b0,1'b0,1'b0,1'b0};
            //ALUout <= $rs + SE(imm)
            `OPCODE_SWD:
                control_bit = {2'd0,1'b0,1'b1,3'd3,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b0,1'b0,1'b0,1'b0};
            //ALUout <= $rs + SE(imm)
            `OPCODE_BNE:
                control_bit = {2'd0,1'b0,1'b0,3'd3,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b0,1'b1,1'b0,1'b1};
            //if(bcond)PC<=PC+SE(imm)
            `OPCODE_BEQ:
                control_bit = {2'd0,1'b0,1'b0,3'd3,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b0,1'b1,1'b0,1'b1};
            //if(bcond) PC<=PC+SE(imm)
            `OPCODE_BGZ:
                control_bit = {2'd0,1'b0,1'b0,3'd3,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b0,1'b1,1'b0,1'b1};
            //if(bcond) PC<=PC+SE(imm)
            `OPCODE_BLZ:
                control_bit = {2'd0,1'b0,1'b0,3'd3,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b0,1'b1,1'b0,1'b1};
            //if(bcond) PC<=PC+SE(imm)
            `OPCODE_R:
            case (funct)
                `FUNC_ADD:
                    control_bit = {2'd0,1'b0,1'b1,3'd0,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b0,1'b0,1'b0,1'b0};
                //ALUout <= $rs + $rt
                `FUNC_AND:
                    control_bit = {2'd0,1'b0,1'b1,3'd0,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_AND,1'b0,1'b0,1'b0,1'b0,1'b0};
                //ALUout <= $rs & $rt
                `FUNC_SUB:
                    control_bit = {2'd0,1'b0,1'b1,3'd0,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_SUB,1'b0,1'b0,1'b0,1'b0,1'b0};
                //ALUout <= $rs - $rt
                `FUNC_ORR:
                    control_bit = {2'd0,1'b0,1'b1,3'd0,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_OR,1'b0,1'b0,1'b0,1'b0,1'b0};
                //ALUout <= $rs | $rt
                `FUNC_NOT:
                    control_bit = {2'd0,1'b0,1'b1,3'd0,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_NOT,1'b0,1'b0,1'b0,1'b0,1'b0};
                //ALUout <= !$rs
                `FUNC_TCP:
                    control_bit = {2'd0,1'b0,1'b1,3'd0,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_TCP,1'b0,1'b0,1'b0,1'b0,1'b0};
                //ALUout <= !$rs+1
                `FUNC_SHL:
                    control_bit = {2'd0,1'b0,1'b1,3'd0,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_LLS,1'b0,1'b0,1'b0,1'b0,1'b0};
                //ALUout <= $rs << 1
                `FUNC_SHR:
                    control_bit = {2'd0,1'b0,1'b1,3'd0,2'd0,1'b0,2'd0,1'b0,1'b0,1'b0,`OP_ARS,1'b0,1'b0,1'b0,1'b0,1'b0};
                //ALUout <= $rs >>> 1
            endcase
        endcase
        else if(stage==`MEMstage)
        case (opcode)
            `OPCODE_SWD:
                control_bit = {2'd0,1'b0,1'b0,3'd0,2'd0,1'b0,2'd0,1'b1,1'b0,1'b1,`OP_IDA,1'b0,1'b0,1'b1,1'b0,1'b0};
            //Mem[ALUout] <= $rt
            `OPCODE_LWD:
                control_bit = {2'd0,1'b0,1'b0,3'd0,2'd0,1'b0,2'd1,1'b0,1'b1,1'b1,`OP_IDA,1'b0,1'b0,1'b0,1'b0,1'b0};
            //MDR <= Mem[ALUout]
        endcase
        else if(stage==`WBstage)
        case (opcode)
            `OPCODE_LHI:
                control_bit = {2'd0,1'b1,1'b0,3'd0,2'd0,1'b0,2'd2,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b0,1'b1,1'b0,1'b0};
            //$rt<=ALUout
            `OPCODE_ADI:
                control_bit = {2'd0,1'b1,1'b0,3'd0,2'd0,1'b0,2'd2,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b0,1'b1,1'b0,1'b0};
            //$rt<=ALUout
            `OPCODE_ORI:
                control_bit = {2'd0,1'b1,1'b0,3'd0,2'd0,1'b0,2'd2,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b0,1'b1,1'b0,1'b0};
            //$rt<=ALUout
            `OPCODE_LWD:
                control_bit = {2'd0,1'b1,1'b0,3'd0,2'd0,1'b0,2'd1,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b0,1'b1,1'b0,1'b0};
            //$rt<=MDR
            `OPCODE_R:
            case (funct)
                `FUNC_ADD:
                    control_bit = {2'd1,1'b1,1'b0,3'd0,2'd0,1'b0,2'd2,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b0,1'b1,1'b0,1'b0};
                //$rd <= ALUout
                `FUNC_SUB:
                    control_bit = {2'd1,1'b1,1'b0,3'd0,2'd0,1'b0,2'd2,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b0,1'b1,1'b0,1'b0};
                //$rd <= ALUout
                `FUNC_AND:
                    control_bit = {2'd1,1'b1,1'b0,3'd0,2'd0,1'b0,2'd2,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b0,1'b1,1'b0,1'b0};
                //$rd <= ALUout
                `FUNC_ORR:
                    control_bit = {2'd1,1'b1,1'b0,3'd0,2'd0,1'b0,2'd2,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b0,1'b1,1'b0,1'b0};
                //$rd <= ALUout
                `FUNC_NOT:
                    control_bit = {2'd1,1'b1,1'b0,3'd0,2'd0,1'b0,2'd2,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b0,1'b1,1'b0,1'b0};
                //$rd <= ALUout
                `FUNC_TCP:
                    control_bit = {2'd1,1'b1,1'b0,3'd0,2'd0,1'b0,2'd2,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b0,1'b1,1'b0,1'b0};
                //$rd <= ALUout
                `FUNC_SHL:
                    control_bit = {2'd1,1'b1,1'b0,3'd0,2'd0,1'b0,2'd2,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b0,1'b1,1'b0,1'b0};
                //$rd <= ALUout
                `FUNC_SHR:
                    control_bit = {2'd1,1'b1,1'b0,3'd0,2'd0,1'b0,2'd2,1'b0,1'b0,1'b0,`OP_ADD,1'b0,1'b0,1'b1,1'b0,1'b0};
                //$rd <= ALUout
            endcase
        endcase
    end
endmodule
