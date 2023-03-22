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

// Creates clock signal with given period duration
// Must use 100Mhz base clock signal!
// Minimum: 1 ms period
module clock_gen_ms(
    input clk_100M,
    input [31:0] ms,
    output reg clk = 0
);
    
    reg [31:0] count = 0;
    wire [31:0] m = (ms == 1) ? 49_999 : (100_000 * (ms/2)) - 1;
    
    always @ (posedge clk_100M) begin
        count <= (count == m) ? 0 : count + 1; 
        clk <= (count == 0) ? ~clk : clk;
    end
    
endmodule