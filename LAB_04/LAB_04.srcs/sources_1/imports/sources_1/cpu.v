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

    wire [12:0] control_bit;
    reg [15:0] instruction;

    control_path cp(
                     .inst(instruction),
                     .control_bit(control_bit));
    data_path dp(
                  .instruction(instruction),
                  .inputReady(inputReady),
                  .control_bit(control_bit),
                  .reset_n(reset_n),
                  .output_port(output_port),
                  .num_inst(num_inst),
                  .PC(address));

    always @(negedge reset_n or posedge clk or posedge inputReady) begin
        if(!reset_n) begin
            readM <=0;
            instruction <=instruction;
        end
        else begin
            if(inputReady) begin
                readM <= 0;
                instruction <= data;
            end
            else begin
                readM <= 1;
                instruction <= instruction;
            end
        end
    end
endmodule
//////////////////////////////////////////////////////////////////////////
