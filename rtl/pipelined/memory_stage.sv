`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 12/29/2025
// Design Name: 
// Module Name: memory_stage
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
module memory_stage#(
    parameter DATA_MEMORY_DEPTH         = 4096,
    parameter DATA_START_ADDRESS        = 'h0
)(
    input   wire                                    clock,
    input   wire                                    reset_n,
    input   wire                                    enable,
    input   wire                                    upstream_enable,
    input   wire    [31:0]                          register_status,
    input   wire    [31:0]                          alu_result_delivered,
    input   wire    [31:0]                          data_memory_read_data,
    input   wire    [31:0]                          register_file_read_data_two,
    input   wire    [31:0]                          program_counter_delivered,
    input   wire    [4:0]                           rd_delivered,
    input   wire    [31:0]                          immediate_delivered,
    input   wire    [6:0]                           opcode_delivered,
    input   wire    [4:0]                           rs2,
    input   wire    [2:0]                           funct3,
    input   wire    [3:0]                           instruction_type,

    output  logic                                   ready,
    output  logic   [31:0]                          immediate_shipped,
    output  logic   [31:0]                          alu_result_shipped,
    output  logic   [31:0]                          program_counter_shipped,
    output  logic   [4:0]                           rd_shipped,
    output  logic   [6:0]                           opcode_shipped,
    output  logic   [31:0]                          read_data,
    output  logic                                   read_data_valid,
    output  logic   [31:0]                          write_data,
    output  logic   [$clog2(DATA_MEMORY_DEPTH)-1:0] write_address,
    output  logic   [3:0]                           write_byte_select,
    output  logic   [$clog2(DATA_MEMORY_DEPTH)-1:0] read_address,
    output  logic                                   valid
);


wire [31:0]                             riscv_memory_writer_alu_result;
wire [2:0]                              riscv_memory_writer_funct3;
wire [31:0]                             riscv_memory_writer_read_data;
wire [3:0]                              riscv_memory_writer_instruction_type;

wire [3:0]                              riscv_memory_writer_write_byte_select;
wire [31:0]                             riscv_memory_writer_write_data;
wire [$clog2(DATA_MEMORY_DEPTH)-1:0]    riscv_memory_writer_write_address;

riscv_memory_writer #(
    .START_ADDRESS  (DATA_START_ADDRESS),
    .DEPTH          (DATA_MEMORY_DEPTH)
) riscv_memory_writer(
    .alu_result         (riscv_memory_writer_alu_result),
    .funct3             (riscv_memory_writer_funct3),
    .read_data          (riscv_memory_writer_read_data),
    .instruction_type   (riscv_memory_writer_instruction_type),

    .write_byte_select  (riscv_memory_writer_write_byte_select),
    .write_data         (riscv_memory_writer_write_data),
    .write_address      (riscv_memory_writer_write_address)
);


wire [31:0]                             riscv_memory_reader_data;
wire [2:0]                              riscv_memory_reader_funct3;
wire [31:0]                             riscv_memory_reader_alu_result;
wire [3:0]                              riscv_memory_reader_instruction_type;

wire [31:0]                             riscv_memory_reader_read_data;
wire                                    riscv_memory_reader_read_data_valid;
wire [$clog2(DATA_MEMORY_DEPTH)-1:0]    riscv_memory_reader_read_address;

riscv_memory_reader #(
    .START_ADDRESS  (DATA_START_ADDRESS),
    .DEPTH          (DATA_MEMORY_DEPTH)
) riscv_memory_reader(
    .data               (riscv_memory_reader_data),
    .funct3             (riscv_memory_reader_funct3),
    .alu_result         (riscv_memory_reader_alu_result),
    .instruction_type   (riscv_memory_reader_instruction_type),

    .read_data          (riscv_memory_reader_read_data),
    .read_data_valid    (riscv_memory_reader_read_data_valid),
    .read_address       (riscv_memory_reader_read_address)
);


logic [6:0]                             _opcode_shipped;
logic [31:0]                            _immediate_shipped;
logic [31:0]                            _alu_result_shipped;
logic [31:0]                            _program_counter_shipped;
logic [31:0]                            _read_data;
logic                                   _read_data_valid;
logic [4:0]                             _rd_shipped;
logic                                   _valid;
logic                                   read_after_write_hazard;

always_comb begin
    _read_data                      = read_data;
    _program_counter_shipped        = program_counter_shipped;
    _immediate_shipped              = immediate_shipped;
    _alu_result_shipped             = alu_result_shipped;
    _opcode_shipped                 = opcode_shipped;
    _rd_shipped                     = rd_shipped;
    _valid                          = valid;
    _read_data_valid                = '0;
    ready                           = '0;

    if (register_status[rs2] && (rs2 != rd_delivered)) begin
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
                ready                       = '1;
                _read_data                  = riscv_memory_reader_read_data;
                _read_data_valid            = riscv_memory_reader_read_data_valid;
                _program_counter_shipped    = program_counter_delivered;
                _rd_shipped                 = rd_delivered;
                _opcode_shipped             = opcode_delivered;
                _alu_result_shipped         = alu_result_delivered;
                _immediate_shipped          = immediate_delivered;
                _valid                      = '1;
            end
        end
    end
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        read_data                   <= '0;
        read_data_valid             <= '0;
        valid                       <= '0;
        program_counter_shipped     <= '0;
        alu_result_shipped          <= '0;
        immediate_shipped           <= '0;
        opcode_shipped              <= '0;
        rd_shipped                  <= '0;
    end
    else begin
        read_data                   <= _read_data;
        read_data_valid             <= _read_data_valid;
        valid                       <= _valid;
        program_counter_shipped     <= _program_counter_shipped;
        alu_result_shipped          <= _alu_result_shipped;
        immediate_shipped           <= _immediate_shipped;
        opcode_shipped              <= _opcode_shipped;
        rd_shipped                  <= _rd_shipped;
    end
end


assign read_address                             = riscv_memory_reader_read_address;
assign write_byte_select                        = riscv_memory_writer_write_byte_select;
assign write_data                               = riscv_memory_writer_write_data;
assign write_address                            = riscv_memory_writer_write_address;

assign riscv_memory_writer_alu_result           = alu_result_delivered;
assign riscv_memory_writer_funct3               = funct3;
assign riscv_memory_writer_read_data            = register_file_read_data_two;
assign riscv_memory_writer_instruction_type     = instruction_type;

assign riscv_memory_reader_alu_result           = alu_result_delivered;
assign riscv_memory_reader_data                 = data_memory_read_data;
assign riscv_memory_reader_funct3               = funct3;
assign riscv_memory_reader_instruction_type     = instruction_type;

endmodule