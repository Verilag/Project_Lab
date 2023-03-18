`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2023 00:25:28
// Design Name: 
// Module Name: clock_divider
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


module clock_divider(
        input clk, 
        input [31:0] prescaler,
        output reg clk_output = 0
    );
    
    reg [31:0] COUNT = 32'd0;
    always @ (posedge clk) begin
        COUNT <= COUNT == prescaler ? 32'd0 : COUNT + 1;
        clk_output <= (COUNT == 0) ? ~clk_output : clk_output;
    end
    
endmodule
