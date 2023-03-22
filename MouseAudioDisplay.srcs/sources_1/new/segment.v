`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2023 00:27:04
// Design Name: 
// Module Name: segment
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


module display_segment(
    input clk10khz,
    input [3:0] number, // Recognised number
    input [3:0] volume, // Audio input task
    output [3:0] an, output [6:0] seg, output dp
);  

    parameter NONE = 7'b1111111;
    parameter ZERO = 7'b1000000;
    parameter ONE = 7'b1111001;
    parameter TWO = 7'b0100100;
    parameter THREE = 7'b0110000;
    parameter FOUR = 7'b0011001;
    parameter FIVE = 7'b0010010;
    parameter SIX = 7'b0000010;
    parameter SEVEN = 7'b1111000;
    parameter EIGHT = 7'b0000000;
    parameter NINE = 7'b0010000;

    wire [6:0] nums [9:0]; // 10 numbers of 7 bits
    assign nums[0] = ZERO; assign nums[1] = ONE; assign nums[2] = TWO;
    assign nums[3] = THREE; assign nums[4] = FOUR; assign nums[5] = FIVE;
    assign nums[6] = SIX; assign nums[7] = SEVEN; assign nums[8] = EIGHT;
    assign nums[9] = NINE;

    reg [6:0] display [3:0]; 
    reg [1:0] index = 2'b0;
    
    assign an = ~(1'b1 << index);
    assign seg = display[index];
    assign dp = ~(number != 10 && index == 3);

    always @ (number, volume) begin
        display[0] <= nums[volume];
        display[1] <= NONE;
        
        if (number == 10) begin
            display[3] <= NONE;
            display[2] <= NONE;
            
        end else if (number == 9) begin
            display[3] <= ONE;
            display[2] <= ZERO;
            
        end else begin
            display[3] <= ZERO;
            display[2] <= nums[number+1];
        end
    end

    always @ (posedge clk10khz) begin
        index <= index + 1;
    end

endmodule
