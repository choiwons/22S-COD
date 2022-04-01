`include "opcodes.v"
module data_path(instruction,clk, control_bit,reset_n, num_inst, PC, output_port);
    input [`WORD_SIZE-1:0] instruction;
    input [13:0] control_bit;
    input clk;
    input reset_n;
    output reg [15:0] num_inst;
    output reg [15:0] PC;
    output reg [15:0] output_port;
    //MUX
    wire [`WORD_SIZE-1:0] MUXbeforeALU;
    wire [1:0] MUXbeforeRF;
    wire [`WORD_SIZE-1:0] writeData;
    //Wire
    wire [`WORD_SIZE-1:0] regData1;
    wire [`WORD_SIZE-1:0] regData2;
    wire [`WORD_SIZE-1:0] resultOfALU;
    wire isOverFlow;

    //MUX connection
    assign    MUXbeforeALU = (control_bit[10:9]==2'b00) ? {{8{instruction[7]}},instruction[7:0]} :
              (control_bit[10:9]==2'b01) ? instruction[7:0]<<8  :
              (control_bit[10:9]==2'b10) ? regData2 : regData2;
    assign    MUXbeforeRF = (control_bit[0]) ? instruction[9:8] : instruction[7:6] ;
    //RF, ALU instanciation
    RF rf(
           .RegWrite(control_bit[11]),
           .reset_n(reset_n),
           .clk(clk),
           .addr1(instruction[11:10]), //rs
           .addr2(instruction[9:8]),   //rt
           .addr3(MUXbeforeRF),   //write address
           .data1(regData1),
           .data2(regData2),
           .data3(writeData)
       );
    ALU alu(
            .A(regData1),
            .B(MUXbeforeALU),
            .Cin(1'b0),
            .OP(`ALUOp),
            .C(writeData),
            .Cout(isOverFlow)
        );
    ///////////////////////////
    always @(negedge reset_n  or posedge clk) begin
        if(!reset_n) begin
            output_port <= 0;
            PC <= 0;
            num_inst <= 0;
        end
        else if(`PCwrite)begin
            PC <= (control_bit[1]) ? {PC[15:12], instruction[11:0]}: PC+1;
            output_port <= regData1;
            num_inst <= num_inst + 1;
        end
        else begin
            PC <= PC;
            output_port <= output_port;
            num_inst <=num_inst;
        end
    end
endmodule
