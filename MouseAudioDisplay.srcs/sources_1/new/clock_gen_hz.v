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

// Creates clock signal with given frequency 
// Must use 100Mhz base clock signal!
// Minimum: 1Hz | Maximum: 100Mhz
module clock_gen_hz(
    input clk_100Mhz,
    input [31:0] freq,
    output reg clk = 0
);
    
    reg [31:0] count = 0; 
    wire [31:0] m = (100_000_000 / (2*freq)) - 1;
    
    always @ (posedge clk_100Mhz) begin
        count <= (count >= m) ? 0 : count + 1; 
        clk <= (count == 0) ? ~clk : clk;
    end
    
endmodule
