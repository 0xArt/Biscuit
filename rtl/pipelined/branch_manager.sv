`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 05/06/2026
// Design Name: 
// Module Name: branch_manager
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

module branch_manager(
    input   wire            execute_enable,
    input   wire    [6:0]   opcode,
    input   wire            branch_taken,
    input   wire            branch_result,
    input   wire    [31:0]  unbranched_program_counter,
    input   wire    [31:0]  jalr_target,

    output  logic           flush_frontend,          // fetch, decode, register_status_table
    output  logic           flush_execute,           // execute only (branch mispredict)
    output  logic           prediction_correct,
    output  logic           valid,
    output  logic   [31:0]  correct_program_counter
);


logic branch_enable;
logic jalr_redirect;

always_comb begin
    branch_enable           = execute_enable && (opcode == OP_BRANCH);
    jalr_redirect           = execute_enable && (opcode == OP_JALR);

    valid                   = '0;
    prediction_correct      = '0;
    flush_frontend          = '0;
    flush_execute           = '0;
    correct_program_counter = unbranched_program_counter;

    if (branch_enable) begin
        valid = '1;

        if (branch_taken == branch_result) begin
            prediction_correct = '1;
        end
        else begin
            // misprediction: squash the speculative path and redirect
            prediction_correct      = '0;
            flush_frontend          = '1;
            flush_execute           = '1;
            correct_program_counter = unbranched_program_counter;
        end
    end
    if (jalr_redirect) begin
        // JALR target (rs1 + imm) is only known now; squash the wrongly
        // fetched fall-through path and redirect. The execute stage outputs
        // are registered, so by the time the JALR is visible here it has
        // already shipped downstream (its link write is safe); flush_execute
        // kills the wrong-path instruction currently inside execute.
        flush_frontend          = '1;
        flush_execute           = '1;
        correct_program_counter = jalr_target & 32'hFFFFFFFE;
    end
end


endmodule