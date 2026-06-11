`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 10/19/2025
// Design Name: 
// Module Name: riscv_memory_writer
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

module riscv_memory_writer #(
    parameter START_ADDRESS     = 'h10000,
    parameter DEPTH             = 4096
)(
    input   wire    [31:0]              alu_result,
    input   wire    [2:0]               funct3,
    input   wire    [31:0]              read_data,
    input   wire    [3:0]               instruction_type,

    output  logic   [3:0]               write_byte_select,
    output  logic   [31:0]              write_data,
    output  logic   [$clog2(DEPTH)-1:0] write_address
);


always_comb begin
    write_data          = '0;
    write_byte_select   = '0;
    write_address       = '0;

    if (instruction_type == S_TYPE) begin
        case (funct3)
            F3_BYTE, F3_BYTE_U: begin
                if (alu_result[1:0] == 2'b00) begin
                    write_byte_select   = 4'b0001;
                    write_data          = read_data & 32'hFF;
                end
                if (alu_result[1:0] == 2'b01) begin
                    write_byte_select   = 4'b0010;
                    write_data          = (read_data & 32'hFF) << 8;
                end
                if (alu_result[1:0] == 2'b10) begin
                    write_byte_select   = 4'b0100;
                    write_data          = (read_data & 32'hFF) << 16;
                end
                if (alu_result[1:0] == 2'b11) begin
                    write_byte_select   = 4'b1000;
                    write_data          = (read_data & 32'hFF) << 24;
                end
            end
            F3_WORD: begin
                write_data  = read_data;

                if (alu_result[1:0] == 2'b00) begin
                    write_byte_select   = '1;
                end
            end
            F3_HALFWORD, F3_HALFWORD_U: begin
                if (alu_result[1:0] == 2'b00) begin
                    write_byte_select   = 4'b0011;
                    write_data          = read_data & 32'hFFFF;
                end
                if (alu_result[1:0] == 2'b01) begin
                    write_byte_select   = 4'b1100;
                    write_data          = (read_data & 32'hFFFF) << 16;
                end
            end
        endcase
    end

    if (alu_result < START_ADDRESS) begin
        write_byte_select   = '0;
    end
    else begin
        write_address   = alu_result - START_ADDRESS;
    end
end


endmodule