`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2023 12:28:07
// Design Name: 
// Module Name: team_integration_display
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

module team_integration_segment(
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


module click_detector(
    input [6:0] mouse_x, mouse_y,
    input left_click, right_click, led15, 
    output reg [12:0] segments = 13'b0_0000_0000_0000
);
    // Get segment that cursor is currently in
    wire [12:0] within;
    coord_to_segment convert(.x(mouse_x), .y(mouse_y), .within(within));
    
    // Update segment filled status only on left/right mouse click
    always @ (posedge left_click, posedge right_click, negedge led15) begin     
        if (left_click) segments <= segments | within; // Set segment
        else if (right_click) segments <= segments & ~within; // Clear segment 
        else segments <= 13'b0_0000_0000_0000; // Reset segments
    end

endmodule


module team_integration_oled(
    input [6:0] mouse_x, mouse_y,
    input [12:0] shown_segments, pixel_index,
    output reg [15:0] color_chooser
);
    
    parameter green_color = 16'b00000_111111_00000;
    parameter outline_color = 16'b11111_111111_11111;
    parameter white_color = 16'b11111_111111_11111;
    parameter background_color = 16'b00000_000000_00000;
    
    wire [6:0] row, col;
    assign col = pixel_index % 96;
    assign row = pixel_index / 96;
    
    wire green_border, outline;
    assign green_border = (col == 57 && row < 58) || (row == 57 && col < 58);
    assign outline = ((row > 5 && row <= 52) && (col == 17 || col == 22 || col == 38 || col == 43 )) || 
        ((col >= 17 && col <= 43) && (row == 5 || row == 10 || row == 26 || row == 31 || row == 47 || row == 52));
    
    // Get the segment that the current pixel index is in
    wire [12:0] index_within; // Get one hot encoding of pixel index in which segment
    coord_to_segment get_seg(.x(col), .y(row), .within(index_within));
    
    wire within_cursor; wire [15:0] cursor_color;
    check_draw_cursor check_cursor(
        .mouse_x(mouse_x), .mouse_y(mouse_y),
        .pixel_index(pixel_index),
        .within_cursor(within_cursor),
        .color_chooser(cursor_color)
    );
    
    always @ (pixel_index) begin
        if (within_cursor) color_chooser <= cursor_color;
        else if (green_border) color_chooser <= green_color;
        else if (outline) color_chooser <= outline_color;
        else if (shown_segments & index_within) color_chooser <= white_color;
        else color_chooser <= background_color;
    end

endmodule
