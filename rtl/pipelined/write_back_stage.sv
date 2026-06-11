`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 12/30/2025
// Design Name: 
// Module Name: write_back_stage
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
module write_back_stage(
    input   wire            clock,
    input   wire            reset_n,
    input   wire            enable,
    input   wire            upstream_enable,
    input   wire    [6:0]   opcode,
    input   wire    [31:0]  alu_result,
    input   wire    [31:0]  memory_read_data,
    input   wire    [31:0]  program_counter,
    input   wire    [31:0]  immediate,
    input   wire    [4:0]   rd_delivered,

    output  logic           ready,
    output  logic   [4:0]   rd_shipped,
    output  logic   [31:0]  write_data,
    output  logic           write_data_valid,
    output  logic           register_status_valid,
    output  logic           valid
);


wire [6:0]  riscv_write_back_controller_opcode;
wire [31:0] riscv_write_back_controller_memory_read_data;
wire [31:0] riscv_write_back_controller_alu_result;
wire [31:0] riscv_write_back_controller_program_counter;
wire [31:0] riscv_write_back_controller_immediate;

wire [31:0] riscv_write_back_controller_write_data;
wire        riscv_write_back_controller_write_data_valid;

riscv_write_back_controller riscv_write_back_controller(
    .opcode             (riscv_write_back_controller_opcode),
    .memory_read_data   (riscv_write_back_controller_memory_read_data),
    .alu_result         (riscv_write_back_controller_alu_result),
    .program_counter    (riscv_write_back_controller_program_counter),
    .immediate          (riscv_write_back_controller_immediate),

    .write_data         (riscv_write_back_controller_write_data),
    .write_data_valid   (riscv_write_back_controller_write_data_valid)
);


logic   [4:0]   _rd_shipped;
logic   [31:0]  _write_data;
logic           _write_data_valid;
logic           _valid;
logic           _register_status_valid;

always_comb begin
    _rd_shipped             = rd_shipped;
    _write_data             = write_data;
    _valid                  = valid;
    _write_data_valid       = '0;
    _register_status_valid  = '0;
    ready                   = '0;

    if (upstream_enable && valid) begin
        _valid  = '0;
    end

    if (enable) begin
        if (upstream_enable || !valid) begin
            ready                   = '1;
            _rd_shipped             = rd_delivered;
            _write_data             = riscv_write_back_controller_write_data;
            _write_data_valid       = riscv_write_back_controller_write_data_valid;
            _register_status_valid  = riscv_write_back_controller_write_data_valid;
            _valid                  = '1;
        end
    end
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        rd_shipped              <= '0;
        write_data              <= '0;
        write_data_valid        <= '0;
        valid                   <= '0;
        register_status_valid   <= '0;
    end
    else begin
        rd_shipped              <= _rd_shipped;
        write_data              <= _write_data;
        write_data_valid        <= _write_data_valid;
        valid                   <= _valid;
        register_status_valid   <= _register_status_valid;
    end
end


assign riscv_write_back_controller_opcode           = opcode;
assign riscv_write_back_controller_memory_read_data = memory_read_data;
assign riscv_write_back_controller_alu_result       = alu_result;
assign riscv_write_back_controller_program_counter  = program_counter;
assign riscv_write_back_controller_immediate        = immediate;

endmodule