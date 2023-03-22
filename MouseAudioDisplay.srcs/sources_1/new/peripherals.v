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
    input clk_100M, J_MIC_Pin3,
    output cs, sdin, sclk, d_cn, resn, vccen, pmoden,
    output [3:0] JXADC,
    output J_MIC_Pin1, J_MIC_Pin4,
    inout PS2Clk, PS2Data,
    
    input [15:0] colour_chooser, output [12:0] pixel_index, // OLED display variables
    output [11:0] mouse_x, mouse_y, output mouse_l, mouse_m, mouse_r, // Mouse variables
    output [11:0] audio_in, input [11:0] audio_out // Audio in & out variables
);
    
    wire clk6p25M_signal, frame_begin, sending_pixels, sample_pixel;
    clock_gen_hz clk6p25M(.clk_100M(clk_100M), .freq(6_250_000), .clk(clk6p25M_signal));
    Oled_Display oled_one(.clk(clk6p25M_signal), .reset(0), .frame_begin(frame_begin), .sending_pixels(sending_pixels), 
        .sample_pixel(sample_pixel), .pixel_index(pixel_index), .pixel_data(colour_chooser), 
        .cs(cs), .sdin(sdin), .sclk(sclk), .d_cn(d_cn), .resn(resn), .vccen(vccen), .pmoden(pmoden));
        
    wire [3:0] mouse_z; wire mouse_new_e;
    MouseCtl mouse(.clk(clk_100M), .rst(0), .value(0), .setx(0), .sety(0), .setmax_x(0), .setmax_y(0),
        .xpos(mouse_x), .ypos(mouse_y), .zpos(mouse_z),
        .left(mouse_l), .middle(mouse_m), .right(mouse_r), .new_event(mouse_new_e),
        .ps2_clk(PS2Clk), .ps2_data(PS2Data));
    
    wire clk20k_signal; 
    clock_gen_hz clk20k(.clk_100M(clk_100M), .freq (20_000), .clk (clk20k_signal));
    Audio_Input mic(
        .CLK(clk_100M),               // 100MHz clock
        .cs(clk20k_signal),           // sampling clock, 20kHz
        .MISO(J_MIC_Pin3),            // J_MIC3_Pin3, serial mic input
        .clk_samp(J_MIC_Pin1),        // J_MIC3_Pin1
        .sclk(J_MIC_Pin4),            // J_MIC3_Pin4, MIC3 serial clock
        .sample(audio_in)             // 12-bit audio sample data
    );
    
    wire clk50M_signal; 
    clock_gen_hz clk50M(.clk_100M(clk_100M), .freq(50_000_000), .clk(clk50M_signal));
    Audio_Output speaker(
        .CLK(clk50M_signal),
        .START(clk20k_signal),
        .DATA1(audio_out),
        .RST(0),
        .D1(JXADC[1]),
        .D2(JXADC[2]),
        .CLK_OUT(JXADC[3]),
        .nSYNC(JXADC[0])
    );
    
endmodule
