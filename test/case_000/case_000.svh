//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
//
// Create Date: 11/09/2026
// Design Name:
// Module Name: case_000
// Project Name:
// Target Devices:
// Tool Versions:
// Description: self checking pass over the test program on both cores
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


`ifndef _case_000_svh_
`define _case_000_svh_

//self checking pass over the architectural state left behind by the test
//program. every expected value is stable across loop iterations of the
//program, so the check does not depend on where the run window stops.

integer case_000_checks;

task check(input string name, input logic [31:0] got, input logic [31:0] expected);
    if (got !== expected) begin
        $fatal(0, "%s: got %0d (0x%08x), expected %0d (0x%08x)", name, got, got, expected, expected);
    end
    case_000_checks = case_000_checks + 1;
endtask

task case_000();

case_000_checks = 0;

$display("Running case 000");

//---------------- single cycle core ----------------
//branch / arithmetic / word store chain
check("sc mem[80]",   testbench.riscv_core.riscv_data_memory.byte_lane[0].block_ram.inferred.generic_block_ram.memory[80], 7);
check("sc mem[84]",   testbench.riscv_core.riscv_data_memory.byte_lane[0].block_ram.inferred.generic_block_ram.memory[84], 71);
//jalr: correct target, link value stored, fall-through squashed
check("sc mem[88]",   testbench.riscv_core.riscv_data_memory.byte_lane[0].block_ram.inferred.generic_block_ram.memory[88], 88);
check("sc x1",        testbench.riscv_core.riscv_register_file.registers[1],  88);
check("sc x28",       testbench.riscv_core.riscv_register_file.registers[28], 0);
check("sc x29",       testbench.riscv_core.riscv_register_file.registers[29], 0);
//sub-word stores land in the right byte lanes
check("sc mem[94].2", testbench.riscv_core.riscv_data_memory.byte_lane[2].block_ram.inferred.generic_block_ram.memory[94], 8'h23);
check("sc mem[94].3", testbench.riscv_core.riscv_data_memory.byte_lane[3].block_ram.inferred.generic_block_ram.memory[94], 8'h01);
check("sc mem[90].2", testbench.riscv_core.riscv_data_memory.byte_lane[2].block_ram.inferred.generic_block_ram.memory[90], 8'hFE);
check("sc mem[90].3", testbench.riscv_core.riscv_data_memory.byte_lane[3].block_ram.inferred.generic_block_ram.memory[90], 8'hFF);
check("sc mem[89].1", testbench.riscv_core.riscv_data_memory.byte_lane[1].block_ram.inferred.generic_block_ram.memory[89], 8'hFB);
//sub-word loads: lane select plus sign/zero extension
check("sc x12 (lh)",  testbench.riscv_core.riscv_register_file.registers[12], 291);
check("sc x13 (lhu)", testbench.riscv_core.riscv_register_file.registers[13], 291);
check("sc x15 (lh)",  testbench.riscv_core.riscv_register_file.registers[15], -2);
check("sc x16 (lhu)", testbench.riscv_core.riscv_register_file.registers[16], 65534);
check("sc x19 (lb)",  testbench.riscv_core.riscv_register_file.registers[19], -5);
check("sc x20 (lbu)", testbench.riscv_core.riscv_register_file.registers[20], 251);

//---------------- pipelined core ----------------
check("pl mem[80]",   testbench.riscv_core_pipelined.riscv_data_memory.byte_lane[0].block_ram.inferred.generic_block_ram.memory[80], 7);
check("pl mem[84]",   testbench.riscv_core_pipelined.riscv_data_memory.byte_lane[0].block_ram.inferred.generic_block_ram.memory[84], 71);
check("pl mem[88]",   testbench.riscv_core_pipelined.riscv_data_memory.byte_lane[0].block_ram.inferred.generic_block_ram.memory[88], 88);
check("pl x1",        testbench.riscv_core_pipelined.riscv_register_file.registers[1],  88);
check("pl x28",       testbench.riscv_core_pipelined.riscv_register_file.registers[28], 0);
check("pl x29",       testbench.riscv_core_pipelined.riscv_register_file.registers[29], 0);
check("pl mem[94].2", testbench.riscv_core_pipelined.riscv_data_memory.byte_lane[2].block_ram.inferred.generic_block_ram.memory[94], 8'h23);
check("pl mem[94].3", testbench.riscv_core_pipelined.riscv_data_memory.byte_lane[3].block_ram.inferred.generic_block_ram.memory[94], 8'h01);
check("pl mem[90].2", testbench.riscv_core_pipelined.riscv_data_memory.byte_lane[2].block_ram.inferred.generic_block_ram.memory[90], 8'hFE);
check("pl mem[90].3", testbench.riscv_core_pipelined.riscv_data_memory.byte_lane[3].block_ram.inferred.generic_block_ram.memory[90], 8'hFF);
check("pl mem[89].1", testbench.riscv_core_pipelined.riscv_data_memory.byte_lane[1].block_ram.inferred.generic_block_ram.memory[89], 8'hFB);
check("pl x12 (lh)",  testbench.riscv_core_pipelined.riscv_register_file.registers[12], 291);
check("pl x13 (lhu)", testbench.riscv_core_pipelined.riscv_register_file.registers[13], 291);
check("pl x15 (lh)",  testbench.riscv_core_pipelined.riscv_register_file.registers[15], -2);
check("pl x16 (lhu)", testbench.riscv_core_pipelined.riscv_register_file.registers[16], 65534);
check("pl x19 (lb)",  testbench.riscv_core_pipelined.riscv_register_file.registers[19], -5);
check("pl x20 (lbu)", testbench.riscv_core_pipelined.riscv_register_file.registers[20], 251);

$display("case 000 passed: %0d/34 checks", case_000_checks);

endtask: case_000

`endif
