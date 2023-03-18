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


module coord_to_segment( // coordinates to segment converter
    input [6:0] x, y,
    output [12:0] within
);

    assign within[0] = (x >= 18 && y >= 6 && x < 22 && y < 10);
    assign within[1] = (x >= 22 && x < 39 && y >= 6 && y < 10);
    assign within[2] = (x >= 39 && y >= 6 && x < 43 && y < 10);
    assign within[3] = (x >= 18 && x < 22 && y >= 10 && y < 27);
    assign within[4] = (x >= 39 && x < 43 && y >= 10 && y < 27);
    assign within[5] = (x >= 18 && y >= 27 && x < 22 && y < 31);
    assign within[6] = (x >= 22 && x < 39 && y >= 27 && y < 31);
    assign within[7] = (x >= 39 && y >= 27 && x < 43 && y < 31);
    assign within[8] = (x >= 18 && x < 22 && y >= 31 && y < 48);
    assign within[9] = (x >= 39 && x < 43 && y >= 31 && y < 48);
    assign within[10] = (x >= 18 && y >= 48 && x < 22 && y < 52);
    assign within[11] = (x >= 22 && x < 39 && y >= 48 && y < 52);
    assign within[12] = (x >= 39 && y >= 48 && x < 43 && y < 52);

endmodule

module number_decoder(
    input [12:0] shown_segments,
    output reg [3:0] number
);
    
    parameter [12:0] zero = 13'b1_1111_1011_1111;
    parameter [12:0] one = 13'b1_0010_1001_0100;
    parameter [12:0] two = 13'b1_1101_1111_0111;
    parameter [12:0] three = 13'b1_1110_1111_0111;
    parameter [12:0] four = 13'b1_0010_1111_1101;
    parameter [12:0] five = 13'b1_1110_1110_1111;
    parameter [12:0] six = 13'b1_1111_1110_1111;
    parameter [12:0] seven = 13'b1_0010_1001_0111;
    parameter [12:0] eight = 13'b1_1111_1111_1111;
    parameter [12:0] nine = 13'b1_1110_1111_1111;
    
    always @ (shown_segments) begin
        case (shown_segments)
            zero: number <= 0;
            one: number <= 1;
            two: number <= 2;
            three: number <= 3;
            four: number <= 4;
            five: number <= 5;
            six: number <= 6;
            seven: number <= 7;
            eight: number <= 8;
            nine: number <= 9;
            default: number <= 10; // Invalid number
        endcase
    end

endmodule