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
    input clk_100Mhz, J_MIC_Pin3,
    input [15:0] sw, 
    input btnC, btnU, btnL, btnR, btnD,
    output [15:0] led,
    output cs, sdin, sclk, d_cn, resn, vccen, pmoden,
    output [3:0] an, output [6:0] seg, output dp,
    output [3:0] JXADC,
    output J_MIC_Pin1, J_MIC_Pin4,
    inout PS2Clk, PS2Data
); 

    wire [12:0] pixel_index; wire [15:0] colour_chooser;
    wire [11:0] mouse_x, mouse_y; wire mouse_l, mouse_m, mouse_r;
    wire [11:0] audio_in, audio_out;
    
    peripherals hardware(
        .clk_100Mhz(clk_100Mhz), .J_MIC_Pin3(J_MIC_Pin3), .JXADC(JXADC),
        .cs(cs), .sdin(sdin), .sclk(sclk), .d_cn(d_cn), .resn(resn), .vccen(vccen), .pmoden(pmoden),
        .J_MIC_Pin1(J_MIC_Pin1), .J_MIC_Pin4(J_MIC_Pin4),
        .PS2Clk(PS2Clk), .PS2Data(PS2Data),
        
        .colour_chooser(colour_chooser), .pixel_index(pixel_index),
        .mouse_x(mouse_x), .mouse_y(mouse_y), .mouse_l(mouse_l), .mouse_m(mouse_m), .mouse_r(mouse_r), 
        .audio_in(audio_in), .audio_out(audio_out)
    );
    
    wire [15:0] team_basic_color; wire [11:0] team_basic_speaker;
    wire [3:0] team_basic_dp; wire [15:0] team_basic_led; wire [27:0] team_basic_seg;
    team_integration team(
        .clk_100Mhz(clk_100Mhz), .mouse_l(mouse_l), .mouse_r(mouse_r), .sw15(sw[15]),
        .mouse_x(mouse_x), .mouse_y(mouse_y), .audio_in(audio_in), .pixel_index(pixel_index), 
        
        .colour_chooser(team_basic_color), .audio_out(team_basic_speaker),
        .led(team_basic_led), .seg(team_basic_seg), .dp(team_basic_dp)
    );
    
    display_multiplexer oled_display(.state(TEAM_BASIC),
        .menu_color(0), .team_basic_color(team_basic_color),
        .color_chooser(colour_chooser));
    
    audio_out_multiplexer speaker(.state(TEAM_BASIC), .team_basic_out(team_basic_speaker), .audio_out(audio_out));
    
    led_multiplexer leds(.state(TEAM_BASIC), .team_basic_led(team_basic_led), .led(led));
    
    wire clk1khz_signal;
    clock_gen_hz clk1khz(.clk_100Mhz(clk_100Mhz), .freq(1000), .clk(clk1khz_signal));
    seg_multiplexer segment(.clk1khz(clk1khz_signal), .state(TEAM_BASIC),
        .team_basic_seg(team_basic_seg), .team_basic_decimal(team_basic_dp),
        .an(an), .seg(seg), .dp(dp));
    
endmodule

