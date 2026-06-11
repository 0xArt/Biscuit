`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 10/24/2025
// Design Name: 
// Module Name: riscv_result
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

module riscv_program_counter(
    input   wire            clock,
    input   wire            reset_n,
    input   wire            halt,
    input   wire    [3:0]   instruction_type,
    input   wire    [6:0]   opcode,
    input   wire    [2:0]   funct3,
    input   wire    [31:0]  alu_result,
    input   wire    [31:0]  immediate,
    input   wire    [31:0]  read_data_one,

    output  logic   [31:0]  result
);

logic [31:0]    _result;
logic           alternative_increment;

always_comb begin
    alternative_increment   = 0;
    _result                 = result;

    if (instruction_type == J_TYPE) begin
        alternative_increment   = 1;
    end

    if (instruction_type == B_TYPE) begin
        if (funct3  == F3_BEQ) begin
            if (alu_result == 0) begin
                alternative_increment   = 1;
            end
        end
        if (funct3 == F3_BLT || funct3 == F3_BLTU) begin
            if (alu_result[0]) begin
                alternative_increment   = 1;
            end
        end
        if (funct3 == F3_BNE) begin
            if (alu_result != 0) begin
                alternative_increment   = 1;
            end
        end
        if (funct3 == F3_BGE || funct3 == F3_BGEU) begin
            if (!alu_result[0]) begin
                alternative_increment   = 1;
            end
        end
    end

    if (!halt) begin
        if (alternative_increment) begin
            if (opcode == OP_BRANCH) begin
                _result    = result + immediate;
            end
            if (opcode == OP_JAL) begin
                _result    = result + immediate;
            end
            if (opcode == OP_JALR) begin
                _result    = (read_data_one + immediate) & 32'hFFFFFFFE;
            end
        end
        else begin
            _result = result + 4;
        end
    end
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        result  <= '0;
    end
    else begin
        result  <= _result;
    end
end


endmodule