`include "opcodes.v"

module data_path(
        input clk,
        input reset_n,
        ///>>
        input RegWrite, //RF enable
        input [1:0] ALUSrc, //0:buffer_B | 1:imm<<8 | 2:SignExtendedImm | 3:ZeroExtendedImm
        input [3:0] ALUOp, // opcode for ALU
        input Branch,//for branch inst
        input Jump,
        input MemWrite, //write enable bit
        input MemRead, //read enable bit
        input [1:0] RegDst, // index of reg WB reg dest | 0:rt |1:rd |2:2
        input [1:0] MemtoReg, //mux control bit to RF write data | 0:memory data | 1:ALUout | 2:pc_buffer_WB
        input isWWD, //to know current inst is WWD
        input isHalt, // for HLT
        input use_rs,
        input use_rt,
        input isComplete,
        input PCSrc,
        input isJAL,
        //<<refer to control path
        input [`WORD_SIZE-1:0] i_data,
        input [`WORD_SIZE-1:0] d_data,
        output d_readM,
        output d_writeM,
        output [`WORD_SIZE-1:0] instruction,
        output reg [`WORD_SIZE-1:0] num_inst,
        output [`WORD_SIZE-1:0] i_address,
        output [`WORD_SIZE-1:0] d_address,
        output reg [`WORD_SIZE-1:0] output_port,
        output is_halted
    );
    //////////////////////////////////////////
    //wire
    wire stall_enable;
    wire [`WORD_SIZE-1:0] targetAddress;
    wire BranchCond;
    wire [`WORD_SIZE-1:0] resultOfALU;
    //////////////////////////////////////////
    //PC update
    reg [`WORD_SIZE-1:0] PC;
    wire [`WORD_SIZE-1 :0] PCSrc_MUX;
    wire [`WORD_SIZE-1 :0] tarr;
    wire [`WORD_SIZE-1 :0] PCPlusOne;
    assign PCPlusOne = PC + 1;
    assign tarr = (Jump_EX) ? targetAddress : PCPlusOne;
    assign PCSrc_MUX = (PCSrc_EX) ? buffer_A : tarr;
    always @(negedge reset_n  or posedge clk) begin //every posedge clk, if PCwrite is on, update PC.
        if(!reset_n) begin
            PC <= 0;
        end
        else if(!stall_enable) begin
            if(Branch_EX&&BranchCond)
                PC <= pc_buffer_ID_EX + SignExtendedImm;
            else
                PC <= PCSrc_MUX;
        end
    end
    /////////////////////////////////////////
    //IF
    assign i_address = PC;
    assign instruction = IR;
    /////////////////////////////////////////
    //>>> IF/ID buffer
    reg [`WORD_SIZE-1:0] pc_buffer_IF_ID;
    reg [`WORD_SIZE-1:0] IR;
    always@(negedge reset_n or posedge clk) begin
        if(!reset_n || Jump_EX || (Branch_EX&&BranchCond)) begin
            IR <=`INST_BUB;
            pc_buffer_IF_ID <= 0;
        end
        else if(!stall_enable) begin
            IR<= i_data;
            pc_buffer_IF_ID <= PCPlusOne;
        end
    end
    /////////////////////////////////////////
    //<<<<< IF/ID buffer
    //////////////////////////////////////////
    //ID
    wire [1:0] RegDst_Mux;
    wire [1:0] rs;
    wire [1:0] rt;
    wire [1:0] rd;
    wire [7:0] imm;
    wire [`WORD_SIZE-1:0] RF_out_A;
    wire [`WORD_SIZE-1:0] RF_out_B;
    wire [`WORD_SIZE-1:0] MemtoReg_Mux;
    assign imm = IR[7:0];
    assign rs = IR[11:10];
    assign rt = IR[9:8];
    assign rd = IR[7:6];
    assign RegDst_Mux = (isJAL||RegDst==2'd2) ? 2'd2 :
           (RegDst == 2'd0) ? rt :
           rd;
    RF rf(
           .RegWrite(RegWrite_WB),
           .reset_n(reset_n),
           .clk(clk),
           .addr1(rs),
           .addr2(rt),
           .addr3(buffer_dest_reg_WB),
           .data1(RF_out_A),
           .data2(RF_out_B),
           .data3(MemtoReg_Mux)
       );
    ///////////////////////////////////////////
    // >>>> ID/EX buffer
    ////control
    reg [`WORD_SIZE-1:0] pc_buffer_ID_EX;
    reg [`WORD_SIZE-1:0] SignExtendedImm;
    reg [`WORD_SIZE-1:0] ZeroExtendedImm;
    reg [`WORD_SIZE-1:0] ShiftedImm;
    reg [`WORD_SIZE-1:0] buffer_A;
    reg [`WORD_SIZE-1:0] buffer_B;
    reg [1:0] MemtoReg_EX;
    reg RegWrite_EX;
    reg isWWD_EX;
    reg MemRead_EX;
    reg MemWrite_EX;
    reg Branch_EX;
    reg Jump_EX;
    reg PCSrc_EX;
    reg isComplete_EX;
    reg isHalt_EX;
    reg [1:0] ALUSrc_EX;
    reg [3:0] ALUOp_EX;
    reg [1:0] buffer_dest_reg_EX;
    reg [11:0] target;
    always @(negedge reset_n or posedge clk) begin
        if(!reset_n ||stall_enable|| Jump_EX ||(Branch_EX && BranchCond)) begin
            SignExtendedImm <= 0;
            ZeroExtendedImm <= 0;
            ShiftedImm <= 0;
            buffer_A <= 0;
            buffer_B <= 0;
            pc_buffer_ID_EX <= 0;
            buffer_dest_reg_EX<=0;
            target <=0;
            MemtoReg_EX<=0;
            RegWrite_EX<=0;
            isWWD_EX<=0;
            MemRead_EX<=0;
            MemWrite_EX<=0;
            Branch_EX<=0;
            Jump_EX<=0;
            ALUSrc_EX<=0;
            ALUOp_EX<=0;
            isComplete_EX <=0;
            PCSrc_EX <=0;
            isHalt_EX <=0;
        end
        else begin
            SignExtendedImm <= {{8{imm[7]}},imm};
            ZeroExtendedImm <= {{8{1'b0}},imm};
            ShiftedImm <= imm<<8;
            buffer_A <= RF_out_A;
            buffer_B <= RF_out_B;
            pc_buffer_ID_EX <= pc_buffer_IF_ID;
            buffer_dest_reg_EX<=RegDst_Mux;
            target <= IR[11:0];
            MemtoReg_EX <=MemtoReg;
            RegWrite_EX <=RegWrite;
            isWWD_EX<=isWWD;
            MemRead_EX<=MemRead;
            MemWrite_EX<=MemWrite;
            Branch_EX<=Branch;
            Jump_EX<=Jump;
            ALUSrc_EX<=ALUSrc;
            ALUOp_EX<=ALUOp;
            isComplete_EX <=isComplete;
            PCSrc_EX <= PCSrc;
            isHalt_EX <= isHalt;
        end
    end
    // <<<< ID/EX buffer
    ///////////////////////////////////////////
    //EX
    wire [`WORD_SIZE-1:0] ALUSrc_Mux;
    assign targetAddress = {pc_buffer_ID_EX[15:12],target[11:0]};
    assign    ALUSrc_Mux = (ALUSrc_EX==0) ? buffer_B :  // mux for ALU second input
              (ALUSrc_EX==1) ? ShiftedImm :
              (ALUSrc_EX==2) ? SignExtendedImm :
              ZeroExtendedImm; //(ALUSrc_EX==3)
    ALU alu(
            .A(buffer_A),
            .B(ALUSrc_Mux),
            .OP(ALUOp_EX),
            .C(resultOfALU),
            .bcond(BranchCond)
        );
    /////////////////////////////////////////
    //>>EX/MEM buffer
    reg [`WORD_SIZE-1:0] ALUOut;
    reg [1:0] buffer_dest_reg_MEM;
    reg [`WORD_SIZE-1:0] buffer_write_data;
    reg [`WORD_SIZE-1:0] pc_buffer_EX_MEM;
    reg [`WORD_SIZE-1:0] MEM_rs_for_WWD;
    reg [1:0] MemtoReg_MEM;
    reg RegWrite_MEM;
    reg isWWD_MEM;
    reg MemRead_MEM;
    reg MemWrite_MEM;
    reg isComplete_MEM;
    reg isHalt_MEM;
    always @(negedge reset_n or posedge clk) begin
        if(!reset_n) begin
            ALUOut <= 0;
            buffer_dest_reg_EX <=0;
            buffer_write_data <=0;
            pc_buffer_EX_MEM <= 0;
            MemtoReg_MEM <= 0;
            RegWrite_MEM <= 0;
            isWWD_MEM<= 0;
            MemRead_MEM<= 0;
            MemWrite_MEM<= 0;
            isComplete_MEM<=0;
            MEM_rs_for_WWD <=0 ;
            isHalt_MEM <=0;
        end
        else  begin
            ALUOut <= resultOfALU;
            buffer_dest_reg_MEM <= buffer_dest_reg_EX;
            buffer_write_data <= buffer_B;
            pc_buffer_EX_MEM <= pc_buffer_ID_EX;
            MemtoReg_MEM <=MemtoReg_EX;
            RegWrite_MEM <=RegWrite_EX;
            isWWD_MEM<=isWWD_EX;
            MemRead_MEM<=MemRead_EX;
            MemWrite_MEM<=MemWrite_EX;
            isComplete_MEM <= isComplete_EX;
            MEM_rs_for_WWD <= buffer_A;
            isHalt_MEM <= isHalt_EX;
        end
    end
    //<<EX/MEM buffer
    /////////////////////////////////////////
    //MEM
    assign d_address = ALUOut;
    assign d_data = (MemWrite_MEM) ? buffer_write_data : 16'bz;
    assign d_readM  = MemRead_MEM;
    assign d_writeM  = MemWrite_MEM;
    /////////////////////////////////////////
    //>>MEM/WB buffer
    reg [`WORD_SIZE-1:0] pc_buffer_MEM_WB;
    reg [`WORD_SIZE-1:0] ALUOut_WB;
    reg [`WORD_SIZE-1:0] MDR;
    reg [`WORD_SIZE-1:0] buffer_for_WWD;
    reg [`WORD_SIZE-1:0] WB_rs_for_WWD;
    reg [1:0] buffer_dest_reg_WB;
    reg [1:0] MemtoReg_WB;
    reg RegWrite_WB;
    reg isWWD_WB;
    reg isComplete_WB;
    reg isHalt_WB;
    always @(negedge reset_n or posedge clk) begin
        if(!reset_n) begin
            ALUOut_WB <= 0;
            pc_buffer_MEM_WB <= 0;
            MDR <= 0;
            buffer_for_WWD <=0;
            buffer_dest_reg_WB <=0;
            MemtoReg_WB <=0;
            RegWrite_WB <=0;
            isWWD_WB<=0;
            isComplete_WB <=0;
            WB_rs_for_WWD <=0;
            isHalt_WB <=0;
        end
        else begin
            ALUOut_WB <= ALUOut;
            pc_buffer_MEM_WB <= pc_buffer_EX_MEM;
            MDR <=d_data;
            buffer_for_WWD <=buffer_write_data;
            buffer_dest_reg_WB <=buffer_dest_reg_MEM;
            MemtoReg_WB <=MemtoReg_MEM;
            RegWrite_WB <=RegWrite_MEM;
            isWWD_WB<=isWWD_MEM;
            isComplete_WB <= isComplete_MEM;
            WB_rs_for_WWD <= MEM_rs_for_WWD;
            isHalt_WB <=isHalt_MEM;
        end
    end
    //<<MEM/WB buffer
    /////////////////////////////////////////
    // WB
    assign MemtoReg_Mux = (MemtoReg_WB==2'd0) ? MDR :
           (MemtoReg_WB == 2'd1) ? ALUOut_WB : pc_buffer_MEM_WB;
    assign is_halted = isHalt_WB;
    always @(negedge reset_n or posedge clk) begin
        if(!reset_n) begin
            output_port <=0;
            num_inst <= 0;
        end
        else begin
            if(isWWD_WB) begin
                output_port <= WB_rs_for_WWD;
            end
            if(isComplete_WB) begin
                num_inst <= num_inst +1;
            end
        end
    end
    //////////////////////////////////////////
    //Stall control
    wire branch_decision;
    assign branch_decision = Branch_EX && BranchCond;
    stall_flush sf(
                    .rs_ID(rs),
                    .rt_ID(rt),
                    .dest_EX(buffer_dest_reg_EX),
                    .dest_MEM(buffer_dest_reg_MEM),
                    .dest_WB(buffer_dest_reg_WB),
                    .use_rs_ID(use_rs),
                    .use_rt_ID(use_rt),
                    .RegWrite_EX(RegWrite_EX),
                    .RegWrite_MEM(RegWrite_MEM),
                    .RegWrite_WB(RegWrite_WB),
                    .Jump(Jump_EX),
                    .Branch(branch_decision),
                    .isJAL(isJAL),
                    .stall_enable(stall_enable)
                );
endmodule
