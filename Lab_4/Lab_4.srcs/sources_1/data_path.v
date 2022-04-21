`include "opcodes.v"
module data_path(data,inputReady,instruction,clk,reset_n, RegDst,Jump,ALUOp,ALUSrc,RegWrite,isWWD,PCwrite, num_inst, PC, output_port);
    output reg [`WORD_SIZE-1:0] instruction;
    input clk;
    input reset_n;
    input RegDst;
    input Jump;
    input [3:0] ALUOp;
    input [1:0] ALUSrc;
    input RegWrite;
    input isWWD;
    input PCwrite;
    input [15:0] data;
    input inputReady;
    output reg [15:0] num_inst;
    output reg [15:0] PC;
    output reg [15:0] output_port;
    /////////////////////////////////////////
    //About IR
    always @(negedge reset_n or posedge inputReady) begin
        if(!reset_n) begin
            instruction <= 0;
        end
        else begin
            instruction <=data;
        end
    end
    //////////////////////////////////////////
    //About RF
    wire [1:0] MUXbeforeRF;
    wire [1:0] rs;
    wire [1:0] rt;
    wire [1:0] rd;
    wire [7:0] imm;
    wire [`WORD_SIZE-1:0] writeData;
    wire [`WORD_SIZE-1:0] regData1;
    wire [`WORD_SIZE-1:0] regData2;
    assign imm = instruction[7:0];
    assign rs = instruction[11:10];
    assign rt = instruction[9:8];
    assign rd = instruction[7:6];
    assign MUXbeforeRF = (RegDst) ? rt : rd ; //mux for RF write register
    RF rf(
           .RegWrite(RegWrite),
           .reset_n(reset_n),
           .clk(clk),
           .addr1(rs),
           .addr2(rt),
           .addr3(MUXbeforeRF),
           .data1(regData1),
           .data2(regData2),
           .data3(writeData)
       );
    ///////////////////////////////////////////
    //About ALU
    wire [`WORD_SIZE-1:0] MUXbeforeALU;
    wire isOverFlow;
    assign    MUXbeforeALU = (ALUSrc==2'b00) ? {{8{imm[7]}},imm} :  // mux for ALU second input
              (ALUSrc==2'b01) ? imm<<8  :
              (ALUSrc==2'b10) ? regData2 : regData2;
    ALU alu(
            .A(regData1),
            .B(MUXbeforeALU),
            .Cin(1'b0),
            .OP(ALUOp),
            .C(writeData),
            .Cout(isOverFlow)
        );
    //////////////////////////////////////////
    //About PC
    wire [11:0] targetAddress;
    assign targetAddress = instruction[11:0];
    always @(negedge reset_n  or posedge clk) begin //every posedge clk, if PCwrite is on, update PC.
        if(!reset_n) begin
            PC <= 0;
        end
        else if(PCwrite)begin
            PC <= (Jump) ? {PC[15:12], targetAddress}: PC+1;
        end
    end
    /////////////////////////////////////////
    //About output
    //num_inst : if PCwrite is high, this means it's right instruction. Then, +1 to num_inst
    //output_port : if isWWD is high, this means it's WWD instruction. Then, operate output_port <- $rt
    always @(negedge reset_n or posedge clk) begin
        if(!reset_n) begin
            output_port <=0;
            num_inst <=0;
        end
        else begin
            if(isWWD) begin
                output_port <= regData1;
            end
            if(PCwrite) begin
                num_inst <= num_inst +1;
            end
        end
    end
endmodule
