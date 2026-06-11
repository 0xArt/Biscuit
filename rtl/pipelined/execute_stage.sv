`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 12/29/2025
// Design Name: 
// Module Name: execute_stage
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
module execute_stage(
    input   wire            clock,
    input   wire            reset_n,
    input   wire            enable,
    input   wire            flush,
    input   wire            upstream_enable,
    input   wire    [31:0]  register_status,
    input   wire            alu_source,
    input   wire    [31:0]  register_file_read_data_one,
    input   wire    [31:0]  register_file_read_data_two_delivered,
    input   wire    [6:0]   opcode_delivered,
    input   wire    [4:0]   rd_delivered,
    input   wire    [4:0]   rs1_delivered,
    input   wire    [4:0]   rs2_delivered,
    input   wire    [2:0]   funct3_delivered,
    input   wire    [6:0]   funct7,
    input   wire    [31:0]  immediate_delivered,
    input   wire    [3:0]   instruction_type_delivered,
    input   wire    [31:0]  program_counter_delivered,
    input   wire    [31:0]  unbranched_program_counter_delivered,
    input   wire            branch_taken_delivered,

    output  logic           ready,
    output  logic   [31:0]  register_file_read_data_two_shipped,
    output  logic   [4:0]   rd_shipped,
    output  logic   [4:0]   rs1_shipped,
    output  logic   [4:0]   rs2_shipped,
    output  logic   [6:0]   opcode_shipped,
    output  logic   [31:0]  program_counter_shipped,
    output  logic   [31:0]  immediate_shipped,
    output  logic   [2:0]   funct3_shipped,
    output  logic   [3:0]   instruction_type_shipped,
    output  logic   [31:0]  alu_result,
    output  logic   [31:0]  unbranched_program_counter_shipped,
    output  logic           branch_taken_shipped,
    output  logic           take_branch,
    output  logic           valid
);


wire [31:0] riscv_alu_src1;
wire [31:0] riscv_alu_src2;
wire [6:0]  riscv_alu_opcode;
wire [2:0]  riscv_alu_funct3;
wire [6:0]  riscv_alu_funct7;
wire [3:0]  riscv_alu_instruction_type;

wire [31:0] riscv_alu_result;
wire        riscv_alu_branch_taken;

riscv_alu riscv_alu(
    .src1               (riscv_alu_src1),
    .src2               (riscv_alu_src2),
    .opcode             (riscv_alu_opcode),
    .funct3             (riscv_alu_funct3),
    .funct7             (riscv_alu_funct7),
    .instruction_type   (riscv_alu_instruction_type),

    .result             (riscv_alu_result),
    .branch_taken       (riscv_alu_branch_taken)
);


logic [31:0]    _alu_result;
logic           _take_branch;
logic           _valid;
logic [31:0]    _program_counter_shipped;
logic [31:0]    _immediate_shipped;
logic [6:0]     _opcode_shipped;
logic [4:0]     _rd_shipped;
logic [4:0]     _rs1_shipped;
logic [4:0]     _rs2_shipped;
logic [2:0]     _funct3_shipped;
logic [3:0]     _instruction_type_shipped;
logic [31:0]    _register_file_read_data_two_shipped;
logic           read_after_write_hazard;
logic [31:0]    _unbranched_program_counter_shipped;
logic           _branch_taken_shipped;

always_comb begin
    _alu_result                             = alu_result;
    _take_branch                            = take_branch;
    _program_counter_shipped                = program_counter_shipped;
    _immediate_shipped                      = immediate_shipped;
    _opcode_shipped                         = opcode_shipped;
    _rd_shipped                             = rd_shipped;
    _rs1_shipped                            = rs1_shipped;
    _rs2_shipped                            = rs2_shipped;
    _funct3_shipped                         = funct3_shipped;
    _instruction_type_shipped               = instruction_type_shipped;
    _register_file_read_data_two_shipped    = register_file_read_data_two_shipped;
    _unbranched_program_counter_shipped     = unbranched_program_counter_shipped;
    _branch_taken_shipped                   = branch_taken_shipped;
    _valid                                  = valid;
    ready                                   = '0;

    if (register_status[rs1_delivered] || (!alu_source && register_status[rs2_delivered])) begin
        read_after_write_hazard = '1;
    end
    else begin
        read_after_write_hazard = '0;
    end

    if (upstream_enable && valid) begin
        _valid  = '0;
    end

    if (enable) begin
        if (upstream_enable || !valid) begin
            if (!read_after_write_hazard) begin
                ready                                   = '1;
                _alu_result                             = riscv_alu_result;
                _take_branch                            = riscv_alu_branch_taken; 
                _program_counter_shipped                = program_counter_delivered;
                _immediate_shipped                      = immediate_delivered;
                _opcode_shipped                         = opcode_delivered;
                _rd_shipped                             = rd_delivered;
                _rs1_shipped                            = rs1_delivered;
                _rs2_shipped                            = rs2_delivered;
                _funct3_shipped                         = funct3_delivered;
                _instruction_type_shipped               = instruction_type_delivered;
                _register_file_read_data_two_shipped    = register_file_read_data_two_delivered;
                _unbranched_program_counter_shipped     = unbranched_program_counter_delivered;
                _branch_taken_shipped                   = branch_taken_delivered;
                _valid                                  = '1;
            end
        end
    end

    if (flush) begin
        _valid = '0;
    end
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        alu_result                          <= '0;
        take_branch                         <= '0;
        valid                               <= '0;
        program_counter_shipped             <= '0;
        immediate_shipped                   <= '0;
        opcode_shipped                      <= '0;
        rd_shipped                          <= '0;
        rs1_shipped                         <= '0;
        rs2_shipped                         <= '0;
        funct3_shipped                      <= '0;
        instruction_type_shipped            <= '0;
        register_file_read_data_two_shipped <= '0;
        unbranched_program_counter_shipped  <= '0;
        branch_taken_shipped                <= '0;
    end
    else begin
        alu_result                          <= _alu_result;
        take_branch                         <= _take_branch;
        valid                               <= _valid;
        program_counter_shipped             <= _program_counter_shipped;
        immediate_shipped                   <= _immediate_shipped;
        opcode_shipped                      <= _opcode_shipped;
        rd_shipped                          <= _rd_shipped;
        rs1_shipped                         <= _rs1_shipped;
        rs2_shipped                         <= _rs2_shipped;
        funct3_shipped                      <= _funct3_shipped;
        instruction_type_shipped            <= _instruction_type_shipped;
        register_file_read_data_two_shipped <= _register_file_read_data_two_shipped;
        unbranched_program_counter_shipped  <= _unbranched_program_counter_shipped;
        branch_taken_shipped                <= _branch_taken_shipped;
    end
end


assign riscv_alu_src1               = register_file_read_data_one;
assign riscv_alu_src2               = alu_source ? immediate_delivered : register_file_read_data_two_delivered;
assign riscv_alu_opcode             = opcode_delivered;
assign riscv_alu_funct3             = funct3_delivered;
assign riscv_alu_funct7             = funct7;
assign riscv_alu_instruction_type   = instruction_type_delivered;

endmodule