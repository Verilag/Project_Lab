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

    // Input hardware data
    wire [6:0] mouse_x, mouse_y; 
    wire mouse_l, mouse_m, mouse_r;
    wire [12:0] pixel_index; 
    wire [11:0] audio_in;

    // Output hardware data
    wire [15:0] colour_chooser; // Display 
    wire [11:0] audio_out; // Speaker
    
    peripherals hardware(
        .clk_100Mhz(clk_100Mhz), .J_MIC_Pin3(J_MIC_Pin3), .JXADC(JXADC),
        .cs(cs), .sdin(sdin), .sclk(sclk), .d_cn(d_cn), .resn(resn), .vccen(vccen), .pmoden(pmoden),
        .J_MIC_Pin1(J_MIC_Pin1), .J_MIC_Pin4(J_MIC_Pin4),
        .PS2Clk(PS2Clk), .PS2Data(PS2Data),
        
        .colour_chooser(colour_chooser), .pixel_index(pixel_index),
        .mouse_x(mouse_x), .mouse_y(mouse_y), .mouse_l(mouse_l), .mouse_m(mouse_m), .mouse_r(mouse_r), 
        .audio_in(audio_in), .audio_out(audio_out)
    );
    
    
    wire [3:0] state, hover_menu_item; wire [15:0] menu_color;
    main_menu menu_app(
        .enable(state == MENU),
        .clk_100Mhz(clk_100Mhz), .btnC(btnC), .btnU(btnU), .btnD(btnD),
        .mouse_x(mouse_x), .mouse_y(mouse_y), .pixel_index(pixel_index),
        .hover_menu_item(hover_menu_item), .color_chooser(menu_color)
    );
    
    
    wire clk1Mhz_signal;
    clock_gen_hz clk1Mhz(.clk_100Mhz(clk_100Mhz), .freq(1_000_000), .clk(clk1Mhz_signal));
    menu_fsm(
        .clk1Mhz(clk1Mhz_signal), .back(btnL), .left_click(mouse_l), 
        .hover_entry(hover_menu_item), .state(state)
    );
    

    wire [15:0] basic_audio_in_led, basic_audio_in_nums;
    basic_audio_in(
        .enable(state == BASIC_AUDIO_IN), .clk_100Mhz(clk_100Mhz), .audio_in(audio_in), 
        .basic_audio_in_led(basic_audio_in_led), 
        .basic_audio_in_nums(basic_audio_in_nums)
    );
    
    wire [11:0] basic_audio_out_speaker;
    basic_audio_out(
        .clk_100Mhz(clk_100Mhz), .btnC(btnC), 
        .SW15(sw[15]), .audio_out(basic_audio_out_speaker)
    );
    
    wire [15:0] basic_mouse_color;
    basic_mouse(
        .enable(state == BASIC_MOUSE),
        .mouse_m(mouse_m),
        .mouse_x(mouse_x), .mouse_y(mouse_y),
        .pixel_index(pixel_index),
        .color_chooser(basic_mouse_color)
    );

    
    wire clk25Mhz_signal;
    clock_gen_hz clk25Mhz(.clk_100Mhz(clk_100Mhz), .freq(25_000_000), .clk(clk25Mhz_signal));
    
    wire [15:0] basic_display_color;
    basic_display(
        .enable(state == BASIC_DISPLAY),
        .clk(clk25Mhz_signal),
        .reset_display_button(btnC),
        .sw(sw[10:0]),
        .pixel_index(pixel_index),
        .colour_chooser(basic_display_color)
    );
    
    wire [15:0] paint_color;
    wire [11:0] paint_speaker;
    wire [15:0] paint_led;
    
    paint paint_app(
        .enable(state == PAINT),
        .clk_100M(clk_100Mhz), .mouse_l(mouse_l), .mouse_r(mouse_r), .sw0(sw[0]), .sw15(sw[15]), .btnC(btnC), .btnR(btnR), 
        .mouse_x(mouse_x), .mouse_y(mouse_y),
        .pixel_index(pixel_index),
        .led(paint_led),
        .colour_chooser(paint_color),
        .audio_out(paint_speaker)
    );    
    
    wire [15:0] numpad_color; wire clk1hz_signal;
    wire [3:0] numpad_dp; wire [15:0] numpad_nums;
    clock_gen_hz clk1hz(.clk_100Mhz(clk_100Mhz), .freq(1), .clk(clk1hz_signal));
    numpad np(
        .enable(state == NUMPAD), .mouse_l(mouse_l),
        .clk1Mhz(clk1Mhz_signal), .clk1hz(clk1hz_signal),
        .mouse_x(mouse_x), .mouse_y(mouse_y), .pixel_index(pixel_index),
        
        .color_chooser(numpad_color),
        .numpad_dp(numpad_dp),
        .numpad_nums(numpad_nums)
    );
    
    wire [15:0] team_basic_color; wire [11:0] team_basic_speaker;
    wire [3:0] team_basic_dp; wire [15:0] team_basic_led; wire [15:0] team_basic_nums;
    team_integration team(
        .enable(state == TEAM_BASIC),
        .clk_100Mhz(clk_100Mhz), .mouse_l(mouse_l), .mouse_r(mouse_r), .sw15(sw[15]),
        .mouse_x(mouse_x), .mouse_y(mouse_y), .audio_in(audio_in), .pixel_index(pixel_index), 
        
        .colour_chooser(team_basic_color), .audio_out(team_basic_speaker),
        .led(team_basic_led), .seg_nums(team_basic_nums), .dp(team_basic_dp)
    );

    wire [15:0] audio_cal_led;
    wire [3:0] audio_cal_an;
    wire [6:0] audio_cal_seg;
    wire [11:0] audio_cal_speaker;
    wire [15:0] audio_cal_nums;
    audio_cal audio_cal_app(
        .enable(state == TEAM_AUDIO_CAL),
        .clock_1ns(clk_100Mhz),
        .sw(sw),
        .data_stream(audio_in),
        .led(audio_cal_led),
        .seg_wire_freq(audio_cal_nums),
        .audio_out(audio_cal_speaker)
    );
    
    display_multiplexer oled_display(
        .state(state),
        .menu_color(menu_color), .basic_mouse_color(basic_mouse_color), .team_basic_color(team_basic_color), 
        .basic_display_color(basic_display_color), .numpad_color(numpad_color),
        .paint_color(paint_color),
        .color_chooser(colour_chooser)
    );
    
    audio_out_multiplexer speaker(
        .state(state), 
        .basic_audio_out_speaker(basic_audio_out_speaker),
        .team_basic_out(team_basic_speaker),
        .paint_out(paint_speaker),
        .audio_cal_out(audio_cal_speaker),
        .audio_out(audio_out)
    );
    
    led_multiplexer leds(
        .state(state), 
        .basic_audio_in_led(basic_audio_in_led),
        .team_basic_led(team_basic_led),
        .paint_led(paint_led),
        .audio_cal_led(audio_cal_led),
        .led(led)
    );
    
    wire clk1khz_signal;
    clock_gen_hz clk1khz(.clk_100Mhz(clk_100Mhz), .freq(1000), .clk(clk1khz_signal));
    seg_multiplexer segment(
        .clk1khz(clk1khz_signal), .state(state),
        .basic_audio_in_nums(basic_audio_in_nums),
        .team_basic_nums(team_basic_nums), .team_basic_dp(team_basic_dp), 
        .audio_cal_nums(audio_cal_nums),
        .numpad_nums(numpad_nums), .numpad_dp(numpad_dp),
        .an(an), .seg(seg), .dp(dp)
    );
    
endmodule

