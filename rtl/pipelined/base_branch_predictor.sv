`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 01/13/2026
// Design Name: 
// Module Name: base_branch_predictor
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
module base_branch_predictor#(
    parameter TABLE_DEPTH     = 256
)(
    input   wire            clock,
    input   wire            reset_n,
    input   wire            prediction_enable,
    input   wire            prediction_correct,
    input   wire            branch_taken,
    input   wire    [31:0]  program_counter_prediction,
    input   wire            update_enable,
    input   wire    [31:0]  program_counter_update,

    output  logic           valid,
    output  logic           take_branch
);


logic [$clog2(TABLE_DEPTH)-1:0]         prediction_index;
logic [$clog2(TABLE_DEPTH)-1:0]         update_index;
logic [TABLE_DEPTH-1:0][1:0]            _predictor_table;
logic [TABLE_DEPTH-1:0][1:0]            predictor_table;

always_comb begin
    prediction_index    = program_counter_prediction[$clog2(TABLE_DEPTH)-1:0];
    update_index        = program_counter_update[$clog2(TABLE_DEPTH)-1:0];
    _predictor_table    = predictor_table;
    take_branch         = 1;
    valid               = 0;

    if (update_enable) begin
        if (prediction_correct) begin
            if (branch_taken) begin
                //took branch when it should have
                if (predictor_table[update_index] != 2'b11) begin
                    _predictor_table[update_index] = predictor_table[update_index] + 1'b1;
                end
            end
            else begin
                // did not take branch when it shouldnt have
                if (predictor_table[update_index] != 2'b00) begin
                    _predictor_table[update_index] = predictor_table[update_index] - 1'b1;
                end
            end
        end
        else begin
            if (branch_taken) begin 
                //took branch when it should not have
                if (predictor_table[update_index] != 2'b00) begin
                    _predictor_table[update_index] = predictor_table[update_index] - 1'b1;
                end
            end
            else begin
                //did not take branch when it should have
                if (predictor_table[update_index] != 2'b11) begin
                    _predictor_table[update_index] = predictor_table[update_index] + 1'b1;
                end
            end
        end
    end

    if (prediction_enable) begin
        valid   = '1;

        if (predictor_table[prediction_index] < 2'b10) begin
            take_branch = '0;
        end
    end
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        for (int i = 0; i < TABLE_DEPTH; i = i + 1) begin
            predictor_table[i] <= 2'b10;
        end
    end
    else begin
        predictor_table <= _predictor_table;
    end
end


endmodule   