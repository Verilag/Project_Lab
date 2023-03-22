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
    input clk_100M, mouse_l, mouse_r, sw15,
    input [11:0] mouse_x, mouse_y, audio_in,
    input [12:0] pixel_index,
    output [15:0] led, colour_chooser,
    output [3:0] an, output [6:0] seg, output dp,
    output [11:0] audio_out
);
    
    // Limit mouse coordinates to screen dimensions (64 x 96 pixels)
    wire [6:0] limit_x, limit_y;
    limit_mouse_coor limit(.x(mouse_x), .y(mouse_y), .limit_x(limit_x), .limit_y(limit_y));
    
    // Detect mouse click and update segment status
    wire [12:0] shown_segments;
    click_detector click(.mouse_x(limit_x), .mouse_y(limit_y), .left_click(mouse_l), .right_click(mouse_r), 
        .segments(shown_segments), .led15(led[15]));
    
    // Show filled segments, outline and mouse cursor 
    display_pixels display(.mouse_x(limit_x), .mouse_y(limit_y), .shown_segments(shown_segments), 
        .pixel_index(pixel_index), .color_chooser(colour_chooser));

    wire [3:0] number;
    number_decoder decode(.shown_segments(shown_segments), .number(number));
    assign led[15] = sw15 ? number != 10 : 0;
    
    wire [3:0] volume;
    audio_input_task mic(.clk_100M(clk_100M), .audio_in(audio_in), .volume_state(volume));
    assign led[8:0] = (2**volume) - 1;
    
    wire clk10k_signal; 
    clock_gen_hz clk10k(.clk_100M(clk_100M), .freq(10_000), .clk(clk10k_signal));
    display_segment(.clk(clk10k_signal), .number(number), .volume(volume), .an(an), .seg(seg), .dp(dp));
    
    play_audio sound(.clk_100M(clk_100M), .number(number), .audio_out(audio_out));
    assign led[14] = audio_out > 0; 
     
endmodule
