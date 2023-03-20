`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2023 11:32:16
// Design Name: 
// Module Name: clk_divider
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
//////////////////////////////////////////////////////////////////////////////////

module clk_divider(
    input clock,
    output reg slow_clock = 0,
    input [31:0] m
    );
    
    reg [31:0] COUNT = 31'd0;
        
    always @(posedge clock)
        begin
        //Cutoff Value "m" = (x/2) - 1, where x nanoseconds happen
        COUNT <= (COUNT == m) ? 0 : COUNT + 1;
        slow_clock <= (COUNT == 0) ? ~slow_clock : slow_clock;
        end
endmodule
