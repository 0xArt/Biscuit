`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 09/27/2025
// Design Name: 
// Module Name: riscv_instruction_memory
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
module riscv_memory#(
    parameter MEMORY_DEPTH          = 4096,
    parameter TECHNOLOGY            = "SIMULATION"
)(
    input   wire                                    clock,
    input   wire                                    reset_n,
    input   wire    [$clog2(MEMORY_DEPTH)-1:0]      read_address,
    input   wire                                    write_protect,
    input   wire                                    write_enable,
    input   wire    [31:0]                          write_data,
    input   wire    [$clog2(MEMORY_DEPTH)-1:0]      write_address,
    input   wire    [3:0]                           write_byte_select,

    output  wire    [31:0]                          read_data
);

genvar i;

wire                            block_ram_clock;
wire                            block_ram_reset_n;
wire [3:0]                      block_ram_write_enable;
wire [3:0][7:0]                 block_ram_write_data;
wire [$clog2(MEMORY_DEPTH)-1:0] block_ram_write_address;
wire [$clog2(MEMORY_DEPTH)-1:0] block_ram_read_address;

wire [3:0][7:0]                 block_ram_read_data;

generate
    for(i = 0; i < 4; i = i + 1) begin : byte_lane
        block_ram #(
            .DATA_WIDTH         (8),
            .DATA_DEPTH         (MEMORY_DEPTH),
            .PIPELINED_OUTPUT   (0),
            .TECHNOLOGY         (TECHNOLOGY)
        )block_ram(
            .clock          (block_ram_clock),
            .reset_n        (block_ram_reset_n),
            .write_enable   (block_ram_write_enable[i]),
            .write_data     (block_ram_write_data[i]),
            .write_address  (block_ram_write_address),
            .read_address   (block_ram_read_address),

            .read_data      (block_ram_read_data[i])
        );

        assign block_ram_write_enable[i]    = write_protect ? 1'b0  : (write_enable && write_byte_select[i]);
        assign block_ram_write_data[i]      = write_protect ? '0    : write_data[((7*i)+i)+7:((7*i)+i)];
    end
endgenerate


assign block_ram_clock              = clock;
assign block_ram_reset_n            = reset_n;
assign block_ram_read_address       = read_address;
assign read_data                    = {block_ram_read_data[3], block_ram_read_data[2], block_ram_read_data[1], block_ram_read_data[0]};
assign block_ram_write_address      = write_address;

endmodule