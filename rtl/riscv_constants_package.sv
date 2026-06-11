`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 5/31/2026
// Design Name: 
// Module Name: riscv_constants_package
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
package riscv_constants_package;

// Instruction type encoding
localparam R_TYPE           = 4'b0001;
localparam I_TYPE           = 4'b0010;
localparam S_TYPE           = 4'b0011;
localparam B_TYPE           = 4'b0100;
localparam U_TYPE           = 4'b0101;
localparam J_TYPE           = 4'b0110;

// RISC-V opcode definitions
localparam OP_REG           = 7'b0110011; // R-type: ADD, SUB, AND, OR, etc.
localparam OP_IMM           = 7'b0010011; // I-type: ADDI, ANDI, ORI, etc.
localparam OP_LOAD          = 7'b0000011; // I-type: LW, LH, LB, etc.
localparam OP_STORE         = 7'b0100011; // S-type: SW, SH, SB
localparam OP_BRANCH        = 7'b1100011; // B-type: BEQ, BNE, BLT, etc.
localparam OP_JAL           = 7'b1101111; // J-type: JAL
localparam OP_JALR          = 7'b1100111; // I-type: JALR
localparam OP_LUI           = 7'b0110111; // U-type: LUI
localparam OP_AUIPC         = 7'b0010111; // U-type: AUIPC

localparam F3_BYTE          = 3'b000;
localparam F3_HALFWORD      = 3'b001;
localparam F3_WORD          = 3'b010;
localparam F3_BYTE_U        = 3'b100;
localparam F3_HALFWORD_U    = 3'b101;

localparam F3_BEQ           = 3'b000;
localparam F3_BNE           = 3'b001;
localparam F3_BLT           = 3'b100;
localparam F3_BGE           = 3'b101;
localparam F3_BLTU          = 3'b110;
localparam F3_BGEU          = 3'b111;

endpackage