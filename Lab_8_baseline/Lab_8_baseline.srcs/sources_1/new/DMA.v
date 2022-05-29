`define WORD_SIZE 16
/*************************************************
* DMA module (DMA.v)
* input: clock (CLK), bus request (BR) signal,
*        data from the device (edata), and DMA command (cmd)
* output: bus grant (BG) signal
*         READ signal
*         memory address (addr) to be written by the device,
*         offset device offset (0 - 2)
*         data that will be written to the memory
*         interrupt to notify DMA is end
* You should NOT change the name of the I/O ports and the module name
* You can (or may have to) change the type and length of I/O ports
* (e.g., wire -> reg) if you want
* Do not add more ports!
*************************************************/

module DMA (
        input CLK, BG,
        input [4 * `WORD_SIZE - 1 : 0] edata,
        input cmd,
        output reg BR, READ,
        output [`WORD_SIZE - 1 : 0] addr,
        output [4 * `WORD_SIZE - 1 : 0] data,
        output reg [1:0] offset,
        output interrupt);
    /* Implement your own logic */
    reg [2:0] write_counter;

    assign addr = (offset == 0) ? 16'h01f4 :
           (offset == 1)?  16'h01f8 : 16'h01fc;
    assign data = edata;

    always @(posedge CLK) begin
        write_counter <= (!BG) ? 0 :
                      (write_counter == 0) ? 1 :
                      (write_counter == 1) ? 2 : 0;

        offset <= (!BG) ? 0 :
               (write_counter == 2) ? offset+1 : offset;
        if(offset==2&&write_counter==2) begin
            BR <= 0;
            READ <= 0;
        end
    end
    always @(posedge BG) begin
        READ <=1;
    end
    always @(posedge cmd) begin
        BR<=1;
    end
endmodule
