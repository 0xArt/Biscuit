`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
//
// Create Date: 10/24/2025
// Design Name:
// Module Name: testbench
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

module testbench;

localparam  CLOCK_FREQUENCY = 100_000_000;
localparam  CLOCK_PERIOD    = 1e9/CLOCK_FREQUENCY;
localparam  PROGRAM_SIZE    = 20;

logic clock;
logic reset_n;
logic halt;
integer i;
logic [127:0][31:0] program_data;



logic           riscv_core_clock;
logic           riscv_core_reset_n;
logic           riscv_core_halt;
logic [31:0]    riscv_core_program_memory_write_data;
logic           riscv_core_program_memory_write_data_enable;
logic [31:0]    riscv_core_program_memory_write_address;

riscv_core riscv_core(
    .clock                              (riscv_core_clock),
    .reset_n                            (riscv_core_reset_n),
    .halt                               (riscv_core_halt),
    .program_memory_write_data          (riscv_core_program_memory_write_data),
    .program_memory_write_data_enable   (riscv_core_program_memory_write_data_enable),
    .program_memory_write_address       (riscv_core_program_memory_write_address)
);


logic           riscv_core_pipelined_clock;
logic           riscv_core_pipelined_reset_n;
logic           riscv_core_pipelined_halt;
logic [31:0]    riscv_core_pipelined_program_memory_write_data;
logic           riscv_core_pipelined_program_memory_write_data_enable;
logic [31:0]    riscv_core_pipelined_program_memory_write_address;

riscv_core_pipelined riscv_core_pipelined(
    .clock                              (riscv_core_pipelined_clock),
    .reset_n                            (riscv_core_pipelined_reset_n),
    .halt                               (riscv_core_pipelined_halt),
    .program_memory_write_data          (riscv_core_pipelined_program_memory_write_data),
    .program_memory_write_data_enable   (riscv_core_pipelined_program_memory_write_data_enable),
    .program_memory_write_address       (riscv_core_pipelined_program_memory_write_address)
);


initial begin
    clock   =   0;

    forever begin
        #(CLOCK_PERIOD/2);
        clock   =   ~clock;
    end
end

always_comb begin 
    program_data        = '0;
    program_data[0]     = 32'h00500113; // initialize x2 = 5
    program_data[1]     = 32'h00c00193; // initialize x3 = 12
    program_data[2]     = 32'hff718393; // initialize x7 = 3
    program_data[3]     = 32'h0023e233; // x4 = (3 OR 5) = 7
    program_data[4]     = 32'h0041f2b3; // x5 = (12 AND 7) = 4
    program_data[5]     = 32'h004282b3; // x5 = 4 + 7 = 11
    program_data[6]     = 32'h02728663; // shouldn't be taken
    program_data[7]     = 32'h0041a233; // x4 = (12 < 7) = 0
    program_data[8]     = 32'h00020463; // should be taken
    program_data[9]     = 32'h00000293; // shouldn't happen
    program_data[10]    = 32'h0023a233; // x4 = (3 < 5) = 1
    program_data[11]    = 32'h005203b3; // x7 = 1 + 11 = 12
    program_data[12]    = 32'h402383b3; // x7 = 12 - 5 = 7
    program_data[13]    = 32'h0471a223; // [80] = 7
    program_data[14]    = 32'h05002103; // x2 = [80] = 7
    program_data[15]    = 32'h008001ef; // save 64 in x3
    program_data[16]    = 32'h00100113; // shouldn't happen
    program_data[17]    = 32'h00310133; // x2 = 7 + 64 = 71
    program_data[18]    = 32'h04202a23; // write mem[84] = 71
    program_data[19]    = 32'hfb5ff06f; // loop back to start
end

initial begin
    reset_n = 0;
    repeat(10) @(posedge clock);
    reset_n = 1;
end

initial begin
    riscv_core_program_memory_write_data                    = '0;
    riscv_core_program_memory_write_data_enable             = '0;
    riscv_core_program_memory_write_address                 = '0;
    riscv_core_pipelined_program_memory_write_data          = '0;
    riscv_core_pipelined_program_memory_write_data_enable   = '0;
    riscv_core_pipelined_program_memory_write_address       = '0;
    halt    = 1;
    wait(reset_n);
    repeat(10) @(posedge clock);
    
    for (i = 0; i < PROGRAM_SIZE; i = i + 1) begin
        @(posedge clock);
        riscv_core_program_memory_write_address                 = i;
        riscv_core_program_memory_write_data                    = program_data[i];
        riscv_core_program_memory_write_data_enable             = '1;
        riscv_core_pipelined_program_memory_write_address       = i;
        riscv_core_pipelined_program_memory_write_data          = program_data[i];
        riscv_core_pipelined_program_memory_write_data_enable   = '1;
    end
    @(posedge clock);
    riscv_core_program_memory_write_data                    = '0;
    riscv_core_program_memory_write_data_enable             = '0;
    riscv_core_pipelined_program_memory_write_data          = '0;
    riscv_core_pipelined_program_memory_write_data_enable   = '0;
    halt    = 0;
    repeat(555) @(posedge clock);
    $stop();
end


assign riscv_core_clock             = clock;
assign riscv_core_reset_n           = reset_n;
assign riscv_core_halt              = halt;

assign riscv_core_pipelined_clock   = clock;
assign riscv_core_pipelined_reset_n = reset_n;
assign riscv_core_pipelined_halt    = halt;


endmodule