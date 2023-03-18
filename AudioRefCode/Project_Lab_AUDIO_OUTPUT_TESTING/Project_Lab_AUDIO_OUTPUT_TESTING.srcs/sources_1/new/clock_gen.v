`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2023 08:06:55 PM
// Design Name: 
// Module Name: clock_gen
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


module clock_gen(
    input clock_1ns,
    input [31:0] freq,
    output reg clk
    );
    
    reg [31:0] count = 0;
    reg [31:0] m;
        
    always @ (posedge clock_1ns) begin
    m = 100000000/(2*freq) - 1;
    count <= (count == m) ? 0 : count + 1; 
    clk <= (count == 0) ? ~clk : clk;
    end
    
endmodule
