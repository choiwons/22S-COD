`define LINE_SIZE 64
`define ENTITY_SIZE 77
module d_cache(
        inout d_data,
        input [`WORD_SIZE-1:0] d_address,
        input [`WORD_SIZE-1:0] write_target_address,
        input [`WORD_SIZE-1:0] write_data,
        input reset_n,
        input clk,
        input MemRead_MEM,
        input MemWrite_MEM,
        input stall_DMA,
        output reg d_readM,
        output reg d_writeM,
        output [`WORD_SIZE-1:0] d_cache_data,
        output d_ready,
        output use_memory
    );
    reg  [`ENTITY_SIZE:0] entities [3:0]; //{valid bit, idx, data line}
    reg [`LINE_SIZE-1:0] write_line;  //wire for write (combinational logic)
    reg [3:0] ls_counter;
    ///////////////////////////
    wire [`LINE_SIZE-1:0] d_data;
    wire [`LINE_SIZE-1:0] target_block;
    wire [`WORD_SIZE-1:0] target_word;
    wire [11:0] target_tag;
    wire [11:0]tag;
    wire [1:0] idx;
    wire [1:0] bo;
    wire target_valid;
    wire hit;
    /////////////////////////////////////////////////
    assign d_address = write_target_address;
    assign tag= write_target_address[`WORD_SIZE-1:4];
    assign idx = write_target_address[3:2];
    assign bo = write_target_address[1:0];
    //////////////////////////////////////////////////
    assign target_valid = entities[idx][`ENTITY_SIZE-1];
    assign target_tag = entities[idx][`ENTITY_SIZE-2:4*`WORD_SIZE];
    assign target_block = entities[idx][`LINE_SIZE-1:0];
    assign target_word = (bo==2'b11) ? entities[idx][`WORD_SIZE-1:0] :
           (bo==2'b10) ? entities[idx][2*`WORD_SIZE-1:`WORD_SIZE]:
           (bo==2'b01) ? entities[idx][3*`WORD_SIZE-1:2*`WORD_SIZE]:
           entities[idx][4*`WORD_SIZE-1:3*`WORD_SIZE];
    ///////////////////////////////////////////////////
    assign d_data = (MemWrite_MEM) ? write_line : `LINE_SIZE'bz;
    assign d_cache_data = ((target_tag == tag)&&target_valid) ? target_word :
           (ls_counter == 3'd2)&&(bo==2'b11) ? d_data[`WORD_SIZE-1:0] :
           (ls_counter == 3'd2)&&(bo==2'b10) ? d_data[2*`WORD_SIZE-1:`WORD_SIZE]:
           (ls_counter == 3'd2)&&(bo==2'b01) ? d_data[3*`WORD_SIZE-1:2*`WORD_SIZE]:
           (ls_counter == 3'd2)&&(bo==2'b00) ? d_data[4*`WORD_SIZE-1:3*`WORD_SIZE]: `WORD_SIZE'bz;
    ///////
    assign hit =(target_tag == tag)&&target_valid;
    assign d_ready = (MemRead_MEM&&(hit))||(MemRead_MEM&&ls_counter == 3'd2) ? 1 :
           (MemWrite_MEM&&(ls_counter==3'd2)) ? 1 : 0;
    assign use_memory = (ls_counter!=0)||d_readM||d_writeM;
    ////////////////////////////////////////////////////
    //combinational logic for write_line
    always @(*) begin
        case(bo)
            2'b11 : begin
                write_line[`WORD_SIZE-1:0] = write_data;
            end
            2'b10 : begin
                write_line[2*`WORD_SIZE-1:`WORD_SIZE] = write_data;
            end
            2'b01 : begin
                write_line[3*`WORD_SIZE-1:2*`WORD_SIZE] = write_data;
            end
            2'b00 : begin
                write_line[4*`WORD_SIZE-1:3*`WORD_SIZE] = write_data;
            end
        endcase
    end
    /////////////////////////////////////////////////
    //for counter
    always @(negedge reset_n or posedge clk) begin
        if(!reset_n) begin
            ls_counter <= 0;
        end
        else begin
            ls_counter <= (!d_readM&&!d_writeM) ? 3'd0 :
                       (ls_counter == 3'd0) ? 3'd1 :
                       (ls_counter == 3'd1) ? 3'd2 : 3'd0;
            if(d_readM && ls_counter == 3'd2) begin
                entities[idx] <= {1'b1,tag,d_data};
                d_readM <=0;
            end
            if(d_writeM && ls_counter == 3'd2) begin
                d_writeM <= 0;
            end
        end
    end
    ////////////////////////////////////////////////
    //for cache update when hit, and logic for enable signal(d_writeM,d_readM)
    always @(negedge reset_n or posedge clk) begin
        if(!reset_n) begin
            entities[0] <= `ENTITY_SIZE'b0;
            entities[1] <= `ENTITY_SIZE'b0;
            entities[2] <= `ENTITY_SIZE'b0;
            entities[3] <= `ENTITY_SIZE'b0;
            d_writeM <=0;
            d_readM <=0;
        end
        else if(stall_DMA)begin

        end
        else begin
            if(MemWrite_MEM)begin //write
                if ((!target_valid||!(target_tag==tag))&&(ls_counter != 3'd2)) //miss
                    d_writeM <=1;
                else if(ls_counter !=3'd2) begin  // hit
                    case(bo)
                        2'b11 : begin
                            entities[idx][`WORD_SIZE-1:0] <= write_data;
                        end
                        2'b10 : begin
                            entities[idx][2*`WORD_SIZE-1:`WORD_SIZE] <= write_data;
                        end
                        2'b01 : begin
                            entities[idx][3*`WORD_SIZE-1:2*`WORD_SIZE] <= write_data;
                        end
                        2'b00 : begin
                            entities[idx][4*`WORD_SIZE-1:3*`WORD_SIZE] <= write_data;
                        end
                    endcase
                    d_writeM <=1;
                end
            end
            else if(MemRead_MEM) begin //Read
                if (!hit&&(ls_counter != 3'd2))
                    d_readM <= 1;
            end
        end
    end
endmodule
