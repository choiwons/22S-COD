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
        output readM,                       // read from memory
        output [`WORD_SIZE-1:0] address,    // current address for data
        inout [`WORD_SIZE-1:0] data,        // data being input or output
        input inputReady,                   // indicates that data is ready from the input port
        input reset_n,                      // active-low RESET signal
        input clk,                          // clock signal

        // for debuging/testing purpose
        output [`WORD_SIZE-1:0] num_inst,   // number of instruction during execution
        output [`WORD_SIZE-1:0] output_port // this will be used for a "WWD" instruction
    );

    wire [12:0] control_bit;
    reg [15:0] instruction;

    control_path cp(
                     .inst(instruction),
                     .control_bit(control_bit));
    data_path dp(
                  .instruction(instruction),
                  .inputReady(inputReady),
                  .clk(clk),
                  .control_bit(control_bit),
                  .reset_n(reset_n),
                  .output_port(output_port),
                  .readM(readM),
                  .num_inst(num_inst),
                  .PC(address));


    always @(negedge reset_n or posedge inputReady) begin
        if(!reset_n) begin
            instruction <=0;
        end
        else begin
            instruction <= data;
        end
    end
endmodule
//////////////////////////////////////////////////////////////////////////
