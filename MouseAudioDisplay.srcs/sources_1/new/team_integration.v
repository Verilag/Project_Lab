`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2023 00:37:45
// Design Name: 
// Module Name: team_integration
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


module team_integration(
    input clk, mouse_l, mouse_r, sw15,
    input [11:0] mouse_x, mouse_y,
    input [12:0] pixel_index,
    output led14, led15,
    output [15:0] colour_chooser,
    output [3:0] an, output [6:0] seg, output dp
);
    
    // Limit mouse coordinates to screen dimensions (64 x 96 pixels)
    wire [6:0] limit_x, limit_y;
    limit_mouse_coor limit(.x(mouse_x), .y(mouse_y), .limit_x(limit_x), .limit_y(limit_y));
    
    // Detect mouse click and update segment status
    wire [12:0] shown_segments;
    click_detector click(.mouse_x(limit_x), .mouse_y(limit_y), .left_click(mouse_l), .right_click(mouse_r), 
        .segments(shown_segments), .led15(led15));
    
    // Show filled segments, outline and mouse cursor 
    display_pixels display(.mouse_x(limit_x), .mouse_y(limit_y), .shown_segments(shown_segments), 
        .pixel_index(pixel_index), .color_chooser(colour_chooser));

    wire [3:0] number;
    number_decoder decode(.shown_segments(shown_segments), .number(number));
    assign led15 = sw15 ? number != 10 : 0;
    
    wire clk10k; parameter prescaler_10k = 30'd4_999; // 10kHz
    clock_divider clk_divider10k(.clk(clk), .prescaler(prescaler_10k), .clk_output(clk10k));
    display_segment(.clk(clk10k), .number(number), .volume(0), .an(an), .seg(seg), .dp(dp));
    
    wire beep;
    play_audio sound(.clk(clk10k), .number(number), .beep(beep));
    assign led14 = beep;
     
endmodule
