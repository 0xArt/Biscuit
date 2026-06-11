`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 12/29/2025
// Design Name: 
// Module Name: decode_stage
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

module decode_stage(
    input   wire            clock,
    input   wire            reset_n,
    input   wire            enable,
    input   wire            flush,
    input   wire            upstream_enable,
    input   wire    [31:0]  instruction,
    input   wire    [31:0]  program_counter_delivered,
    input   wire    [31:0]  unbranched_program_counter_delivered,
    input   wire            branch_taken_delivered,
    input   wire    [31:0]  register_status,

    output  logic           ready,
    output  logic           valid,
    output  logic           register_status_valid,
    output  logic   [6:0]   opcode,
    output  logic   [4:0]   rd,
    output  logic   [4:0]   rs1,
    output  logic   [4:0]   rs2,
    output  logic   [2:0]   funct3,
    output  logic   [6:0]   funct7,
    output  logic   [31:0]  immediate,
    output  logic   [3:0]   instruction_type,
    output  logic           alu_source,
    output  logic   [31:0]  program_counter_shipped,
    output  logic   [31:0]  unbranched_program_counter_shipped,
    output  logic           branch_taken_shipped
);


wire [31:0] riscv_instruction_decoder_instruction;

wire [6:0]  riscv_instruction_decoder_opcode;
wire [4:0]  riscv_instruction_decoder_rd;
wire [4:0]  riscv_instruction_decoder_rs1;
wire [4:0]  riscv_instruction_decoder_rs2;
wire [2:0]  riscv_instruction_decoder_funct3;
wire [6:0]  riscv_instruction_decoder_funct7;
wire [31:0] riscv_instruction_decoder_imm;
wire [3:0]  riscv_instruction_decoder_instruction_type;
wire        riscv_instruction_decoder_alu_source;


riscv_instruction_decoder riscv_instruction_decoder(
    .instruction    (riscv_instruction_decoder_instruction),

    .opcode             (riscv_instruction_decoder_opcode),
    .rd                 (riscv_instruction_decoder_rd),
    .rs1                (riscv_instruction_decoder_rs1),
    .rs2                (riscv_instruction_decoder_rs2),
    .funct3             (riscv_instruction_decoder_funct3),
    .funct7             (riscv_instruction_decoder_funct7),
    .imm                (riscv_instruction_decoder_imm),
    .instruction_type   (riscv_instruction_decoder_instruction_type),
    .alu_source         (riscv_instruction_decoder_alu_source)
);


logic   [6:0]   _opcode;
logic   [4:0]   _rd;
logic   [4:0]   _rs1;
logic   [4:0]   _rs2;
logic   [2:0]   _funct3;
logic   [6:0]   _funct7;
logic   [31:0]  _immediate;
logic   [3:0]   _instruction_type;
logic           _alu_source;
logic           _valid;
logic   [31:0]  _program_counter_shipped;
logic   [31:0]  _unbranched_program_counter_shipped;
logic           _branch_taken_shipped;
logic           _register_status_valid;
logic           double_busy_hazard;
logic           register_write_instruction;


always_comb begin
    _opcode                             = opcode;
    _rd                                 = rd;
    _rs1                                = rs1;
    _rs2                                = rs2;
    _funct3                             = funct3;
    _funct7                             = funct7;
    _immediate                          = immediate;
    _instruction_type                   = instruction_type;
    _alu_source                         = alu_source;
    _program_counter_shipped            = program_counter_shipped;
    _unbranched_program_counter_shipped = unbranched_program_counter_shipped;
    _branch_taken_shipped               = branch_taken_shipped;
    _valid                              = valid;
    _register_status_valid              = '0;
    ready                               = '0;

    if ((riscv_instruction_decoder_instruction_type == R_TYPE) || (riscv_instruction_decoder_instruction_type == I_TYPE) || (riscv_instruction_decoder_instruction_type == U_TYPE) || (riscv_instruction_decoder_instruction_type == J_TYPE)) begin
        register_write_instruction  = '1;
    end
    else begin
        register_write_instruction  = '0;
    end

    if (upstream_enable && valid) begin
        _valid  = '0;
    end
    
    if (register_status[riscv_instruction_decoder_rd] && register_write_instruction) begin
        double_busy_hazard = '1;
    end
    else begin
        double_busy_hazard = '0;
    end

    if (enable) begin
        if (upstream_enable || !valid) begin
            if (!double_busy_hazard) begin
                ready                               = '1;
                _opcode                             = riscv_instruction_decoder_opcode;
                _rd                                 = riscv_instruction_decoder_rd;
                _rs1                                = riscv_instruction_decoder_rs1;
                _rs2                                = riscv_instruction_decoder_rs2;
                _funct3                             = riscv_instruction_decoder_funct3;
                _funct7                             = riscv_instruction_decoder_funct7;
                _immediate                          = riscv_instruction_decoder_imm;
                _instruction_type                   = riscv_instruction_decoder_instruction_type;
                _alu_source                         = riscv_instruction_decoder_alu_source;
                _program_counter_shipped            = program_counter_delivered;
                _unbranched_program_counter_shipped = unbranched_program_counter_delivered;
                _branch_taken_shipped               = branch_taken_delivered;
                _valid                              = '1 && |riscv_instruction_decoder_instruction_type;
                _register_status_valid              = register_write_instruction;
            end
        end
    end

    if (flush) begin
        _valid  = '0;
    end
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        opcode                              <= '0;
        rd                                  <= '0;
        rs1                                 <= '0;
        rs2                                 <= '0;
        funct3                              <= '0;
        funct7                              <= '0;
        immediate                           <= '0;
        instruction_type                    <= '0;
        alu_source                          <= '0;
        valid                               <= '0;
        program_counter_shipped             <= '0;
        unbranched_program_counter_shipped  <= '0;
        branch_taken_shipped                <= '0;
        register_status_valid               <= '0;
    end
    else begin
        opcode                              <= _opcode;
        rd                                  <= _rd;
        rs1                                 <= _rs1;
        rs2                                 <= _rs2;
        funct3                              <= _funct3;
        funct7                              <= _funct7;
        immediate                           <= _immediate;
        instruction_type                    <= _instruction_type;
        alu_source                          <= _alu_source;
        valid                               <= _valid;
        program_counter_shipped             <= _program_counter_shipped;
        unbranched_program_counter_shipped  <= _unbranched_program_counter_shipped;
        branch_taken_shipped                <= _branch_taken_shipped;
        register_status_valid               <= _register_status_valid;
    end
end


assign riscv_instruction_decoder_instruction    = instruction;

endmodule