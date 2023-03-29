`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2023 00:33:56
// Design Name: 
// Module Name: convert
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


module coord_to_state( // coordinates to state converter
    input [6:0] x, y,
    output reg [1:0]state
);
    
    parameter ERASER = 2'b00;
    parameter BLUE = 2'b01;
    parameter GREEN = 2'b10;
    parameter RED = 2'b11;
      
    always @(*) begin
        if (x > 66 && x < 78 && y > 5 && y < 29) state <= RED;
        else if (x > 80 && x < 92 && y > 5 && y < 29) state <= BLUE;
        else if (x > 66 && x < 78 && y > 34 && y < 58) state <= GREEN;
        else if (x > 80 && x < 92 && y > 34 && y < 58) state <= ERASER;
    end

endmodule
