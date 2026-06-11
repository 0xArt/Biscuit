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


logic   [3:0]   data_byte_select;

always_comb begin
    read_data           = '0;
    read_data_valid     = '0;
    read_address        = '0;
    data_byte_select    = '0;

    if (instruction_type == I_TYPE) begin
        case (funct3)
            F3_BYTE, F3_BYTE_U: begin
                if (alu_result[1:0] == 2'b00) begin
                    data_byte_select   = 4'b0001;
                end
                if (alu_result[1:0] == 2'b01) begin
                    data_byte_select   = 4'b0010;
                end
                if (alu_result[1:0] == 2'b10) begin
                    data_byte_select   = 4'b0100;
                end
                if (alu_result[1:0] == 2'b11) begin
                    data_byte_select   = 4'b1000;
                end
            end
            F3_WORD: begin
                if (alu_result[1:0] == 2'b00) begin
                    data_byte_select   = '1;
                end
            end
            F3_HALFWORD, F3_HALFWORD_U: begin
                if (alu_result[1:0] == 2'b00) begin
                    data_byte_select   = 4'b0011;
                end
                if (alu_result[1:0] == 2'b01) begin
                    data_byte_select   = 4'b1100;
                end
            end
        endcase
    end

    for (int i = 0; i < 4; i++) begin
        if (data_byte_select[i]) begin
            read_data[(i*8)+:8] = data[(i*8)+:8];
        end
    end

    case (funct3)
        F3_BYTE, F3_BYTE_U: begin
            if (data_byte_select == 4'b0010) begin
                read_data   = read_data >> 8;
            end
            else if (data_byte_select == 4'b0100) begin
                read_data   = read_data >> 16;
            end
            else if (data_byte_select == 4'b1000) begin
                read_data   = read_data >> 24;
            end
            else begin
                read_data   = '0;
            end

            if (funct3 == F3_BYTE) begin
                read_data   = {24{read_data[7], read_data[7:0]}};
            end

            if (|data_byte_select) begin
                read_data_valid     = 1;
            end
        end
        F3_HALFWORD, F3_HALFWORD_U: begin
            if (data_byte_select == 4'b0011) begin
                read_data   = read_data;
            end
            else if (data_byte_select == 4'b1100) begin
                read_data   = read_data >> 24;
            end
            else begin
                read_data   = '0;
            end

            if (funct3 == F3_HALFWORD_U) begin
                read_data   = {16{read_data[15], read_data[15:0]}};
            end

            if (|data_byte_select) begin
                read_data_valid     = 1;
            end
        end
        F3_WORD: begin
            if (|data_byte_select) begin
                read_data_valid     = 1;
            end
        end
    endcase

    if (alu_result < START_ADDRESS) begin
        read_data_valid = 0;
    end
    else begin
        read_address    = alu_result - START_ADDRESS;
    end
end


endmodule