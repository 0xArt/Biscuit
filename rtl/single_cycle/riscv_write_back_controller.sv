`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 10/25/2025
// Design Name: 
// Module Name: riscv_write_back_controller
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

module riscv_write_back_controller(
    input   wire    [6:0]   opcode,
    input   wire    [31:0]  memory_read_data,
    input   wire    [31:0]  alu_result,
    input   wire    [31:0]  program_counter,
    input   wire    [31:0]  immediate,

    output  logic    [31:0] write_data,
    output  logic           write_data_valid
);

always_comb begin
    write_data_valid    = 0;
    write_data          = 0;

    if (opcode == OP_LOAD) begin
        write_data          = memory_read_data;
        write_data_valid    = 1;
    end

    if ((opcode == OP_IMM) || (opcode == OP_REG)) begin
        write_data          = alu_result;
        write_data_valid    = 1;
    end

    if ((opcode == OP_JAL) || (opcode  == OP_JALR)) begin
        write_data           = program_counter + 4;
        write_data_valid     = 1;
    end

    if (opcode == OP_LUI) begin
        write_data          = immediate;
        write_data_valid    = 1;
    end

    if (opcode == OP_AUIPC) begin
        write_data          = program_counter + immediate;
        write_data_valid    = 1;
    end
end


endmodule