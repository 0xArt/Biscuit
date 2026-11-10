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

// Three cores. The single cycle core and the pipelined core run the program
// below, and case_000 checks what it leaves behind in both. A second pipelined
// core runs the scoreboard program, which case_001 checks.
module testbench;

localparam  CLOCK_FREQUENCY = 100_000_000;
localparam  CLOCK_PERIOD    = 1e9/CLOCK_FREQUENCY;
localparam  PROGRAM_SIZE    = 40;
localparam  SCOREBOARD_SIZE = 27;

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


// ---- a pipelined core on the scoreboard program, for case_001 ----
logic [31:0]    riscv_core_pipelined_scoreboard_program_memory_write_data;
logic           riscv_core_pipelined_scoreboard_program_memory_write_data_enable;
logic [31:0]    riscv_core_pipelined_scoreboard_program_memory_write_address;
logic [31:0]    scoreboard_program [0:SCOREBOARD_SIZE-1];

riscv_core_pipelined riscv_core_pipelined_scoreboard(
    .clock                              (riscv_core_pipelined_clock),
    .reset_n                            (riscv_core_pipelined_reset_n),
    .halt                               (riscv_core_pipelined_halt),
    .program_memory_write_data          (riscv_core_pipelined_scoreboard_program_memory_write_data),
    .program_memory_write_data_enable   (riscv_core_pipelined_scoreboard_program_memory_write_data_enable),
    .program_memory_write_address       (riscv_core_pipelined_scoreboard_program_memory_write_address)
);

// two writers of one register back to back, and a register written down the
// wrong path of a loop's exit: the scoreboard holds one bit per register, and
// each of these used to leave it wrong
initial begin
    scoreboard_program[0]  = 32'h00000013; // nop
    scoreboard_program[1]  = 32'h00000013; // nop
    scoreboard_program[2]  = 32'h00000013; // nop
    scoreboard_program[3]  = 32'h12345337; // lui  t1, 0x12345
    scoreboard_program[4]  = 32'h67830313; // addi t1, t1, 0x678  -- a second writer of t1 right behind the first
    scoreboard_program[5]  = 32'h04602023; // sw   t1, 64(zero)    -- must store 0x12345678
    scoreboard_program[6]  = 32'habcde3b7; // lui  t2, 0xabcde
    scoreboard_program[7]  = 32'h12338393; // addi t2, t2, 0x123
    scoreboard_program[8]  = 32'h00038e33; // add  t3, t2, zero    -- must read 0xabcde123
    scoreboard_program[9]  = 32'h00300513; // addi a0, zero, 3
    scoreboard_program[10] = 32'h00000593; // addi a1, zero, 0
    scoreboard_program[11] = 32'h00158593; // loop: addi a1, a1, 1
    scoreboard_program[12] = 32'hfff50513; // addi a0, a0, -1      -- also fetched down the wrong path as the loop exits
    scoreboard_program[13] = 32'hfe051ce3; // bne  a0, zero, loop
    scoreboard_program[14] = 32'h00058613; // addi a2, a1, 0
    scoreboard_program[15] = 32'h00a58593; // addi a1, a1, 10
    scoreboard_program[16] = 32'h00c58eb3; // add  t4, a1, a2
    scoreboard_program[17] = 32'h05d02223; // sw   t4, 68(zero)    -- 13 + 3 = 16
    scoreboard_program[18] = 32'h00700513; // addi a0, zero, 7     -- a writer of a0 after the wrong path's flushed one
    scoreboard_program[19] = 32'h04a02423; // sw   a0, 72(zero)    -- must store 7
    scoreboard_program[20] = 32'h03000793; // addi a5, zero, 0x30
    scoreboard_program[21] = 32'h00178713; // addi a4, a5, 1       -- still busy when the xor is let in
    scoreboard_program[22] = 32'h00e7c7b3; // xor  a5, a5, a4      -- reads the register it writes, and waits on a4
    scoreboard_program[23] = 32'h04f02623; // sw   a5, 76(zero)    -- 0x30 ^ 0x31 = 1
    scoreboard_program[24] = 32'h00500413; // addi s0, zero, 5
    scoreboard_program[25] = 32'h00802423; // sw   s0, 8(zero)     -- the offset's low bits name s0, the register it stores
    scoreboard_program[26] = 32'h0000006f; // j    .
end


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
    program_data[19]    = 32'h00000013; // nop (fall through into the jalr/sub-word tests)
    //jalr coverage: target only known from rs1 at execute
    program_data[20]    = 32'h00000317; // auipc x6, 0        -> x6 = 80 (this pc)
    program_data[21]    = 32'h010300e7; // jalr x1, 16(x6)    -> jump to pc 96, x1 = 88 (link)
    program_data[22]    = 32'h29a00e13; // x28 = 666, must be SKIPPED by the jalr
    program_data[23]    = 32'h29b00e93; // x29 = 667, must be SKIPPED by the jalr
    program_data[24]    = 32'h04102c23; // pc 96: mem[88] = x1 = 88 (proves jalr target and link)
    //sub-word store/load coverage
    program_data[25]    = 32'hfff00513; // x10 = -1
    program_data[26]    = 32'h04a02e23; // mem[92] = 0xFFFFFFFF
    program_data[27]    = 32'h12300593; // x11 = 0x123
    program_data[28]    = 32'h04b01f23; // sh x11, 94(x0)  (upper halfword lane)
    program_data[29]    = 32'h05e01603; // lh  x12, 94(x0) -> 0x123 = 291
    program_data[30]    = 32'h05e05683; // lhu x13, 94(x0) -> 291
    program_data[31]    = 32'hffe00713; // x14 = -2
    program_data[32]    = 32'h04e01d23; // sh x14, 90(x0)
    program_data[33]    = 32'h05a01783; // lh  x15, 90(x0) -> -2 (sign-extend)
    program_data[34]    = 32'h05a05803; // lhu x16, 90(x0) -> 65534 (zero-extend)
    program_data[35]    = 32'hffb00913; // x18 = -5
    program_data[36]    = 32'h05200ca3; // sb x18, 89(x0)  (byte lane 1)
    program_data[37]    = 32'h05900983; // lb  x19, 89(x0) -> -5 (sign-extend)
    program_data[38]    = 32'h05904a03; // lbu x20, 89(x0) -> 251 (zero-extend)
    program_data[39]    = 32'hf65ff06f; // loop back to start (jal x0, -156)
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
    riscv_core_pipelined_scoreboard_program_memory_write_data           = '0;
    riscv_core_pipelined_scoreboard_program_memory_write_data_enable    = '0;
    riscv_core_pipelined_scoreboard_program_memory_write_address        = '0;
    halt    = 1;
    wait(reset_n);
    repeat(10) @(posedge clock);

    for (i = 0; i < SCOREBOARD_SIZE; i = i + 1) begin
        @(posedge clock);
        riscv_core_pipelined_scoreboard_program_memory_write_address       = i;
        riscv_core_pipelined_scoreboard_program_memory_write_data          = scoreboard_program[i];
        riscv_core_pipelined_scoreboard_program_memory_write_data_enable   = '1;
    end
    @(posedge clock);
    riscv_core_pipelined_scoreboard_program_memory_write_data_enable   = '0;
    
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
    case_000();
    case_001();
    $stop();
end

`include "case_000/case_000.svh"
`include "case_001/case_001.svh"


assign riscv_core_clock             = clock;
assign riscv_core_reset_n           = reset_n;
assign riscv_core_halt              = halt;

assign riscv_core_pipelined_clock   = clock;
assign riscv_core_pipelined_reset_n = reset_n;
assign riscv_core_pipelined_halt    = halt;


endmodule