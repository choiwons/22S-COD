`define WORD_SIZE 16
`define RegDst control_bit[0]
`define Jump control_bit[1]
`define Branch control_bit[2]
`define MemRead control_bit[3]
`define MemtoReg control_bit[4]
`define ALUOp control_bit[8:5]
`define MemWrite control_bit[9]
`define ALUSrc control_bit[10]
`define RegWrite control_bit[11]
`define isWWD control_bit[12]
module data_path(instruction,control_bit,reset_n,isReady, PC, output_port, isComplete,initComplete);
    input [`WORD_SIZE-1:0] instruction;
    input [12:0] control_bit;
    input reset_n;
    input isReady;
    input initComplete;
    output reg [15:0] PC;
    output reg [15:0] output_port;
    output reg isComplete;

    wire [`WORD_SIZE-1:0] MUXbeforeALU;
    wire [1:0] MUXbeforeRF;
    wire [`WORD_SIZE-1:0] writeData;

    wire [`WORD_SIZE-1:0] regData1;
    wire [`WORD_SIZE-1:0] regData2;
    wire [`WORD_SIZE-1:0] resultOfALU;
    wire isOverFlow;
    wire ALUReady;
    wire readyToRead;
    assign    MUXbeforeALU = (control_bit[10:9]==2'b00) ? {{8{instruction[7]}},instruction[7:0]} :
              (control_bit[10:9]==2'b01) ? instruction[7:0]<<8  :
              (control_bit[10:9]==2'b10) ? regData2 : regData2;
    assign    MUXbeforeRF = (control_bit[0]) ? instruction[9:8] : instruction[7:6] ;

    RF rf(
           .RegWrite(control_bit[11]),
           .clk(clk),
           .reset_n(reset_n),
           .addr1(instruction[11:10]), //rs
           .addr2(instruction[9:8]),   //rt
           .addr3(MUXbeforeRF),   //write address
           .readyToRead(readyToRead),
           .data1(regData1),
           .data2(regData2),
           .data3(writeData),
           .isReady(isReady),
           .ALUReady(ALUReady)
       );
    ALU alu(
            .A(regData1),
            .B(MUXbeforeALU),
            .Cin(1'b0),
            .isReady(readyToRead),
            .OP(`ALUOp),
            .C(writeData),
            .Cout(isOverFlow),
            .writeReady(ALUReady)
        );
    always @(posedge initComplete) begin
        isComplete <= 0;
    end

    always @(negedge reset_n  or posedge ALUReady) begin
        if(!reset_n) begin
            output_port <= 0;
            PC <= 0;
            isComplete <= 0;
        end
        else if(`isWWD) begin
            PC <= (control_bit[1]) ? {PC[15:12], instruction[11:0]}: PC+1;
            output_port <= regData1;
            isComplete <= 1;
        end
        else begin
            PC <= (control_bit[1]) ? {PC[15:12], instruction[11:0]}: PC+1;
            output_port <= regData1;
            isComplete <=1;
        end
    end

endmodule
