`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 12/29/2025
// Design Name: 
// Module Name: fetch_stage
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

module fetch_stage(
    input   wire            clock,
    input   wire            reset_n,
    input   wire            enable,
    input   wire            upstream_enable,
    input   wire    [31:0]  memory_read_data,
    input   wire            take_branch,
    input   wire            flush,
    input   wire    [31:0]  correct_program_counter,

    output  logic   [31:0]  instruction,
    output  logic           valid,
    output  wire    [31:0]  memory_address,
    output  logic   [31:0]  program_counter,
    output  logic   [31:0]  unbranched_program_counter,
    output  logic           branch_taken
);


logic [31:0]    _internal_program_counter;
logic [31:0]    internal_program_counter;
logic [31:0]    _program_counter;
logic [31:0]    _instruction;
logic           _valid;
logic [6:0]     opcode;
logic [31:0]    immediate;
logic [12:0]    imm_b; // B-type immediate (13-bit signed offset, imm[0]=0)
logic [20:0]    imm_j; // J-type immediate (21-bit signed offset, imm[0]=0)
logic [31:0]    _unbranched_program_counter;
logic           _branch_taken;
logic [4:0]     rs1;

always_comb begin
    _unbranched_program_counter = unbranched_program_counter;
    _branch_taken               = branch_taken;
    immediate                   = '0;
    imm_b                       = {memory_read_data[31], memory_read_data[7], memory_read_data[30:25], memory_read_data[11:8], 1'b0};
    imm_j                       = {memory_read_data[31], memory_read_data[19:12], memory_read_data[20], memory_read_data[30:21], 1'b0};
    opcode                      = memory_read_data[6:0];
    rs1                         = memory_read_data[19:15];
    _internal_program_counter   = internal_program_counter;
    _program_counter            = program_counter;
    _instruction                = instruction;
    _valid                      = valid;

    if (upstream_enable && valid) begin
        _valid          = '0;
    end
    
    if (enable) begin
        if (upstream_enable || !valid) begin
            _branch_taken               = '0;
            _program_counter            = internal_program_counter;
            _instruction                = memory_read_data; 
            _internal_program_counter   = internal_program_counter + 4;
            _valid                      = '1;

            if (opcode == OP_BRANCH) begin
                immediate = {{19{imm_b[12]}}, imm_b}; // Sign-extend B-type immediate

                if (take_branch) begin
                    _internal_program_counter   = internal_program_counter + immediate;
                    _unbranched_program_counter = internal_program_counter + 4;
                    _branch_taken               = '1;
                end
                else begin
                    _unbranched_program_counter = internal_program_counter + immediate;
                end
            end
            if (opcode == OP_JAL) begin
                immediate                   = {{11{imm_j[20]}}, imm_j}; // Sign-extend J-type immediate
                _internal_program_counter   = internal_program_counter + immediate;
            end
            // JALR target = rs1 + imm, not known until Execute; fall through
            // to PC+4 here and let branch_manager redirect on resolution.
        end
    end

    if (flush) begin
        _internal_program_counter   = correct_program_counter;
        _valid                      = '0;
    end
end


always_ff @(posedge clock) begin
    if (!reset_n) begin
        internal_program_counter    <= '0;
        program_counter             <= '0;
        instruction                 <= '0;
        valid                       <= '0;
        unbranched_program_counter  <= '0;
        branch_taken                <= '0;
    end
    else begin
        internal_program_counter    <= _internal_program_counter;
        program_counter             <= _program_counter;
        instruction                 <= _instruction;
        valid                       <= _valid;
        unbranched_program_counter  <= _unbranched_program_counter;
        branch_taken                <= _branch_taken;
    end
end

assign memory_address   = internal_program_counter >> 2;

endmodule