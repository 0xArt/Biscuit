`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 09/27/2025
// Design Name: 
// Module Name: riscv_alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
// Copyright 2026 Artin Isagholian
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//////////////////////////////////////////////////////////////////////////////////
import riscv_constants_package::*;

module riscv_alu (
    input   wire    [31:0]  src1,               // Value from rs1 (or PC for AUIPC/JAL)
    input   wire    [31:0]  src2,               // Value from rs2 or immediate
    input   wire    [6:0]   opcode,             // From decoder
    input   wire    [2:0]   funct3,             // From decoder
    input   wire    [6:0]   funct7,             // From decoder
    input   wire    [3:0]   instruction_type,   // From decoder

    output  logic   [31:0]  result,             // ALU result
    output  logic           branch_taken        // For branch instructions
);

// ALU operation codes (internal)
localparam ALU_ADD  = 4'b0000;
localparam ALU_SUB  = 4'b0001;
localparam ALU_AND  = 4'b0010;
localparam ALU_OR   = 4'b0011;
localparam ALU_XOR  = 4'b0100;
localparam ALU_SLL  = 4'b0101;
localparam ALU_SRL  = 4'b0110;
localparam ALU_SRA  = 4'b0111;
localparam ALU_SLT  = 4'b1000;
localparam ALU_SLTU = 4'b1001;
localparam ALU_PASS = 4'b1010; // For LUI: pass src2

// Branch codes from funct3
localparam BR_BEQ  = 3'b000;
localparam BR_BNE  = 3'b001;
localparam BR_BLT  = 3'b100;
localparam BR_BGE  = 3'b101;
localparam BR_BLTU = 3'b110;
localparam BR_BGEU = 3'b111;

// Internal signals
logic [3:0] alu_op;
logic [31:0] sum;
logic [31:0] shift_ammount;
logic signed [31:0] src1_signed, src2_signed;
logic [31:0] diff;
logic eq, less_than, less_than_unsigned;


// Determine ALU operation
always_comb begin
    alu_op = ALU_ADD; // Default

    case (instruction_type)

        R_TYPE: begin
            case (funct3)
                3'b000: alu_op = (funct7[5]) ? ALU_SUB : ALU_ADD;
                3'b001: alu_op = ALU_SLL;
                3'b010: alu_op = ALU_SLT;
                3'b011: alu_op = ALU_SLTU;
                3'b100: alu_op = ALU_XOR;
                3'b101: alu_op = (funct7[5]) ? ALU_SRA : ALU_SRL;
                3'b110: alu_op = ALU_OR;
                3'b111: alu_op = ALU_AND;
            endcase
        end

        I_TYPE: begin
            // For OP_IMM, OP_LOAD, OP_JALR
            // OP_LOAD and OP_JALR use ADD for address
            // OP_IMM uses based on funct3
            if (opcode == 7'b0000011 || opcode == 7'b1100111) begin // LOAD or JALR
                alu_op = ALU_ADD;
            end 
            else begin // OP_IMM
                case (funct3)
                    3'b000: alu_op = ALU_ADD;
                    3'b001: alu_op = ALU_SLL;
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b101: alu_op = (funct7[5]) ? ALU_SRA : ALU_SRL;
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;
                endcase
            end
        end

        S_TYPE: begin // STORE: address = rs1 + imm
            alu_op = ALU_ADD;
        end

        B_TYPE: begin // BRANCH: compute diff, but result not used, set branch_taken
            alu_op = ALU_SUB; // For comparisons
        end

        U_TYPE: begin
            if (opcode == 7'b0110111) begin // LUI: result = imm (src2)
                alu_op = ALU_PASS;
            end 
            else begin // AUIPC: PC + imm (assume src1 is PC, src2 is imm)
                alu_op = ALU_ADD;
            end
        end

        J_TYPE: begin // JAL: rd = PC + 4 (assume src1 is PC, src2 is 4), target = PC + imm separately
            alu_op = ALU_ADD;
        end
        
        default: alu_op = ALU_ADD;
    endcase
end

// Compute result
always_comb begin
    case (alu_op)
        ALU_ADD:  result    = src1 + src2;
        ALU_SUB:  result    = src1 - src2;
        ALU_AND:  result    = src1 & src2;
        ALU_OR:   result    = src1 | src2;
        ALU_XOR:  result    = src1 ^ src2;
        ALU_SLL:  result    = src1 << shift_ammount;
        ALU_SRL:  result    = src1 >> shift_ammount;
        ALU_SRA:  result    = src1_signed >>> shift_ammount;
        ALU_SLT:  result    = {31'b0, less_than};
        ALU_SLTU: result    = {31'b0, less_than_unsigned};
        ALU_PASS: result    = src2;
        default:  result    = 32'b0;
    endcase
end

// For branches, set branch_taken
always_comb begin
    branch_taken    = 0;
    
    if (instruction_type == B_TYPE) begin
        case (funct3)
            BR_BEQ:  branch_taken   = eq;
            BR_BNE:  branch_taken   = !eq;
            BR_BLT:  branch_taken   = less_than;
            BR_BGE:  branch_taken   = !less_than;
            BR_BLTU: branch_taken   = less_than_unsigned;
            BR_BGEU: branch_taken   = !less_than_unsigned;
        endcase
    end 
end


// Sign extensions for comparisons
assign src1_signed          = src1;
assign src2_signed          = src2;
// Computations
assign sum                  = src1 + src2;
assign diff                 = src1 - src2;
assign eq                   = (src1 == src2);
assign less_than            = (src1_signed < src2_signed);
assign less_than_unsigned   = (src1 < src2);
// Shift amount: for I-type shifts, src2[4:0], but since src2 is imm for I, and imm[4:0] is shamt
assign shift_ammount        = src2[4:0];

endmodule