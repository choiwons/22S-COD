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
        output reg [`WORD_SIZE-1:0] num_inst,   // number of instruction during execution
        output [`WORD_SIZE-1:0] output_port // this will be used for a "WWD" instruction
    );
    wire [12:0] control_bit;
    wire isReadyforControl;
    wire isComplete;
    control_path cp(
                     .instruction(data),
                     .inputReady(inputReady),
                     .isReady(isReadyforControl),
                     .control_bit(control_bit)
                 );
    data_path dp(
                  .instruction(data),
                  .control_bit(control_bit),
                  .clk(clk),
                  .reset_n(reset_n),
                  .output_port(output_port),
                  .PC(address),
                  .isReady(isReadyforControl),
                  .isComplete(isComplete)
              );

    // ... fill in the rest of the code
    always @(posedge clk or posedge isComplete or negedge reset_n) begin
        if(!reset_n) begin
            num_inst <=0;
            readM <=0;
        end
        else begin
            if(isComplete) begin
                num_inst <= num_inst +1;
                readM <= 0;
            end
            else begin
                num_inst <= num_inst;
                readM <= 1;
            end
        end
    end
endmodule
//////////////////////////////////////////////////////////////////////////
