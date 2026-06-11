`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 10/18/2025
// Design Name: 
// Module Name: riscv_core
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
module riscv_core #(
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


wire        riscv_program_counter_clock;
wire        riscv_program_counter_reset_n;
wire        riscv_program_counter_halt;
wire [3:0]  riscv_program_counter_instruction_type;
wire [6:0]  riscv_program_counter_opcode;
wire [2:0]  riscv_program_counter_funct3;
wire [31:0] riscv_program_counter_alu_result;
wire [31:0] riscv_program_counter_immediate;
wire [31:0] riscv_program_counter_read_data_one;

wire [31:0] riscv_program_counter_result;

riscv_program_counter riscv_program_counter(
    .clock              (riscv_program_counter_clock),
    .reset_n            (riscv_program_counter_reset_n),
    .halt               (riscv_program_counter_halt),
    .instruction_type   (riscv_program_counter_instruction_type),
    .opcode             (riscv_program_counter_opcode),
    .funct3             (riscv_program_counter_funct3),
    .alu_result         (riscv_program_counter_alu_result),
    .immediate          (riscv_program_counter_immediate),
    .read_data_one      (riscv_program_counter_read_data_one),

    .result             (riscv_program_counter_result)
);


wire [31:0] riscv_instruction_decoder_instruction;

wire [6:0]  riscv_instruction_decoder_opcode;
wire [4:0]  riscv_instruction_decoder_rd;
wire [4:0]  riscv_instruction_decoder_rs1;
wire [4:0]  riscv_instruction_decoder_rs2;
wire [2:0]  riscv_instruction_decoder_funct3;
wire [6:0]  riscv_instruction_decoder_funct7;
wire [31:0] riscv_instruction_decoder_imm;
wire [3:0]  riscv_instruction_decoder_instruction_type;
wire        riscv_instruction_decoder_alu_source;


riscv_instruction_decoder riscv_instruction_decoder(
    .instruction    (riscv_instruction_decoder_instruction),

    .opcode             (riscv_instruction_decoder_opcode),
    .rd                 (riscv_instruction_decoder_rd),
    .rs1                (riscv_instruction_decoder_rs1),
    .rs2                (riscv_instruction_decoder_rs2),
    .funct3             (riscv_instruction_decoder_funct3),
    .funct7             (riscv_instruction_decoder_funct7),
    .imm                (riscv_instruction_decoder_imm),
    .instruction_type   (riscv_instruction_decoder_instruction_type),
    .alu_source         (riscv_instruction_decoder_alu_source)
);


wire [31:0] riscv_alu_src1;
wire [31:0] riscv_alu_src2;
wire [6:0]  riscv_alu_opcode;
wire [2:0]  riscv_alu_funct3;
wire [6:0]  riscv_alu_funct7;
wire [3:0]  riscv_alu_instruction_type;

wire [31:0] riscv_alu_result;
wire        riscv_alu_branch_taken;

riscv_alu   riscv_alu(
    .src1               (riscv_alu_src1),
    .src2               (riscv_alu_src2),
    .opcode             (riscv_alu_opcode),
    .funct3             (riscv_alu_funct3),
    .funct7             (riscv_alu_funct7),
    .instruction_type   (riscv_alu_instruction_type),

    .result             (riscv_alu_result),
    .branch_taken       (riscv_alu_branch_taken)
);


wire        riscv_register_file_clock;
wire        riscv_register_file_reset_n;
wire [4:0]  riscv_register_file_read_address_one;
wire [4:0]  riscv_register_file_read_address_two;
wire        riscv_register_file_write_enable;
wire [4:0]  riscv_register_file_write_address;
wire [31:0] riscv_register_file_write_data;

wire [31:0] riscv_register_file_read_data_one;
wire [31:0] riscv_register_file_read_data_two;

riscv_register_file riscv_register_file(
    .clock              (riscv_register_file_clock),
    .reset_n            (riscv_register_file_reset_n),
    .read_address_one   (riscv_register_file_read_address_one),
    .read_address_two_a (riscv_register_file_read_address_two),
    .read_address_two_b ('0),
    .write_enable       (riscv_register_file_write_enable),
    .write_address      (riscv_register_file_write_address),      
    .write_data         (riscv_register_file_write_data),

    .read_data_one      (riscv_register_file_read_data_one),
    .read_data_two_a    (riscv_register_file_read_data_two)   
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


wire [31:0]                             riscv_memory_writer_alu_result;
wire [2:0]                              riscv_memory_writer_funct3;
wire [31:0]                             riscv_memory_writer_read_data;
wire [3:0]                              riscv_memory_writer_instruction_type;

wire [3:0]                              riscv_memory_writer_write_byte_select;
wire [31:0]                             riscv_memory_writer_write_data;
wire [$clog2(DATA_MEMORY_DEPTH)-1:0]    riscv_memory_writer_write_address;

riscv_memory_writer #(
    .START_ADDRESS  (DATA_START_ADDRESS),
    .DEPTH          (DATA_MEMORY_DEPTH)
) riscv_memory_writer(
    .alu_result         (riscv_memory_writer_alu_result),
    .funct3             (riscv_memory_writer_funct3),
    .read_data          (riscv_memory_writer_read_data),
    .instruction_type   (riscv_memory_writer_instruction_type),

    .write_byte_select  (riscv_memory_writer_write_byte_select),
    .write_data         (riscv_memory_writer_write_data),
    .write_address      (riscv_memory_writer_write_address)
);


wire [31:0]                             riscv_memory_reader_data;
wire [2:0]                              riscv_memory_reader_funct3;
wire [31:0]                             riscv_memory_reader_alu_result;
wire [3:0]                              riscv_memory_reader_instruction_type;

wire [31:0]                             riscv_memory_reader_read_data;
wire                                    riscv_memory_reader_read_data_valid;
wire [$clog2(DATA_MEMORY_DEPTH-1):0]    riscv_memory_reader_read_address;

riscv_memory_reader #(
    .START_ADDRESS  (DATA_START_ADDRESS),
    .DEPTH          (DATA_MEMORY_DEPTH)
) riscv_memory_reader(
    .data               (riscv_memory_reader_data),
    .funct3             (riscv_memory_reader_funct3),
    .alu_result         (riscv_memory_reader_alu_result),
    .instruction_type   (riscv_memory_reader_instruction_type),

    .read_data          (riscv_memory_reader_read_data),
    .read_data_valid    (riscv_memory_reader_read_data_valid),
    .read_address       (riscv_memory_reader_read_address)
);


wire [6:0]  riscv_write_back_controller_opcode;
wire [31:0] riscv_write_back_controller_memory_read_data;
wire [31:0] riscv_write_back_controller_alu_result;
wire [31:0] riscv_write_back_controller_program_counter;
wire [31:0] riscv_write_back_controller_immediate;

wire [31:0] riscv_write_back_controller_write_data;
wire        riscv_write_back_controller_write_data_valid;

riscv_write_back_controller riscv_write_back_controller(
    .opcode             (riscv_write_back_controller_opcode),
    .memory_read_data   (riscv_write_back_controller_memory_read_data),
    .alu_result         (riscv_write_back_controller_alu_result),
    .program_counter    (riscv_write_back_controller_program_counter),
    .immediate          (riscv_write_back_controller_immediate),

    .write_data         (riscv_write_back_controller_write_data),
    .write_data_valid   (riscv_write_back_controller_write_data_valid)
);


assign riscv_instruction_memory_clock               = clock;
assign riscv_instruction_memory_reset_n             = reset_n;
assign riscv_instruction_memory_write_byte_select   = '1;
assign riscv_instruction_memory_write_protect       = !halt;
assign riscv_instruction_memory_write_data          = program_memory_write_data;
assign riscv_instruction_memory_write_enable        = program_memory_write_data_enable;
assign riscv_instruction_memory_write_address       = program_memory_write_address;
assign riscv_instruction_memory_read_address        = riscv_program_counter_result >> 2;

assign riscv_program_counter_clock                  = clock;
assign riscv_program_counter_reset_n                = reset_n;
assign riscv_program_counter_halt                   = halt;
assign riscv_program_counter_instruction_type       = riscv_instruction_decoder_instruction_type;
assign riscv_program_counter_opcode                 = riscv_instruction_decoder_opcode;
assign riscv_program_counter_funct3                 = riscv_instruction_decoder_funct3;
assign riscv_program_counter_alu_result             = riscv_alu_result;
assign riscv_program_counter_immediate              = riscv_instruction_decoder_imm;
assign riscv_program_counter_read_data_one          = riscv_register_file_read_data_one;

assign riscv_instruction_decoder_instruction        = riscv_instruction_memory_read_data;

assign riscv_alu_opcode                             = riscv_instruction_decoder_opcode;
assign riscv_alu_funct3                             = riscv_instruction_decoder_funct3;
assign riscv_alu_funct7                             = riscv_instruction_decoder_funct7;
assign riscv_alu_instruction_type                   = riscv_instruction_decoder_instruction_type;
assign riscv_alu_src1                               = riscv_register_file_read_data_one;
assign riscv_alu_src2                               = riscv_instruction_decoder_alu_source ? riscv_instruction_decoder_imm : riscv_register_file_read_data_two;

assign riscv_register_file_clock                    = clock;
assign riscv_register_file_reset_n                  = reset_n;
assign riscv_register_file_read_address_one         = riscv_instruction_decoder_rs1;
assign riscv_register_file_read_address_two         = riscv_instruction_decoder_rs2;
assign riscv_register_file_write_address            = riscv_instruction_decoder_rd;
assign riscv_register_file_write_data               = riscv_write_back_controller_write_data;
assign riscv_register_file_write_enable             = riscv_write_back_controller_write_data_valid;

assign riscv_data_memory_clock                      = clock;
assign riscv_data_memory_reset_n                    = reset_n;
assign riscv_data_memory_read_address               = riscv_memory_reader_read_address;
assign riscv_data_memory_write_data                 = riscv_memory_writer_write_data;
assign riscv_data_memory_write_enable               = |riscv_memory_writer_write_byte_select;
assign riscv_data_memory_write_byte_select          = riscv_memory_writer_write_byte_select;
assign riscv_data_memory_write_address              = riscv_memory_writer_write_address;
assign riscv_data_memory_write_protect              = '0;

assign riscv_memory_writer_alu_result               = riscv_alu_result;
assign riscv_memory_writer_funct3                   = riscv_instruction_decoder_funct3;
assign riscv_memory_writer_read_data                = riscv_register_file_read_data_two;
assign riscv_memory_writer_instruction_type         = riscv_instruction_decoder_instruction_type;

assign riscv_memory_reader_alu_result               = riscv_alu_result;
assign riscv_memory_reader_data                     = riscv_data_memory_read_data;
assign riscv_memory_reader_funct3                   = riscv_instruction_decoder_funct3;
assign riscv_memory_reader_instruction_type         = riscv_instruction_decoder_instruction_type;

assign riscv_write_back_controller_opcode           = riscv_instruction_decoder_opcode;
assign riscv_write_back_controller_memory_read_data = riscv_memory_reader_read_data;
assign riscv_write_back_controller_alu_result       = riscv_alu_result;
assign riscv_write_back_controller_program_counter  = riscv_program_counter_result;
assign riscv_write_back_controller_immediate        = riscv_instruction_decoder_imm;


endmodule