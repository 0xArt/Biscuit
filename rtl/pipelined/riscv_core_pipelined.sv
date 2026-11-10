`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 12/30/2025
// Design Name: 
// Module Name: riscv_core_pipelined
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

module riscv_core_pipelined #(
    parameter INSTRUCTION_MEMORY_DEPTH  = 4096,
    parameter DATA_MEMORY_DEPTH         = 4096,
    parameter DATA_START_ADDRESS        = 'h0,
    parameter TECHNOLOGY                = "SIMULATION"
)(
    input wire                                          clock,
    input wire                                          reset_n,
    input wire                                          halt,
    input wire  [31:0]                                  program_memory_write_data,
    input wire                                          program_memory_write_data_enable,
    input wire [$clog2(INSTRUCTION_MEMORY_DEPTH)-1:0]   program_memory_write_address
);


wire                                        riscv_instruction_memory_clock;
wire                                        riscv_instruction_memory_reset_n;
wire [$clog2(INSTRUCTION_MEMORY_DEPTH)-1:0] riscv_instruction_memory_read_address;
wire                                        riscv_instruction_memory_write_protect;
wire                                        riscv_instruction_memory_write_enable;
wire [31:0]                                 riscv_instruction_memory_write_data;
wire [$clog2(INSTRUCTION_MEMORY_DEPTH)-1:0] riscv_instruction_memory_write_address;
wire [3:0]                                  riscv_instruction_memory_write_byte_select;

wire [31:0]                                 riscv_instruction_memory_read_data;

riscv_memory #(
    .MEMORY_DEPTH   (INSTRUCTION_MEMORY_DEPTH),
    .TECHNOLOGY     (TECHNOLOGY)
)riscv_instruction_memory(
    .clock                  (riscv_instruction_memory_clock),
    .reset_n                (riscv_instruction_memory_reset_n),
    .read_address           (riscv_instruction_memory_read_address),
    .write_protect          (riscv_instruction_memory_write_protect),
    .write_enable           (riscv_instruction_memory_write_enable),
    .write_data             (riscv_instruction_memory_write_data),
    .write_address          (riscv_instruction_memory_write_address),
    .write_byte_select      (riscv_instruction_memory_write_byte_select),

    .read_data              (riscv_instruction_memory_read_data)
);


wire        riscv_register_file_clock;
wire        riscv_register_file_reset_n;
wire [4:0]  riscv_register_file_read_address_one;
wire [4:0]  riscv_register_file_read_address_two_a;
wire [4:0]  riscv_register_file_read_address_two_b;
wire        riscv_register_file_write_enable;
wire [4:0]  riscv_register_file_write_address;
wire [31:0] riscv_register_file_write_data;

wire [31:0] riscv_register_file_read_data_one;
wire [31:0] riscv_register_file_read_data_two_a;
wire [31:0] riscv_register_file_read_data_two_b;

riscv_register_file riscv_register_file(
    .clock              (riscv_register_file_clock),
    .reset_n            (riscv_register_file_reset_n),
    .read_address_one   (riscv_register_file_read_address_one),
    .read_address_two_a (riscv_register_file_read_address_two_a),
    .read_address_two_b (riscv_register_file_read_address_two_b),
    .write_enable       (riscv_register_file_write_enable),
    .write_address      (riscv_register_file_write_address),      
    .write_data         (riscv_register_file_write_data),

    .read_data_one      (riscv_register_file_read_data_one),
    .read_data_two_a    (riscv_register_file_read_data_two_a),
    .read_data_two_b    (riscv_register_file_read_data_two_b)
);


wire                                        riscv_data_memory_clock;
wire                                        riscv_data_memory_reset_n;
wire [$clog2(DATA_MEMORY_DEPTH)-1:0]        riscv_data_memory_read_address;
wire                                        riscv_data_memory_write_protect;
wire                                        riscv_data_memory_write_enable;
wire [31:0]                                 riscv_data_memory_write_data;
wire [$clog2(DATA_MEMORY_DEPTH)-1:0]        riscv_data_memory_write_address;
wire [3:0]                                  riscv_data_memory_write_byte_select;

wire [31:0]                                 riscv_data_memory_read_data;

riscv_memory #(
    .MEMORY_DEPTH   (DATA_MEMORY_DEPTH),
    .TECHNOLOGY     (TECHNOLOGY)
)riscv_data_memory(
    .clock                  (riscv_data_memory_clock),
    .reset_n                (riscv_data_memory_reset_n),
    .read_address           (riscv_data_memory_read_address),
    .write_protect          (riscv_data_memory_write_protect),
    .write_enable           (riscv_data_memory_write_enable),
    .write_data             (riscv_data_memory_write_data),
    .write_address          (riscv_data_memory_write_address),
    .write_byte_select      (riscv_data_memory_write_byte_select),

    .read_data              (riscv_data_memory_read_data)
);


wire        register_status_table_clock;
wire        register_status_table_reset_n;
wire [4:0]  register_status_table_retire_register;
wire        register_status_table_retire_enable;
wire [4:0]  register_status_table_busy_register;
wire        register_status_table_busy_enable;
wire        register_status_table_flush;

wire [31:0] register_status_table_status;

register_status_table register_status_table(
    .clock              (register_status_table_clock),
    .reset_n            (register_status_table_reset_n),
    .retire_register    (register_status_table_retire_register),
    .retire_enable      (register_status_table_retire_enable),
    .busy_register      (register_status_table_busy_register),
    .busy_enable        (register_status_table_busy_enable),
    .flush              (register_status_table_flush),

    .status             (register_status_table_status)
);


wire        base_branch_predictor_clock;
wire        base_branch_predictor_reset_n;
wire        base_branch_predictor_prediction_enable;
wire        base_branch_predictor_prediction_correct;
wire        base_branch_predictor_branch_taken;
wire [31:0] base_branch_predictor_program_counter_prediction;
wire        base_branch_predictor_update_enable;
wire [31:0] base_branch_predictor_program_counter_update;

wire        base_branch_predictor_valid;
wire        base_branch_predictor_take_branch;

base_branch_predictor base_branch_predictor(
    .clock                          (base_branch_predictor_clock),
    .reset_n                        (base_branch_predictor_reset_n),
    .prediction_enable              (base_branch_predictor_prediction_enable),
    .prediction_correct             (base_branch_predictor_prediction_correct),
    .branch_taken                   (base_branch_predictor_branch_taken),
    .program_counter_prediction     (base_branch_predictor_program_counter_prediction),
    .update_enable                  (base_branch_predictor_update_enable),
    .program_counter_update         (base_branch_predictor_program_counter_update),

    .valid                          (base_branch_predictor_valid),
    .take_branch                    (base_branch_predictor_take_branch)
);


wire            branch_manager_execute_enable;
wire    [6:0]   branch_manager_opcode;
wire            branch_manager_branch_taken;
wire            branch_manager_branch_result;
wire    [31:0]  branch_manager_unbranched_program_counter;
wire    [31:0]  branch_manager_jalr_target;

wire            branch_manager_flush_frontend;
wire            branch_manager_flush_execute;
wire            branch_manager_prediction_correct;
wire            branch_manager_valid;
wire    [31:0]  branch_manager_correct_program_counter;

branch_manager branch_manager(
    .execute_enable                  (branch_manager_execute_enable),
    .opcode                         (branch_manager_opcode),
    .branch_taken                   (branch_manager_branch_taken),
    .branch_result                  (branch_manager_branch_result),
    .unbranched_program_counter     (branch_manager_unbranched_program_counter),
    .jalr_target                    (branch_manager_jalr_target),

    .flush_frontend                 (branch_manager_flush_frontend),
    .flush_execute                  (branch_manager_flush_execute),
    .prediction_correct             (branch_manager_prediction_correct),
    .valid                          (branch_manager_valid),
    .correct_program_counter        (branch_manager_correct_program_counter)
);


wire            fetch_stage_clock;
wire            fetch_stage_reset_n;
wire            fetch_stage_halt;
wire            fetch_stage_enable;
wire            fetch_stage_upstream_enable;
wire    [31:0]  fetch_stage_memory_read_data;
wire            fetch_stage_flush;
wire            fetch_stage_prediction_incorrect;
wire    [31:0]  fetch_stage_correct_program_counter;

wire    [31:0]  fetch_stage_instruction;
wire            fetch_stage_valid;
wire    [31:0]  fetch_stage_memory_address;
wire    [31:0]  fetch_stage_program_counter;
wire    [31:0]  fetch_stage_unbranched_program_counter;
wire            fetch_stage_branch_taken;

fetch_stage fetch_stage(
    .clock                      (fetch_stage_clock),
    .reset_n                    (fetch_stage_reset_n),
    .enable                     (fetch_stage_enable),
    .upstream_enable            (fetch_stage_upstream_enable),
    .memory_read_data           (fetch_stage_memory_read_data),
    .take_branch                (fetch_stage_take_branch),
    .flush                      (fetch_stage_flush),
    .correct_program_counter    (fetch_stage_correct_program_counter),

    .instruction                (fetch_stage_instruction),
    .valid                      (fetch_stage_valid),
    .memory_address             (fetch_stage_memory_address),
    .program_counter            (fetch_stage_program_counter),
    .unbranched_program_counter (fetch_stage_unbranched_program_counter),
    .branch_taken               (fetch_stage_branch_taken)
);


wire            decode_stage_clock;
wire            decode_stage_reset_n;
wire            decode_stage_enable;
wire            decode_stage_flush;
wire            decode_stage_upstream_enable;
wire    [31:0]  decode_stage_instruction;
wire    [31:0]  decode_stage_program_counter_delivered;
wire    [31:0]  decode_stage_unbranched_program_counter_delivered;
wire            decode_stage_branch_taken_delivered;
wire    [31:0]  decode_stage_register_status;

wire            decode_stage_ready;
wire            decode_stage_valid;
wire            decode_stage_register_status_valid;
wire    [6:0]   decode_stage_opcode;
wire    [4:0]   decode_stage_rd;
wire    [4:0]   decode_stage_rs1;
wire    [4:0]   decode_stage_rs2;
wire    [2:0]   decode_stage_funct3;
wire    [6:0]   decode_stage_funct7;
wire    [31:0]  decode_stage_immediate;
wire    [3:0]   decode_stage_instruction_type;
wire            decode_stage_alu_source;
wire    [31:0]  decode_stage_program_counter_shipped;
wire    [31:0]  decode_stage_unbranched_program_counter_shipped;
wire            decode_stage_branch_taken_shipped;

decode_stage decode_stage(
    .clock                                  (decode_stage_clock),
    .reset_n                                (decode_stage_reset_n),
    .enable                                 (decode_stage_enable),
    .flush                                  (decode_stage_flush),
    .upstream_enable                        (decode_stage_upstream_enable),
    .instruction                            (decode_stage_instruction),
    .program_counter_delivered              (decode_stage_program_counter_delivered),
    .unbranched_program_counter_delivered   (decode_stage_unbranched_program_counter_delivered),
    .branch_taken_delivered                 (decode_stage_branch_taken_delivered),
    .register_status                        (decode_stage_register_status),
    
    .ready                                  (decode_stage_ready),
    .valid                                  (decode_stage_valid),
    .register_status_valid                  (decode_stage_register_status_valid),
    .opcode                                 (decode_stage_opcode),
    .rd                                     (decode_stage_rd),
    .rs1                                    (decode_stage_rs1),
    .rs2                                    (decode_stage_rs2),
    .funct3                                 (decode_stage_funct3),
    .funct7                                 (decode_stage_funct7),
    .immediate                              (decode_stage_immediate),
    .instruction_type                       (decode_stage_instruction_type),
    .alu_source                             (decode_stage_alu_source),
    .program_counter_shipped                (decode_stage_program_counter_shipped),
    .unbranched_program_counter_shipped     (decode_stage_unbranched_program_counter_shipped),
    .branch_taken_shipped                   (decode_stage_branch_taken_shipped)
);


wire            execute_stage_clock;
wire            execute_stage_reset_n;
wire            execute_stage_enable;
wire            execute_stage_flush;
wire            execute_stage_upstream_enable;
wire    [31:0]  execute_stage_register_status;
wire    [31:0]  execute_stage_register_file_read_data_one;
wire    [31:0]  execute_stage_register_file_read_data_two_delivered;
wire    [6:0]   execute_stage_opcode_delivered;
wire    [4:0]   execute_stage_rd_delivered;
wire    [4:0]   execute_stage_rs1_delivered;
wire    [4:0]   execute_stage_rs2_delivered;
wire    [2:0]   execute_stage_funct3_delivered;
wire    [6:0]   execute_stage_funct7;
wire    [31:0]  execute_stage_immediate_delivered;
wire    [3:0]   execute_stage_instruction_type_delivered;
wire            execute_stage_alu_source;
wire    [31:0]  execute_stage_program_counter_delivered;
wire    [31:0]  execute_stage_unbranched_program_counter_delivered;
wire            execute_stage_branch_taken_delivered;

wire            execute_stage_ready;
wire    [31:0]  execute_stage_register_file_read_data_two_shipped;
wire    [4:0]   execute_stage_rd_shipped;
wire    [4:0]   execute_stage_rs1_shipped;
wire    [4:0]   execute_stage_rs2_shipped;
wire    [6:0]   execute_stage_opcode_shipped;
wire    [31:0]  execute_stage_immediate_shipped;
wire    [3:0]   execute_stage_instruction_type_shipped;
wire    [31:0]  execute_stage_program_counter_shipped;
wire    [2:0]   execute_stage_funct3_shipped;
wire    [31:0]  execute_stage_alu_result;
wire    [31:0]  execute_stage_unbranched_program_counter_shipped;
wire            execute_stage_branch_taken_shipped;
wire            execute_stage_take_branch;
wire            execute_stage_valid;

execute_stage execute_stage(
    .clock                                  (execute_stage_clock),
    .reset_n                                (execute_stage_reset_n),
    .enable                                 (execute_stage_enable),
    .flush                                  (execute_stage_flush),
    .upstream_enable                        (execute_stage_upstream_enable),
    .register_status                        (execute_stage_register_status),
    .alu_source                             (execute_stage_alu_source),
    .register_file_read_data_one            (execute_stage_register_file_read_data_one),
    .register_file_read_data_two_delivered  (execute_stage_register_file_read_data_two_delivered),
    .opcode_delivered                       (execute_stage_opcode_delivered),
    .rd_delivered                           (execute_stage_rd_delivered),
    .rs1_delivered                          (execute_stage_rs1_delivered),
    .rs2_delivered                          (execute_stage_rs2_delivered),
    .funct3_delivered                       (execute_stage_funct3_delivered),
    .funct7                                 (execute_stage_funct7),
    .immediate_delivered                    (execute_stage_immediate_delivered),
    .instruction_type_delivered             (execute_stage_instruction_type_delivered),
    .program_counter_delivered              (execute_stage_program_counter_delivered),
    .unbranched_program_counter_delivered   (execute_stage_unbranched_program_counter_delivered),
    .branch_taken_delivered                 (execute_stage_branch_taken_delivered),

    .ready                                  (execute_stage_ready),
    .unbranched_program_counter_shipped     (execute_stage_unbranched_program_counter_shipped),
    .branch_taken_shipped                   (execute_stage_branch_taken_shipped),
    .register_file_read_data_two_shipped    (execute_stage_register_file_read_data_two_shipped),
    .rd_shipped                             (execute_stage_rd_shipped),
    .rs1_shipped                            (execute_stage_rs1_shipped),
    .rs2_shipped                            (execute_stage_rs2_shipped),
    .opcode_shipped                         (execute_stage_opcode_shipped),
    .immediate_shipped                      (execute_stage_immediate_shipped),
    .instruction_type_shipped               (execute_stage_instruction_type_shipped),
    .program_counter_shipped                (execute_stage_program_counter_shipped),
    .funct3_shipped                         (execute_stage_funct3_shipped),
    .alu_result                             (execute_stage_alu_result),
    .take_branch                            (execute_stage_take_branch),
    .valid                                  (execute_stage_valid)
);


wire                                    memory_stage_clock;
wire                                    memory_stage_reset_n;
wire                                    memory_stage_enable;
wire                                    memory_stage_upstream_enable;
wire   [31:0]                           memory_stage_register_status;
wire   [31:0]                           memory_stage_alu_result_delivered;
wire   [31:0]                           memory_stage_data_memory_read_data;
wire   [31:0]                           memory_stage_register_file_read_data_two;
wire   [31:0]                           memory_stage_immediate_delivered;
wire   [6:0]                            memory_stage_opcode_delivered;
wire   [4:0]                            memory_stage_rs2;
wire   [31:0]                           memory_stage_program_counter_delivered;
wire   [4:0]                            memory_stage_rd_delivered;
wire   [2:0]                            memory_stage_funct3;
wire   [3:0]                            memory_stage_instruction_type;

wire                                    memory_stage_ready;
wire   [31:0]                           memory_stage_program_counter_shipped;
wire   [4:0]                            memory_stage_rd_shipped;
wire   [6:0]                            memory_stage_opcode_shipped;
wire   [31:0]                           memory_stage_immediate_shipped;
wire   [31:0]                           memory_stage_alu_result_shipped;
wire   [31:0]                           memory_stage_read_data;
wire                                    memory_stage_read_data_valid;
wire   [31:0]                           memory_stage_write_data;
wire   [$clog2(DATA_MEMORY_DEPTH)-1:0]  memory_stage_write_address;
wire   [3:0]                            memory_stage_write_byte_select;
wire   [$clog2(DATA_MEMORY_DEPTH)-1:0]  memory_stage_read_address;
wire                                    memory_stage_valid;


memory_stage #(
    .DATA_START_ADDRESS (DATA_START_ADDRESS),
    .DATA_MEMORY_DEPTH  (DATA_MEMORY_DEPTH)
) memory_stage(
    .clock                          (memory_stage_clock),
    .reset_n                        (memory_stage_reset_n),
    .enable                         (memory_stage_enable),
    .upstream_enable                (memory_stage_upstream_enable),
    .occupant_arriving              (execute_stage_ready),
    .register_status                (memory_stage_register_status),
    .alu_result_delivered           (memory_stage_alu_result_delivered),
    .data_memory_read_data          (memory_stage_data_memory_read_data),
    .immediate_delivered            (memory_stage_immediate_delivered),
    .program_counter_delivered      (memory_stage_program_counter_delivered),
    .rd_delivered                   (memory_stage_rd_delivered),
    .opcode_delivered               (memory_stage_opcode_delivered),
    .rs2                            (memory_stage_rs2),
    .funct3                         (memory_stage_funct3),
    .instruction_type               (memory_stage_instruction_type),
    .register_file_read_data_two    (memory_stage_register_file_read_data_two),

    .ready                          (memory_stage_ready),
    .program_counter_shipped        (memory_stage_program_counter_shipped),
    .rd_shipped                     (memory_stage_rd_shipped),
    .opcode_shipped                 (memory_stage_opcode_shipped),
    .immediate_shipped              (memory_stage_immediate_shipped),
    .alu_result_shipped             (memory_stage_alu_result_shipped),
    .read_data                      (memory_stage_read_data),
    .read_data_valid                (memory_stage_read_data_valid),
    .write_data                     (memory_stage_write_data),
    .write_address                  (memory_stage_write_address),
    .write_byte_select              (memory_stage_write_byte_select),
    .read_address                   (memory_stage_read_address),
    .valid                          (memory_stage_valid)
);


wire            write_back_stage_clock;
wire            write_back_stage_reset_n;
wire            write_back_stage_enable;
wire            write_back_stage_upstream_enable;
wire    [6:0]   write_back_stage_opcode;
wire    [31:0]  write_back_stage_alu_result;
wire    [31:0]  write_back_stage_memory_read_data;
wire    [31:0]  write_back_stage_program_counter;
wire    [31:0]  write_back_stage_immediate;
wire    [4:0]   write_back_stage_rd_delivered;

wire            write_back_stage_ready;
wire    [4:0]   write_back_stage_rd_shipped;
wire    [31:0]  write_back_stage_write_data;
wire            write_back_stage_write_data_valid;
wire            write_back_stage_register_status_valid;
wire            write_back_stage_valid;

write_back_stage write_back_stage(
    .clock                      (write_back_stage_clock),
    .reset_n                    (write_back_stage_reset_n),
    .enable                     (write_back_stage_enable),
    .upstream_enable            (write_back_stage_upstream_enable),
    .opcode                     (write_back_stage_opcode),
    .alu_result                 (write_back_stage_alu_result),
    .memory_read_data           (write_back_stage_memory_read_data),
    .program_counter            (write_back_stage_program_counter),
    .immediate                  (write_back_stage_immediate),
    .rd_delivered               (write_back_stage_rd_delivered),

    .ready                      (write_back_stage_ready),
    .write_data                 (write_back_stage_write_data),
    .write_data_valid           (write_back_stage_write_data_valid),
    .rd_shipped                 (write_back_stage_rd_shipped),
    .register_status_valid      (write_back_stage_register_status_valid),
    .valid                      (write_back_stage_valid)
);


assign riscv_instruction_memory_clock                       = clock;
assign riscv_instruction_memory_reset_n                     = reset_n;
assign riscv_instruction_memory_write_byte_select           = 4'b1111;
assign riscv_instruction_memory_write_protect               = !halt;
assign riscv_instruction_memory_write_data                  = program_memory_write_data;
assign riscv_instruction_memory_write_enable                = program_memory_write_data_enable;
assign riscv_instruction_memory_write_address               = program_memory_write_address;
assign riscv_instruction_memory_read_address                = fetch_stage_memory_address;

assign riscv_register_file_clock                            = clock;
assign riscv_register_file_reset_n                          = reset_n;
assign riscv_register_file_read_address_one                 = decode_stage_rs1;
assign riscv_register_file_read_address_two_a               = decode_stage_rs2;
assign riscv_register_file_read_address_two_b               = execute_stage_rs2_shipped;
assign riscv_register_file_write_address                    = write_back_stage_rd_shipped;
assign riscv_register_file_write_data                       = write_back_stage_write_data;
assign riscv_register_file_write_enable                     = write_back_stage_write_data_valid;

assign riscv_data_memory_clock                              = clock;
assign riscv_data_memory_reset_n                            = reset_n;
assign riscv_data_memory_read_address                       = memory_stage_read_address;
assign riscv_data_memory_write_data                         = memory_stage_write_data;
assign riscv_data_memory_write_enable                       = |memory_stage_write_byte_select;
assign riscv_data_memory_write_byte_select                  = memory_stage_write_byte_select;
assign riscv_data_memory_write_address                      = memory_stage_write_address;
assign riscv_data_memory_write_protect                      = '0;

assign register_status_table_clock                          = clock;
assign register_status_table_reset_n                        = reset_n;
assign register_status_table_busy_register                  = decode_stage_rd;
assign register_status_table_busy_enable                    = decode_stage_register_status_valid;
assign register_status_table_retire_register                = write_back_stage_rd_shipped;
assign register_status_table_retire_enable                  = write_back_stage_register_status_valid;
assign register_status_table_flush                          = branch_manager_flush_frontend;

assign base_branch_predictor_clock                          = clock;
assign base_branch_predictor_reset_n                        = reset_n;
assign base_branch_predictor_prediction_enable              = '1;
assign base_branch_predictor_prediction_correct             = branch_manager_prediction_correct;
assign base_branch_predictor_branch_taken                   = execute_stage_branch_taken_shipped;
assign base_branch_predictor_program_counter_prediction     = fetch_stage_memory_address;
assign base_branch_predictor_update_enable                  = branch_manager_valid;
assign base_branch_predictor_program_counter_update         = execute_stage_program_counter_shipped >> 2;

assign branch_manager_execute_enable                        = execute_stage_valid;
assign branch_manager_opcode                                = execute_stage_opcode_shipped;
assign branch_manager_branch_taken                          = execute_stage_branch_taken_shipped;
assign branch_manager_branch_result                         = execute_stage_take_branch;
assign branch_manager_unbranched_program_counter            = execute_stage_unbranched_program_counter_shipped;
assign branch_manager_jalr_target                           = execute_stage_alu_result;

assign fetch_stage_clock                                    = clock;
assign fetch_stage_reset_n                                  = reset_n;
assign fetch_stage_enable                                   = !halt;
assign fetch_stage_upstream_enable                          = decode_stage_ready;
assign fetch_stage_memory_read_data                         = riscv_instruction_memory_read_data;
assign fetch_stage_take_branch                              = base_branch_predictor_take_branch;
assign fetch_stage_flush                                    = branch_manager_flush_frontend;
assign fetch_stage_correct_program_counter                  = branch_manager_correct_program_counter;

assign decode_stage_clock                                   = clock;
assign decode_stage_reset_n                                 = reset_n;
assign decode_stage_enable                                  = !halt && fetch_stage_valid;
assign decode_stage_flush                                   = branch_manager_flush_frontend;
assign decode_stage_upstream_enable                         = execute_stage_ready;
assign decode_stage_instruction                             = fetch_stage_instruction;
assign decode_stage_program_counter_delivered               = fetch_stage_program_counter;
assign decode_stage_unbranched_program_counter_delivered    = fetch_stage_unbranched_program_counter;
assign decode_stage_branch_taken_delivered                  = fetch_stage_branch_taken;
assign decode_stage_register_status                         = register_status_table_status;

assign execute_stage_clock                                  = clock;
assign execute_stage_reset_n                                = reset_n;
assign execute_stage_enable                                 = decode_stage_valid && !halt;
assign execute_stage_flush                                  = branch_manager_flush_execute;
assign execute_stage_upstream_enable                        = memory_stage_ready;
assign execute_stage_register_status                        = register_status_table_status;
assign execute_stage_register_file_read_data_one            = riscv_register_file_read_data_one;
assign execute_stage_register_file_read_data_two_delivered  = riscv_register_file_read_data_two_a;
assign execute_stage_opcode_delivered                       = decode_stage_opcode;
assign execute_stage_rd_delivered                           = decode_stage_rd;
assign execute_stage_rs1_delivered                          = decode_stage_rs1;
assign execute_stage_rs2_delivered                          = decode_stage_rs2;
assign execute_stage_funct3_delivered                       = decode_stage_funct3;
assign execute_stage_funct7                                 = decode_stage_funct7;
assign execute_stage_immediate_delivered                    = decode_stage_immediate;
assign execute_stage_instruction_type_delivered             = decode_stage_instruction_type;
assign execute_stage_alu_source                             = decode_stage_alu_source;
assign execute_stage_program_counter_delivered              = decode_stage_program_counter_shipped;
assign execute_stage_unbranched_program_counter_delivered   = decode_stage_unbranched_program_counter_shipped;
assign execute_stage_branch_taken_delivered                 = decode_stage_branch_taken_shipped;

assign memory_stage_clock                                   = clock;
assign memory_stage_reset_n                                 = reset_n;
assign memory_stage_enable                                  = execute_stage_valid && !halt;
assign memory_stage_upstream_enable                         = write_back_stage_ready;
assign memory_stage_register_status                         = register_status_table_status;
assign memory_stage_alu_result_delivered                    = execute_stage_alu_result;
assign memory_stage_data_memory_read_data                   = riscv_data_memory_read_data;
assign memory_stage_register_file_read_data_two             = riscv_register_file_read_data_two_b;
assign memory_stage_rs2                                     = execute_stage_rs2_shipped;
assign memory_stage_funct3                                  = execute_stage_funct3_shipped;
assign memory_stage_instruction_type                        = execute_stage_instruction_type_shipped;
assign memory_stage_immediate_delivered                     = execute_stage_immediate_shipped;
assign memory_stage_program_counter_delivered               = execute_stage_program_counter_shipped;
assign memory_stage_rd_delivered                            = execute_stage_rd_shipped;
assign memory_stage_opcode_delivered                        = execute_stage_opcode_shipped;

assign write_back_stage_clock                               = clock;
assign write_back_stage_reset_n                             = reset_n;
assign write_back_stage_enable                              = memory_stage_valid && !halt;
assign write_back_stage_upstream_enable                     = '1;
assign write_back_stage_opcode                              = memory_stage_opcode_shipped;
assign write_back_stage_alu_result                          = memory_stage_alu_result_shipped;
assign write_back_stage_memory_read_data                    = memory_stage_read_data;
assign write_back_stage_program_counter                     = memory_stage_program_counter_shipped;
assign write_back_stage_immediate                           = memory_stage_immediate_shipped;
assign write_back_stage_rd_delivered                        = memory_stage_rd_shipped;


endmodule