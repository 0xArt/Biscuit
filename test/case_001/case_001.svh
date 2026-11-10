//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
//
// Create Date: 11/09/2026
// Design Name:
// Module Name: case_001
// Project Name:
// Target Devices:
// Tool Versions:
// Description: self checking pass over the scoreboard program
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


`ifndef _case_001_svh_
`define _case_001_svh_

//the scoreboard program on the pipelined core: a store and an add right
//behind a second writer of their register read the second writer's value,
//and a register a flushed instruction was about to mark busy can still be
//written and read, an instruction that reads the register it writes is not
//held by its own busy mark, a store whose offset's low bits name its data
//register still waits for that register, with nothing left busy at the end

integer case_001_checks;

task check_scoreboard(input string name, input logic [31:0] got, input logic [31:0] expected);
    if (got !== expected) begin
        $fatal(0, "%s: got %0d (0x%08x), expected %0d (0x%08x)", name, got, got, expected, expected);
    end
    case_001_checks = case_001_checks + 1;
endtask

function automatic logic [31:0] scoreboard_word(input integer row);
    scoreboard_word = {testbench.riscv_core_pipelined_scoreboard.riscv_data_memory.genblk1[3].block_ram.genblk1.generic_block_ram.memory[row],
                       testbench.riscv_core_pipelined_scoreboard.riscv_data_memory.genblk1[2].block_ram.genblk1.generic_block_ram.memory[row],
                       testbench.riscv_core_pipelined_scoreboard.riscv_data_memory.genblk1[1].block_ram.genblk1.generic_block_ram.memory[row],
                       testbench.riscv_core_pipelined_scoreboard.riscv_data_memory.genblk1[0].block_ram.genblk1.generic_block_ram.memory[row]};
endfunction

task case_001();

case_001_checks = 0;

$display("Running case 001");

check_scoreboard("mem[64], stored behind a second writer", scoreboard_word(64), 32'h1234_5678);
check_scoreboard("t3, added behind a second writer",       testbench.riscv_core_pipelined_scoreboard.riscv_register_file.registers[28], 32'habcd_e123);
check_scoreboard("mem[68], the loop's sum",                 scoreboard_word(68), 32'd16);
check_scoreboard("mem[72], a0 written after the flush",    scoreboard_word(72), 32'd7);
check_scoreboard("a0",                                      testbench.riscv_core_pipelined_scoreboard.riscv_register_file.registers[10], 32'd7);
check_scoreboard("mem[76], an xor of its own register",   scoreboard_word(76), 32'd1);
check_scoreboard("a5",                                      testbench.riscv_core_pipelined_scoreboard.riscv_register_file.registers[15], 32'd1);
check_scoreboard("mem[8], s0 stored behind its writer",    scoreboard_word(8), 32'd5);
check_scoreboard("nothing left busy",                       testbench.riscv_core_pipelined_scoreboard.register_status_table_status, 32'd0);

$display("case 001 passed: %0d/9 checks", case_001_checks);

endtask: case_001

`endif
