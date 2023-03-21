`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2023 01:44:30 AM
// Design Name: 
// Module Name: clock_gen_hz
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


module clock_gen_hz(
    input clock_10ns,
    input [31:0] freq,
    output reg clk
);
    
    reg [31:0] count = 0, m;
    always @ (posedge clock_10ns) begin
        m = 100_000_000 / (2*freq) - 1;
        count <= (count == m) ? 0 : count + 1; 
        clk <= (count == 0) ? ~clk : clk;
    end
    
endmodule
