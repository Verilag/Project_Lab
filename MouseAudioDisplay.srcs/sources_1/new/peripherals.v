`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2023 00:37:58
// Design Name: 
// Module Name: peripherals
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


module peripherals(
    input clk_100Mhz, J_MIC_Pin3,
    output cs, sdin, sclk, d_cn, resn, vccen, pmoden,
    output [3:0] JXADC,
    output J_MIC_Pin1, J_MIC_Pin4,
    inout PS2Clk, PS2Data,
    
    input [15:0] colour_chooser, output [12:0] pixel_index, // OLED display variables
    output [6:0] mouse_x, mouse_y, output mouse_l, mouse_m, mouse_r, // Mouse variables
    output [11:0] audio_in, input [11:0] audio_out // Audio in & out variables
);
    
    wire clk6p25Mhz_signal, frame_begin, sending_pixels, sample_pixel;
    clock_gen_hz clk6p25M(.clk_100Mhz(clk_100Mhz), .freq(6_250_000), .clk(clk6p25Mhz_signal));
    Oled_Display oled_one(.clk(clk6p25Mhz_signal), .reset(0), .frame_begin(frame_begin), .sending_pixels(sending_pixels), 
        .sample_pixel(sample_pixel), .pixel_index(pixel_index), .pixel_data(colour_chooser), 
        .cs(cs), .sdin(sdin), .sclk(sclk), .d_cn(d_cn), .resn(resn), .vccen(vccen), .pmoden(pmoden));
        
    wire [3:0] mouse_z; wire mouse_new_e;
    wire [11:0] raw_mouse_x, raw_mouse_y;
    MouseCtl mouse(.clk(clk_100Mhz), .rst(0), .value(0), .setx(0), .sety(0), .setmax_x(0), .setmax_y(0),
        .xpos(raw_mouse_x), .ypos(raw_mouse_y), .zpos(mouse_z),
        .left(mouse_l), .middle(mouse_m), .right(mouse_r), .new_event(mouse_new_e),
        .ps2_clk(PS2Clk), .ps2_data(PS2Data));
        
    limit_mouse_coor limit(.x(raw_mouse_x), .y(raw_mouse_y), .limit_x(mouse_x), .limit_y(mouse_y));
    
    wire clk20khz_signal, clk50Mhz_signal; 
    clock_gen_hz clk20k(.clk_100Mhz(clk_100Mhz), .freq (20_000), .clk (clk20khz_signal));
    clock_gen_hz clk50M(.clk_100Mhz(clk_100Mhz), .freq(50_000_000), .clk(clk50Mhz_signal));
    
    Audio_Input mic(
        .CLK(clk_100Mhz),               // 100MHz clock
        .cs(clk20khz_signal),           // sampling clock, 20kHz
        .MISO(J_MIC_Pin3),            // J_MIC3_Pin3, serial mic input
        .clk_samp(J_MIC_Pin1),        // J_MIC3_Pin1
        .sclk(J_MIC_Pin4),            // J_MIC3_Pin4, MIC3 serial clock
        .sample(audio_in)             // 12-bit audio sample data
    );
    
    Audio_Output speaker(
        .CLK(clk50Mhz_signal),
        .START(clk20khz_signal),
        .DATA1(audio_out),
        .RST(0),
        .D1(JXADC[1]),
        .D2(JXADC[2]),
        .CLK_OUT(JXADC[3]),
        .nSYNC(JXADC[0])
    );
    
endmodule

// Limit mouse coordinates to screen dimensions (64 x 96 pixels)
module limit_mouse_coor(
    input [11:0] x, y,
    output reg [6:0] limit_x, limit_y
);
    parameter screen_height = 7'd62;
    parameter screen_width = 7'd94;
    
    always @ (x,y) begin
        if (x >= screen_width-1) limit_x = screen_width-1;
        else limit_x = x;
        
        if (y >= screen_height-1) limit_y = screen_height-1;
        else limit_y = y;
    end
    
endmodule
