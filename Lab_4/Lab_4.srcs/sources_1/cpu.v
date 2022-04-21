///////////////////////////////////////////////////////////////////////////
// MODULE: CPU for TSC microcomputer: cpu.v
// Author:
// Description:

// DEFINITIONS
`define WORD_SIZE 16    // data and address word size

// INCLUDE files
`include "opcodes.v"    // "opcode.v" consists of "define" statements for
// the opcodes and function codes for all instructions

// MODULE DECLARATION
module cpu (
        output reg readM,                       // read from memory
        output [`WORD_SIZE-1:0] address,    // current address for data
        inout [`WORD_SIZE-1:0] data,        // data being input or output
        input inputReady,                   // indicates that data is ready from the input port
        input reset_n,                      // active-low RESET signal
        input clk,                          // clock signal

        // for debuging/testing purpose
        output [`WORD_SIZE-1:0] num_inst,   // number of instruction during execution
        output [`WORD_SIZE-1:0] output_port // this will be used for a "WWD" instruction
    );


    wire [15:0] instruction;
    wire RegDst;
    wire Jump;
    wire [3:0] ALUOp;
    wire [1:0] ALUSrc;
    wire RegWrite;
    wire isWWD;
    wire PCwrite;
    //////////////////////////////////////////////////////
    control_path cp(
                     .opcode(instruction[15:12]),
                     .funct(instruction[5:0]),
                     .RegDst(RegDst),
                     .Jump(Jump),
                     .ALUOp(ALUOp),
                     .ALUSrc(ALUSrc),
                     .RegWrite(RegWrite),
                     .isWWD(isWWD),
                     .PCwrite(PCwrite));
    data_path dp(
                  .instruction(instruction),
                  .data(data),
                  .inputReady(inputReady),
                  .RegDst(RegDst),
                  .Jump(Jump),
                  .ALUOp(ALUOp),
                  .ALUSrc(ALUSrc),
                  .RegWrite(RegWrite),
                  .isWWD(isWWD),
                  .PCwrite(PCwrite),
                  .clk(clk),
                  .reset_n(reset_n),
                  .output_port(output_port),
                  .num_inst(num_inst),
                  .PC(address));

    ///////////////////////////////////////////////////////
    //every posedge clk request input, and if inputReady signal is high, reset request signal(readM) to low
    always @(negedge reset_n or posedge clk or posedge inputReady) begin
        if(!reset_n) begin
            readM <= 0;
        end
        else if(inputReady) begin
            readM <= 0;
        end
        else begin
            readM <= 1;
        end
    end
endmodule
//////////////////////////////////////////////////////////////////////////
