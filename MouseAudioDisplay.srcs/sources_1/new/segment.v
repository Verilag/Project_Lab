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
    input [3:0] number, // Recognised number
    input [3:0] volume, // Audio input task
    output [27:0] seg
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

    reg [1:0] index = 2'b0;
    reg [6:0] first, second, third, fourth;
    assign seg = { first, second, third, fourth }; 
    
    always @ (number, volume) begin
        fourth = nums[volume];
        third = NONE;
        
        if (number == 10) begin
            first <= NONE;
            second <= NONE;
            
        end else if (number == 9) begin
            first <= ONE;
            second <= ZERO;
            
        end else begin
            first <= ZERO;
            second <= nums[number+1];
        end
    end

endmodule
