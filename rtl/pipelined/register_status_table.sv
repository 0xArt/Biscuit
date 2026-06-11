`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 01/03/2026
// Design Name: 
// Module Name: register_status_table
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
module register_status_table(
    input   wire            clock,
    input   wire            reset_n,
    input   wire    [4:0]   retire_register,
    input   wire            retire_enable,
    input   wire    [4:0]   busy_register,
    input   wire            busy_enable,
    input   wire            flush,

    output  logic   [31:0]  status
);


logic [31:0]    _status;

always_comb begin
    _status = status;

    if (retire_enable) begin
        _status[retire_register]    = 1'b0;
    end

    if (busy_enable) begin
        _status[busy_register]  = 1'b1;
    end
    
    if (flush) begin
        _status = '0;
    end
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        status  <= '0;
    end
    else begin
        status  <= _status;
    end
end


endmodule