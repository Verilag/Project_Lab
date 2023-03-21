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
    input clk_100mhz, J_MIC_Pin3,
    input [15:0] sw, 
    output [15:0] led,
    output cs, sdin, sclk, d_cn, resn, vccen, pmoden,
    output [3:0] an, output [6:0] seg, output dp,
    output [3:0] JXADC,
    output J_MIC_Pin1, J_MIC_Pin4,
    inout PS2Clk, PS2Data
); 

    wire clk6p25m; parameter prescaler_6p25m = 32'd7;
    wire frame_begin, sending_pixels, sample_pixel;
    wire [12:0] pixel_index;
    wire [15:0] colour_chooser;
    
    clock_divider clk_divider6p25m(.clk(clk_100mhz), .prescaler(prescaler_6p25m), .clk_output(clk6p25m));
    Oled_Display oled_one(.clk(clk6p25m), .reset(0), .frame_begin(frame_begin), .sending_pixels(sending_pixels), .sample_pixel(sample_pixel), 
        .pixel_index(pixel_index), .pixel_data(colour_chooser), .cs(cs), .sdin(sdin), .sclk(sclk), .d_cn(d_cn), .resn(resn), .vccen(vccen),
        .pmoden(pmoden));
        
    wire [11:0] mouse_x, mouse_y;
    wire [3:0] mouse_z;
    wire mouse_l, mouse_m, mouse_r, mouse_new_e;
    
    MouseCtl mouse(.clk(clk_100mhz), .rst(0), .value(0), .setx(0), .sety(0), .setmax_x(0), .setmax_y(0),
        .xpos(mouse_x), .ypos(mouse_y), .zpos(mouse_z),
        .left(mouse_l), .middle(mouse_m), .right(mouse_r), .new_event(mouse_new_e),
        .ps2_clk(PS2Clk), .ps2_data(PS2Data));
    
    
    wire clk20k_signal; wire [11:0] MIC_in;
    clock_gen_hz clk20kHz(.clock_10ns(clk_100mhz), .freq (20_000), .clk (clk20k_signal));
    Audio_Input unit_my_audio(
        .CLK(clk_100mhz),             // 100MHz clock
        .cs(clk20k_signal),           // sampling clock, 20kHz
        .MISO(J_MIC_Pin3),            // J_MIC3_Pin3, serial mic input
        .clk_samp(J_MIC_Pin1),        // J_MIC3_Pin1
        .sclk(J_MIC_Pin4),            // J_MIC3_Pin4, MIC3 serial clock
        .sample(MIC_in)               // 12-bit audio sample data
    );
    
    wire clk50M_signal;
    wire [11:0] audio_out;
    clock_gen_hz clk50MHz(.clock_10ns(clk_100mhz), .freq (50_000_000), .clk (clk50M_signal));
    Audio_Output audio_out_inst (
        .CLK(clk50M_signal),
        .START(clk20k_signal),
        .DATA1(audio_out),
        .RST (0),
        .D1(JXADC[1]),
        .D2(JXADC[2]),
        .CLK_OUT(JXADC[3]),
        .nSYNC(JXADC[0])
    );
     
    team_integration team(.clk_100mhz(clk_100mhz), .mouse_l(mouse_l), .mouse_r(mouse_r), .sw15(sw[15]),
        .mouse_x(mouse_x), .mouse_y(mouse_y), .pixel_index(pixel_index), .led(led),
        .colour_chooser(colour_chooser), .an(an), .seg(seg), .dp(dp), .audio_out(audio_out), .audio_in(MIC_in));
    
endmodule

