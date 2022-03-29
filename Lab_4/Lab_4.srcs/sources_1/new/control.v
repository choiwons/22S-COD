// module Control(inst, funct, RegDst, Jump, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite);
//     input [3:0] inst;
//     input [5:0] funct;
//     output reg RegDst;
//     output reg Jump;
//     output reg Branch;
//     output reg MemRead;
//     output reg MemtoReg;
//     output reg [3:0] ALUOp;
//     output reg MemWrite;
//     output reg ALUSrc;
//     output reg RegWrite;
//     always @(*) begin
//         case(inst)
//             4'd11 && (funct != 6'd28): begin
//                 RegDst = 1;
//                 Jump = 0;
//                 Branch=0;
//                 MemRead=0;
//                 MemtoReg=0;
//                 ALUOp=4'b0000;
//                 MemWrite=0;
//                 ALUSrc = 0;
//                 RegWrite = 1;
//             end
//             4'd11 && (funct ==6'd28) : begin
//                 RegDst = 0;
//                 Jump = 0;
//                 Branch=0;
//                 MemRead=0;
//                 MemtoReg=0;
//                 ALUOp=4'b0010;
//                 MemWrite=0;
//                 ALUSrc = 0;
//                 RegWrite = 0;
//             end
//             4'd6 : begin
//                 RegDst = 1;
//                 Jump = 0;
//                 Branch=0;
//                 MemRead=0;
//                 MemtoReg=0;
//                 ALUOp=4'b0010;
//                 MemWrite=0;
//                 ALUSrc = 0;
//                 RegWrite = 1;
//             end
//             4'd4 : begin
//                 RegDst = 0;
//                 Jump = 0;
//                 Branch=0;
//                 MemRead=0;
//                 MemtoReg=0;
//                 ALUOp=4'b0000;
//                 MemWrite=0;
//                 ALUSrc = 1;
//                 RegWrite = 1;
//             end
//             4'd9 : begin
//                 RegDst = 0;
//                 Jump = 1;
//                 Branch=0;
//                 MemRead=0;
//                 MemtoReg=0;
//                 ALUOp=4'b0010;
//                 MemWrite=0;
//                 ALUSrc = 0;
//                 RegWrite = 0;
//             end
//             default : begin
//                 RegDst = 0;
//                 Jump = 0;
//                 Branch=0;
//                 MemRead=0;
//                 MemtoReg=0;
//                 ALUOp=4'b0010;
//                 MemWrite=0;
//                 ALUSrc = 0;
//                 RegWrite = 0;
//             end
//         endcase
//     end
// endmodule
