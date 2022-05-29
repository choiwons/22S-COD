`define LINE_SIZE 64
`define ENTITY_SIZE 77
module i_cache(
        inout [`LINE_SIZE-1:0] i_data,
        input reset_n,
        input clk,
        input [`WORD_SIZE-1:0] PC,
        input flush,
        input stall,
        output [`WORD_SIZE-1:0] i_address,
        output reg i_readM,
        output [`WORD_SIZE-1:0] i_cache_data,
        output i_ready
    );
    reg [`ENTITY_SIZE:0] entities [3:0]; // {valid bit, idx, data line}
    reg [3:0] fetch_counter;
    /////////////////////////////////
    wire target_valid;
    wire [11:0] target_tag;
    wire [`LINE_SIZE-1:0] target_block;
    wire [`WORD_SIZE-1:0] target_word;
    wire [11:0]tag;
    wire [1:0] idx;
    wire [1:0] bo;
    wire hit;
    wire miss;
    ////////////////////////////////
    assign tag= PC[`WORD_SIZE-1:4];
    assign idx = PC[3:2];
    assign bo = PC[1:0];
    assign target_valid = entities[idx][`ENTITY_SIZE-1];
    assign target_tag = entities[idx][`ENTITY_SIZE-2:4*`WORD_SIZE];
    assign target_block = entities[idx][`LINE_SIZE-1:0];
    assign target_word = (bo==2'b11) ? entities[idx][`WORD_SIZE-1:0] :
           (bo==2'b10) ? entities[idx][2*`WORD_SIZE-1:`WORD_SIZE]:
           (bo==2'b01) ? entities[idx][3*`WORD_SIZE-1:2*`WORD_SIZE]:
           entities[idx][4*`WORD_SIZE-1:3*`WORD_SIZE];
    ////////////////////////////////
    assign i_address = {PC[15:2],2'b0};
    assign i_ready = hit||(i_readM && fetch_counter == 3'd2) ? 1 : 0;
    assign i_cache_data = (hit) ? target_word :
           (fetch_counter==3'd2)&&(bo==2'b11) ? i_data[`WORD_SIZE-1:0] :
           (fetch_counter==3'd2)&&(bo==2'b10) ? i_data[2*`WORD_SIZE-1:`WORD_SIZE]:
           (fetch_counter==3'd2)&&(bo==2'b01) ? i_data[3*`WORD_SIZE-1:2*`WORD_SIZE]:
           (fetch_counter==3'd2)&&(bo==2'b00) ? i_data[4*`WORD_SIZE-1:3*`WORD_SIZE]: `WORD_SIZE'bz;
    ////////////////////////////////
    assign hit = (target_tag==tag)&&target_valid;
    //////////////////////////////////////////////////
    //for counter
    always @(negedge reset_n or posedge clk) begin
        if(!reset_n) begin
            fetch_counter <= 0;
        end
        else begin
            fetch_counter <= (!i_readM) ? 3'd0 :
                          (fetch_counter == 3'd0) ? 3'd1 :
                          (fetch_counter == 3'd1) ? 3'd2 : 3'd0;
            if(i_readM && fetch_counter == 3'd2) begin
                entities[idx] <= {1'b1,tag,i_data};
                i_readM <=0;
            end
        end
    end
    /////////////////////////////////////////////////
    //for control i_readM signal
    always @(negedge reset_n or posedge clk) begin
        if(!reset_n) begin
            entities[0] <= `ENTITY_SIZE'b0;
            entities[1] <= `ENTITY_SIZE'b0;
            entities[2] <= `ENTITY_SIZE'b0;
            entities[3] <= `ENTITY_SIZE'b0;
        end
        if (!hit&&(fetch_counter != 3'd2)) begin
            i_readM <= 1;
        end
    end
endmodule
