`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2023 00:32:01
// Design Name: 
// Module Name: display
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

module display_pixels(
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
