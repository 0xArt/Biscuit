`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 09/27/2025
// Design Name: 
// Module Name: riscv_instruction_decoder
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

module riscv_instruction_decoder (
    input   wire    [31:0]  instruction, 
    
    output  logic   [6:0]   opcode,      
    output  logic   [4:0]   rd,          
    output  logic   [4:0]   rs1,         
    output  logic   [4:0]   rs2,         
    output  logic   [2:0]   funct3,      
    output  logic   [6:0]   funct7,      
    output  logic   [31:0]  imm,         
    output  logic   [3:0]   instruction_type,
    output  logic           alu_source
);

// Internal signals
logic [11:0]    imm_i; // I-type immediate
logic [11:0]    imm_s; // S-type immediate
logic [11:0]    imm_b; // B-type immediate
logic [19:0]    imm_j; // J-type immediate
logic [31:12]   imm_u; // U-type immediate


always_comb begin
    opcode      = instruction[6:0];
    rd          = instruction[11:7];
    funct3      = instruction[14:12];
    rs1         = instruction[19:15];
    rs2         = instruction[24:20];
    funct7      = instruction[31:25];
    alu_source  = 0;

    // Immediate field assignments
    imm_i  = instruction[31:20];
    imm_s  = {instruction[31:25], instruction[11:7]};
    imm_b  = {instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
    imm_j  = {instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
    imm_u  = instruction[31:12];

    case (opcode)
        OP_REG: begin
            instruction_type    = R_TYPE;
            imm                 = 32'b0; // No immediate in R-type
        end
        OP_IMM, OP_LOAD, OP_JALR: begin
            alu_source  = 1;
            instruction_type    = I_TYPE;
            imm                 = {{20{imm_i[11]}}, imm_i}; // Sign-extend I-type immediate
        end
        OP_STORE: begin
            alu_source          = 1;
            instruction_type    = S_TYPE;
            imm                 = {{20{imm_s[11]}}, imm_s}; // Sign-extend S-type immediate
        end
        OP_BRANCH: begin
            instruction_type    = B_TYPE;
            imm                 = {{20{imm_b[11]}}, imm_b}; // Sign-extend B-type immediate
        end
        OP_LUI, OP_AUIPC: begin
            instruction_type    = U_TYPE;
            imm                 = {imm_u, 12'b0}; // U-type immediate (shifted left by 12)
        end
        OP_JAL: begin
            instruction_type    = J_TYPE;
            imm                 = {{12{imm_j[19]}}, imm_j}; // Sign-extend J-type immediate
        end
        default: begin
            instruction_type    = 4'b0; // Invalid/unknown instruction
            imm                 = 32'b0;
        end
    endcase
end

endmodule