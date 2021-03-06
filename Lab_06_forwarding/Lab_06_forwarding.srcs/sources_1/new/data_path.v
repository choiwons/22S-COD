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
    wire [`WORD_SIZE-1:0] targetAddress;
    wire [`WORD_SIZE-1:0] resultOfALU;
    wire [`WORD_SIZE-1:0] PCSrc_MUX;
    wire [`WORD_SIZE-1:0] Jump_target;
    wire [`WORD_SIZE-1:0] Branch_target;
    wire [`WORD_SIZE-1:0] PCPlusOne;
    wire [`WORD_SIZE-1:0] NextPC;
    wire [1:0] ALUSrc_A;
    wire [1:0] ALUSrc_B;
    wire BranchCond;
    wire stall_enable;
    //////////////////////////////////////////
    //reg
    reg [`WORD_SIZE-1:0] PC;
    //////////////////////////////////////////
    //PC update
    assign PCPlusOne = PC + 1;
    assign Jump_target = (Jump_MEM) ? targetAddress : pc_buffer_EX_MEM;
    assign PCSrc_MUX = (PCSrc_MEM) ? buffer_A_MEM : Jump_target;
    assign Branch_target = pc_buffer_EX_MEM + SignExtendedImm_MEM;
    assign NextPC = (Branch_MEM&&BranchCond_MEM) ? Branch_target : PCSrc_MUX;
    always @(negedge reset_n  or posedge clk) begin //every posedge clk, if PCwrite is on, update PC.
        if(!reset_n) begin
            PC <= 0;
        end
        else if(!stall_enable) begin
            if(flush_enable) begin
                PC <= NextPC;
            end
            else begin
                PC <= predicted_address;
            end
        end
    end
    /////////////////////////////////////////
    //IF
    assign i_address = PC;
    assign instruction = IR;
    /////////////////////////////////////////
    //>>> IF/ID buffer
    reg [`WORD_SIZE-1:0] pc_buffer_IF_ID;
    reg [`WORD_SIZE-1:0] predicted_address_ID;
    reg [`WORD_SIZE-1:0] IR;
    always@(negedge reset_n or posedge clk) begin
        if(!reset_n || flush_enable) begin
            IR <=`INST_BUB;
            pc_buffer_IF_ID <= 0;
            predicted_address_ID <=0;
        end
        else if(!stall_enable) begin
            IR<= i_data;
            pc_buffer_IF_ID <= PCPlusOne;
            predicted_address_ID <= predicted_address;
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
    wire [`WORD_SIZE-1:0] SignExtendedImm;
    wire [`WORD_SIZE-1:0] ZeroExtendedImm;
    wire [`WORD_SIZE-1:0] ShiftedImm;
    wire [`WORD_SIZE-1:0] ALUSrc_Mux;
    wire [`WORD_SIZE-1:0] F_ALUSrc_B_Mux;
    wire [`WORD_SIZE-1:0] latest_rs;
    wire [`WORD_SIZE-1:0] latest_rt;
    assign SignExtendedImm = {{8{imm[7]}},imm};
    assign ZeroExtendedImm = {{8{1'b0}},imm};
    assign ShiftedImm = imm<<8;
    assign imm = IR[7:0];
    assign rs = IR[11:10];
    assign rt = IR[9:8];
    assign rd = IR[7:6];
    assign latest_rs = (ALUSrc_A == 2'd0) ? RF_out_A :
           (ALUSrc_A == 2'd1) ? resultOfALU:
           (ALUSrc_A == 2'd2) ? MemtoReg_Mux : MemtoReg_WB_result;
    assign latest_rt = (ALUSrc_B == 2'd0) ? RF_out_B :
           (ALUSrc_B == 2'd1) ? resultOfALU:
           (ALUSrc_B == 2'd2) ? MemtoReg_Mux : MemtoReg_WB_result;
    assign RegDst_Mux = (RegDst==2'd2) ? 2'd2 :
           (RegDst == 2'd0) ? rt : rd;
    assign ALUSrc_Mux = (ALUSrc==0) ? latest_rt :  // mux for ALU second input
           (ALUSrc==1) ? ShiftedImm :
           (ALUSrc==2) ? SignExtendedImm :
           ZeroExtendedImm; //(ALUSrc==3)
    RF rf(
           .RegWrite(RegWrite_WB),
           .reset_n(reset_n),
           .clk(clk),
           .addr1(rs),
           .addr2(rt),
           .addr3(buffer_dest_reg_WB),
           .data1(RF_out_A),
           .data2(RF_out_B),
           .data3(MemtoReg_WB_result)
       );
    ///////////////////////////////////////////
    // >>>> ID/EX buffer
    ////control
    reg [`WORD_SIZE-1:0] pc_buffer_ID_EX;
    reg [`WORD_SIZE-1:0] predicted_address_EX;
    reg [`WORD_SIZE-1:0] SignExtendedImm_EX;
    reg [`WORD_SIZE-1:0] buffer_A;
    reg [`WORD_SIZE-1:0] buffer_B;
    reg [`WORD_SIZE-1:0] ALU_input_A;
    reg [`WORD_SIZE-1:0] ALU_input_B;
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
        if(!reset_n ||stall_enable|| flush_enable) begin
            predicted_address_EX <=0;
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
            ALU_input_A <=0;
            ALU_input_B <=0;
            SignExtendedImm_EX <=0;
        end
        else begin
            predicted_address_EX <=predicted_address_ID;
            buffer_A <= latest_rs;
            buffer_B <= latest_rt;
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
            ALU_input_A <=latest_rs;
            ALU_input_B <=ALUSrc_Mux;
            SignExtendedImm_EX <= SignExtendedImm;
        end
    end
    // <<<< ID/EX buffer
    ///////////////////////////////////////////
    //EX
    ALU alu(
            .A(ALU_input_A),
            .B(ALU_input_B),
            .OP(ALUOp_EX),
            .C(resultOfALU),
            .bcond(BranchCond)
        );
    /////////////////////////////////////////
    //>>EX/MEM buffer
    reg [`WORD_SIZE-1:0] ALUOut;
    reg [`WORD_SIZE-1:0] buffer_write_data;
    reg [`WORD_SIZE-1:0] pc_buffer_EX_MEM;
    reg [`WORD_SIZE-1:0] MEM_rs_for_WWD;
    reg [`WORD_SIZE-1:0] SignExtendedImm_MEM;
    reg [`WORD_SIZE-1:0] predicted_address_MEM;
    reg [1:0] buffer_dest_reg_MEM;
    reg [1:0] MemtoReg_MEM;
    reg RegWrite_MEM;
    reg Jump_MEM;
    reg Branch_MEM;
    reg BranchCond_MEM;
    reg PCSrc_MEM;
    reg [`WORD_SIZE-1:0] buffer_A_MEM;
    reg isWWD_MEM;
    reg MemRead_MEM;
    reg MemWrite_MEM;
    reg isComplete_MEM;
    reg isHalt_MEM;
    reg [11:0] target_MEM;
    always @(negedge reset_n or posedge clk) begin
        if(!reset_n||flush_enable) begin
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
            Jump_MEM <=0;
            Branch_MEM <=0;
            BranchCond_MEM <=0;
            PCSrc_MEM <= 0;
            target_MEM <=0;
            SignExtendedImm_MEM <=0;
            buffer_A_MEM <=0;
            predicted_address_MEM<=0;
        end
        else begin
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
            MEM_rs_for_WWD <= ALU_input_A;
            isHalt_MEM <= isHalt_EX;
            Jump_MEM <=Jump_EX;
            Branch_MEM <=Branch_EX;
            BranchCond_MEM <=BranchCond;
            PCSrc_MEM <= PCSrc_EX;
            target_MEM <= target;
            SignExtendedImm_MEM <=SignExtendedImm_EX;
            buffer_A_MEM <= buffer_A;
            predicted_address_MEM<= predicted_address_EX;
        end
    end
    //<<EX/MEM buffer
    /////////////////////////////////////////
    //MEM
    assign targetAddress = {pc_buffer_EX_MEM[15:12],target_MEM[11:0]};
    assign d_address = ALUOut;
    assign d_data = (MemWrite_MEM) ? buffer_write_data : 16'bz;
    assign d_readM  = MemRead_MEM;
    assign d_writeM  = MemWrite_MEM;
    assign MemtoReg_Mux = (MemtoReg_MEM==2'd0) ? d_data :
           (MemtoReg_MEM == 2'd1) ? ALUOut : pc_buffer_EX_MEM;
    /////////////////////////////////////////
    //>>MEM/WB buffer
    reg [`WORD_SIZE-1:0] pc_buffer_MEM_WB;
    reg [`WORD_SIZE-1:0] ALUOut_WB;
    reg [`WORD_SIZE-1:0] MDR;
    reg [`WORD_SIZE-1:0] buffer_for_WWD;
    reg [`WORD_SIZE-1:0] WB_rs_for_WWD;
    reg [1:0] buffer_dest_reg_WB;
    reg RegWrite_WB;
    reg isWWD_WB;
    reg isComplete_WB;
    reg isHalt_WB;
    reg [`WORD_SIZE-1:0] MemtoReg_WB_result;
    always @(negedge reset_n or posedge clk) begin
        if(!reset_n) begin
            ALUOut_WB <= 0;
            pc_buffer_MEM_WB <= 0;
            MDR <= 0;
            buffer_for_WWD <=0;
            buffer_dest_reg_WB <=0;
            RegWrite_WB <=0;
            isWWD_WB<=0;
            isComplete_WB <=0;
            WB_rs_for_WWD <=0;
            isHalt_WB <=0;
            MemtoReg_WB_result <=0;
        end
        else begin
            ALUOut_WB <= ALUOut;
            pc_buffer_MEM_WB <= pc_buffer_EX_MEM;
            MDR <=d_data;
            buffer_for_WWD <=buffer_write_data;
            buffer_dest_reg_WB <=buffer_dest_reg_MEM;
            RegWrite_WB <=RegWrite_MEM;
            isWWD_WB<=isWWD_MEM;
            isComplete_WB <= isComplete_MEM;
            WB_rs_for_WWD <= MEM_rs_for_WWD;
            isHalt_WB <=isHalt_MEM;
            MemtoReg_WB_result <=MemtoReg_Mux;
        end
    end
    //<<MEM/WB buffer
    /////////////////////////////////////////
    // WB
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
    wire flush_enable;
    hazard_control hc(
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
                       .MemRead_EX(MemRead_EX),
                       .flush_enable(flush_enable),
                       .stall_enable(stall_enable),
                       .Jump_MEM(Jump_MEM),
                       .Branch_MEM(Branch_MEM),
                       .NextPC(NextPC),
                       .predicted_address_MEM(predicted_address_MEM)

                   );
    /////////////////////////////////////////////////
    //prediction
    wire [`WORD_SIZE-1:0] predicted_address;
    wire [`WORD_SIZE-1:0] write_btb;
    assign write_btb = (Branch_MEM)? pc_buffer_EX_MEM +SignExtendedImm_MEM :
           (Jump_MEM) ? PCSrc_MUX : 0;
    predictor p(
                  .pc(PC[7:0]),
                  .write_address(pc_buffer_EX_MEM[7:0]-1'b1),
                  .write_btb(write_btb),
                  .Jump(Jump_MEM),
                  .Branch(Branch_MEM),
                  .BranchCond(BranchCond_MEM),
                  .NextPC(NextPC),
                  .reset_n(reset_n),
                  .clk(clk),
                  .predicted_address(predicted_address)
              );
    //////////////////////////////////////////////////
    //forwarding
    forwarding_control fc(
                           .dest_EX(buffer_dest_reg_EX),
                           .dest_MEM(buffer_dest_reg_MEM),
                           .dest_WB(buffer_dest_reg_WB),
                           .RegWrite_EX(RegWrite_EX),
                           .RegWrite_MEM(RegWrite_MEM),
                           .RegWrite_WB(RegWrite_WB),
                           .rs(rs),
                           .rt(rt),
                           .use_rs(use_rs),
                           .use_rt(use_rt),
                           .ALUSrc_A(ALUSrc_A),
                           .ALUSrc_B(ALUSrc_B)
                       );
endmodule
