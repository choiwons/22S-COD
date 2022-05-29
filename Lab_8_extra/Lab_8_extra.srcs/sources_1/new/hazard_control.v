`include <opcodes.v>
module hazard_control(
        input reset_n,
        input clk,
        input [1:0] rs_ID,
        input [1:0] rt_ID,
        input [1:0] dest_EX,
        input [1:0] dest_MEM,
        input [1:0] dest_WB,
        input use_rs_ID,
        input use_rt_ID,
        input RegWrite_EX,
        input RegWrite_MEM,
        input RegWrite_WB,
        input Branch,
        input Jump,
        input Jump_MEM,
        input Jump_EX,
        input Branch_EX,
        input Branch_MEM,
        input [`WORD_SIZE-1:0] predicted_address_MEM,
        input [`WORD_SIZE-1:0] NextPC,
        input i_ready,
        input d_ready,
        input MemWrite_MEM,
        input MemRead_MEM,
        input valid_inst_EX,
        input valid_inst_ID,
        input BR,
        input use_memory,
        output stall_IF,
        output stall_ID,
        output stall_EX,
        output stall_MEM,
        output stall_WB,
        output flush_IF,
        output flush_ID,
        output flush_EX,
        output flush_MEM,
        output flush_WB,
        output stall_DMA,
        output reg BG
    );
    reg DMA_interrupt;
    wire data_hazard;
    wire control_hazard;
    wire ls_hazard;
    wire fetch_hazard;
    wire [3:0] hazards;
    wire [1:0] valid_inst;
    reg [4:0] stall;
    reg [4:0] flush;
    assign valid_inst = {valid_inst_ID,valid_inst_EX}; // determine if those buffers are signals of bubble or not
    assign {flush_IF,flush_ID,flush_EX,flush_MEM,flush_WB} =flush; //flush signal for each stage buffer
    assign {stall_IF,stall_ID,stall_EX,stall_MEM,stall_WB} =stall; //stall signal for each stage buffer

    assign control_hazard = (Jump_MEM||Branch_MEM)&&(predicted_address_MEM!=NextPC);  // 1 : miss prediction flush
    assign data_hazard = (rs_ID==dest_EX&&use_rs_ID&&RegWrite_EX)
           || (rt_ID==dest_EX&&use_rt_ID&&RegWrite_EX)
           || (rs_ID==dest_MEM&&use_rs_ID&&RegWrite_MEM)
           || (rt_ID==dest_MEM&&use_rt_ID&&RegWrite_MEM)
           || (rs_ID==dest_WB&&use_rs_ID&&RegWrite_WB)
           || (rt_ID==dest_WB&&use_rt_ID&&RegWrite_WB);
    assign fetch_hazard = (!i_ready); //instruction memory hazard
    assign ls_hazard = (MemRead_MEM&&!d_ready)||(MemWrite_MEM&&!d_ready); //data memory hazard
    assign hazards = {fetch_hazard,ls_hazard,control_hazard,data_hazard};
    /////////////////////////////
    //for DMA
    assign stall_DMA = BR;
    always @(negedge reset_n or posedge clk or negedge BR) begin
        if(BR&&!use_memory) begin
            BG <= 1;
        end
        else begin
            BG <=0;
        end
    end
    ////////////////////////////
    always @(*) begin
        if(((MemRead_MEM&&(d_ready == 0))|| MemWrite_MEM) && BG == 1) begin
            flush = 5'b00001;
            stall = 5'b11110;
        end
        else begin
            case(hazards)
                4'b0000: begin
                    flush = 5'b00000;
                    stall = 5'b00000;
                end
                4'b0001 : begin
                    flush = 5'b00100;
                    stall = 5'b11000;
                end
                4'b0010 : begin
                    flush = 5'b11110;
                    stall = 5'b00000;
                end
                4'b0011 : begin
                    flush = 5'b11110;
                    stall = 5'b00000;
                end
                4'b0100 : begin
                    case(valid_inst)
                        2'b00: begin
                            flush = 5'b00001;
                            stall = 5'b00010;
                        end
                        2'b01: begin
                            flush = 5'b00001;
                            stall = 5'b00110;
                        end
                        2'b10: begin
                            flush = 5'b00001;
                            stall = 5'b00010;
                        end
                        2'b11: begin
                            flush = 5'b00001;
                            stall = 5'b11110;
                        end
                    endcase
                end
                4'b0101 : begin
                    flush = 5'b00001;
                    stall = 5'b11110;
                end
                4'b1000 : begin
                    flush = 5'b01000;
                    stall = 5'b10000;
                end
                4'b1001 : begin
                    flush = 5'b00100;
                    stall = 5'b11000;
                end
                4'b1010 : begin
                    flush = 5'b00001;
                    stall = 5'b11110;
                end
                4'b1011 : begin
                    flush = 5'b00001;
                    stall = 5'b11110;
                end
                4'b1100 : begin
                    case(valid_inst)
                        2'b00: begin
                            flush = 5'b00001;
                            stall = 5'b11110;
                        end
                        2'b01: begin
                            flush = 5'b00001;
                            stall = 5'b11110;
                        end
                        2'b10: begin
                            flush = 5'b01001;
                            stall = 5'b10010;
                        end
                        2'b11: begin
                            flush = 5'b00001;
                            stall = 5'b11110;
                        end
                    endcase
                end
                4'b1101 : begin
                    flush = 5'b00001;
                    stall = 5'b11110;
                end
            endcase
        end
    end
endmodule
