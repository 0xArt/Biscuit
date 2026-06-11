`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 09/27/2025
// Design Name: 
// Module Name: riscv_resgister_file
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
module riscv_register_file(
    input   wire            clock,
    input   wire            reset_n,
    input   wire    [4:0]   read_address_one,
    input   wire    [4:0]   read_address_two_a,
    input   wire    [4:0]   read_address_two_b,
    input   wire            write_enable,
    input   wire    [4:0]   write_address,
    input   wire    [31:0]  write_data,

    output  logic   [31:0]  read_data_one,
    output  logic   [31:0]  read_data_two_a,
    output  logic   [31:0]  read_data_two_b
);


logic [31:0][31:0]  _registers;
reg   [31:0][31:0]  registers;


always_comb begin
    _registers = registers;

    if (write_enable) begin
        _registers[write_address]   = write_data;
    end

    _registers[0]   = '0; //riscv spec requires R0 to be constant of zero

    read_data_one   = registers[read_address_one];
    read_data_two_a = registers[read_address_two_a];
    read_data_two_b = registers[read_address_two_b];
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        registers   <= '0;
    end
    else begin
        registers   <= _registers;
    end
end


endmodule