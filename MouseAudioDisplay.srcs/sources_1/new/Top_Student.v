`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (
    input clk,
    input sw15,
    output led14, led15,
    output [9:0] led,
    output cs, sdin, sclk, d_cn, resn, vccen, pmoden,
    output [3:0] an, output [6:0] seg, output dp,
    inout PS2Clk, PS2Data
); 

    wire clk6p25m; parameter prescaler_6p25m = 32'd7;
    wire frame_begin, sending_pixels, sample_pixel;
    wire [12:0] pixel_index;
    wire [15:0] colour_chooser;
    
    clock_divider clk_divider6p25m(.clk(clk), .prescaler(prescaler_6p25m), .clk_output(clk6p25m));
    Oled_Display oled_one(.clk(clk6p25m), .reset(0), .frame_begin(frame_begin), .sending_pixels(sending_pixels), .sample_pixel(sample_pixel), 
        .pixel_index(pixel_index), .pixel_data(colour_chooser), .cs(cs), .sdin(sdin), .sclk(sclk), .d_cn(d_cn), .resn(resn), .vccen(vccen),
        .pmoden(pmoden));
    
    wire [11:0] mouse_x, mouse_y;
    wire [3:0] mouse_z;
    wire mouse_l, mouse_m, mouse_r, mouse_new_e;
    
    MouseCtl mouse(.clk(clk), .rst(0), .value(0), .setx(0), .sety(0), .setmax_x(0), .setmax_y(0),
        .xpos(mouse_x), .ypos(mouse_y), .zpos(mouse_z),
        .left(mouse_l), .middle(mouse_m), .right(mouse_r), .new_event(mouse_new_e),
        .ps2_clk(PS2Clk), .ps2_data(PS2Data));
    
//    // Limit mouse coordinates to screen dimensions (64 x 96 pixels)
//    wire [6:0] limit_x, limit_y;
//    limit_mouse_coor limit(.x(mouse_x), .y(mouse_y), .limit_x(limit_x), .limit_y(limit_y));
    
//    // Detect mouse click and update segment status
//    wire [12:0] shown_segments;
//    click_detector click(.mouse_x(limit_x), .mouse_y(limit_y), .left_click(mouse_l), .right_click(mouse_r), 
//        .segments(shown_segments), .led15(led15));
    
//    // Show filled segments, outline and mouse cursor 
//    display_pixels display(.mouse_x(limit_x), .mouse_y(limit_y), .shown_segments(shown_segments), 
//        .pixel_index(pixel_index), .color_chooser(colour_chooser));

//     wire [3:0] number;
//     number_decoder decode(.shown_segments(shown_segments), .number(number));
//     assign led15 = sw15 ? number != 10 : 0;

//     wire clk10k; parameter prescaler_10k = 30'd4_999; // 10kHz
//     clock_divider clk_divider10k(.clk(clk), .prescaler(prescaler_10k), .clk_output(clk10k));
//     display_segment(.clk(clk10k), .number(number), .volume(0), .an(an), .seg(seg), .dp(dp));
     
//     wire beep;
//     play_audio sound(.clk(clk10k), .number(number), .beep(beep));
//     assign led14 = beep;
     
     team_integration team(.clk(clk), .mouse_l(mouse_l), .mouse_r(mouse_r), .sw15(sw15),
        .mouse_x(mouse_x), .mouse_y(mouse_x), .pixel_index(pixel_index), .led14(led14), .led15(led15), 
        .colour_chooser(colour_chooser), .an(an), .seg(seg), .dp(dp));
    
endmodule

