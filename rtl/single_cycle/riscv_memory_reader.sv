`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
//
// Create Date: 11/16/2025
// Design Name:
// Module Name: riscv_memory-reader
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

module riscv_memory_reader #(
    parameter START_ADDRESS     = 'h10000,
    parameter DEPTH             = 4096
)(
    input   wire    [31:0]              data,
    input   wire    [2:0]               funct3,
    input   wire    [31:0]              alu_result,
    input   wire    [3:0]               instruction_type,

    output  logic   [31:0]              read_data,
    output  logic                       read_data_valid,
    output  logic   [$clog2(DEPTH)-1:0] read_address
);


logic [7:0]     byte_data;
logic [15:0]    half_data;

always_comb begin
    read_data           = '0;
    read_data_valid     = '0;
    read_address        = '0;

    half_data           = alu_result[1] ? data[31:16] : data[15:0]; // aligned halfword lanes

    case (alu_result[1:0])                                           // selected byte lane
        2'b00:   byte_data = data[7:0];
        2'b01:   byte_data = data[15:8];
        2'b10:   byte_data = data[23:16];
        2'b11:   byte_data = data[31:24];
        default: byte_data = data[7:0];
    endcase

    if (instruction_type == I_TYPE) begin
        case (funct3)
            F3_BYTE:        read_data = {{24{byte_data[7]}},  byte_data}; // LB  (sign-extend)
            F3_BYTE_U:      read_data = {24'b0,               byte_data}; // LBU (zero-extend)
            F3_HALFWORD:    read_data = {{16{half_data[15]}}, half_data}; // LH  (sign-extend)
            F3_HALFWORD_U:  read_data = {16'b0,               half_data}; // LHU (zero-extend)
            F3_WORD:        read_data = data;                             // LW
            default:        read_data = '0;
        endcase

        // naturally-aligned accesses only
        case (funct3)
            F3_BYTE, F3_BYTE_U:         read_data_valid = 1'b1;
            F3_HALFWORD, F3_HALFWORD_U: read_data_valid = (alu_result[0] == 1'b0);
            F3_WORD:                    read_data_valid = (alu_result[1:0] == 2'b00);
            default:                    read_data_valid = 1'b0;
        endcase
    end

    if (alu_result < START_ADDRESS) begin
        read_data_valid = 1'b0;
    end
    else begin
        read_address    = alu_result - START_ADDRESS;
    end
end


endmodule
