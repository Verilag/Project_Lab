`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2023 01:56:17
// Design Name: 
// Module Name: paint
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


module paint(
    input clk_100M, mouse_l, mouse_r, sw15, btnC, btnR, sw0, enable,
    input [11:0] mouse_x, mouse_y,
    input [12:0] pixel_index,
    output [15:0] led, colour_chooser,
    output [11:0] audio_out
);
    
    // Detect mouse click and update colour choice status
    //wire [15:0] colour_choice;
    //click_colour_detector click(.mouse_x(limit_x), .mouse_y(limit_y), .left_click(mouse_l), 
    //    .colour_choice(colour_choice));
    
    wire clockMouse;
    
    clock_gen_hz clock_mouse(
        .clk_100Mhz(clk_100M),
        .freq(10_000_000),
        .clk(clockMouse)
    );
    
    // Show colour palette, outline and mouse cursor 
    display_audio display(
        .enable(enable), .speed_toggler(sw0), .reset(btnC), .send_message(sw15), 
        .mouse_x(mouse_x), .mouse_y(mouse_y), .left_click(mouse_l), .pixel_index(pixel_index), 
        .color_chooser(colour_chooser), .clockMouse(clockMouse), .audio_out(audio_out), 
        .clk_100M(clk_100M), .led(led));

endmodule
