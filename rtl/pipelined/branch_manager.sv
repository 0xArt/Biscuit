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
module branch_manager(
    input   wire            enable,
    input   wire            branch_taken,
    input   wire            branch_result,

    output  logic           flush,
    output  logic           prediction_correct,
    output  logic           valid
);


always_comb begin
    valid               = '0;
    prediction_correct  = '0;
    flush               = '0;

    if (enable) begin
        if (branch_taken == branch_result) begin
            prediction_correct = '1;
        end
        else begin
            prediction_correct  = '0;
            flush               = '1;
        end

        valid = '1;
    end
end


endmodule   