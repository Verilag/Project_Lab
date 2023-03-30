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

module display_audio(
    input enable,
    input clk_100M,
    input speed_toggler,
    input [6:0] mouse_x, mouse_y,
    input left_click, reset, send_message, colour_toggler,
    input [12:0] pixel_index,
    input clockMouse,
    output reg [15:0] color_chooser,
    output [11:0] audio_out,
    output reg [15:0] led
);
    
    // Display module
    
    reg [1:0]pixel_data[1023:0];
    wire pixel_grayscale[1023:0];
    wire [3:0]messageArray[255:0];
    wire [3:0]messageColourArray[511:0];
    wire [32:0] arraySize;
    
    assign arraySize = (colour_toggler == 1) ? 512 : 256;
    
    integer k;
    initial begin
        for (k=0; k<1024; k=k+1) begin
            pixel_data[k] = 0;
        end
    end

    genvar h;
    generate
        for (h = 0; h < 1024; h = h + 1) begin
            assign pixel_grayscale[h] = (pixel_data[h] == 2'b00) ? 0 : 1; 
        end
    endgenerate
    
    genvar i;
    genvar j;
    generate
        for (i = 255; i >= 0 ; i = i - 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                assign messageArray[i][j] = pixel_grayscale[4*(255-i) + (j)];
            end
        end
    endgenerate

    genvar m;
    genvar n;
    generate
        for (m = 0; m < 512; m = m + 1) begin
            for (n = 0; n < 4; n = n + 1) begin
                assign messageColourArray[511-m][n] = pixel_data[2*m + n/2][n % 2];
            end
        end
    endgenerate
    
    parameter ERASER = 16'b11111_111111_11111;
    parameter BLUE = 16'b00000_000000_11111;
    parameter GREEN = 16'b00000_111111_00000;
    parameter RED = 16'b11111_000000_00000;    
    parameter outline_color = 16'b00000_000000_00000;
    parameter background_color = 16'b11111_111111_11111;
    
    wire [6:0] row, col;
    assign col = pixel_index % 96;
    assign row = pixel_index / 96;
    
    reg [1:0] state_choice = 2'b00;
    wire [1:0] state;
    coord_to_state convert(.x(mouse_x), .y(mouse_y), .state(state));
    
    wire red, blue, green, eraser, outline, screen;
    assign red = (col > 66 && col < 78 && row > 5 && row < 29);
    assign blue =  (col > 80 && col < 92 && row > 5 && row < 29);
    assign green =  (col > 66 && col < 78 && row > 34 && row < 58);
    assign eraser =  (col > 80 && col < 92 && row > 34 && row < 58);
    assign outline = (col > 63);
    assign screen = (col < 64);
    
    wire within_cursor; wire [15:0] cursor_color;
    check_draw_cursor check_cursor(
        .mouse_x(mouse_x), .mouse_y(mouse_y),
        .pixel_index(pixel_index),
        .within_cursor(within_cursor),
        .color_chooser(cursor_color)
    );
    
    // Audio module
    
    reg message_gen_enable = 0;
    reg audio_gen_enable = 0;
    
    parameter freq_high_transmit = 550;
    parameter freq_start_transmit = 700;
    
    wire [31:0]transmission_period_ms, transmission_hex_period_ms, decimation, transmission_count;
    assign transmission_period_ms = (speed_toggler ? 20 : 50 );
    assign transmission_hex_period_ms = (transmission_period_ms * 5);
    
    reg [3:0] messageToSend;
    
    reg [31:0] arrayStage = 0;
    
    wire clk_transmission;
    wire clk_hex_transmission;
    wire clk20khz_signal;
    
    clock_gen_hz clk20khz (
       .clk_100Mhz (clk_100M),
       .freq (20000),
       .clk (clk20khz_signal)
      );
    
    reg counter = 0;

    clock_gen_ms clkTransmission(
        .clk_100Mhz (clk_100M),
        .ms (transmission_period_ms),
        .clk (clk_transmission)
       );

    clock_gen_ms clkHexTransmission(
        .clk_100Mhz (clk_100M),
        .ms (transmission_hex_period_ms),
        .clk(clk_hex_transmission)
       );
     
    wire [7:0]wire_led;
    
    always @(posedge clk20khz_signal) begin
        if (enable) begin
            led[8:1] <= wire_led; //encoded message
            message_gen_enable <= send_message;
        end
    end 
    
    audio_code_generator audio_gen(
       .clk_100M(clk_100M),
       .message(messageToSend),
       .clk_transmission(clk_transmission),
       .enable(audio_gen_enable),
       .freq_start_transmit(freq_start_transmit),
       .freq_high_transmit(freq_high_transmit),
       .audio_out(audio_out),
       .led(wire_led)
      );
    
    // Behaviour
    
    always @ (posedge clockMouse, posedge reset) begin
        if (reset) begin
            for (k=0; k<1024; k=k+1) begin
                pixel_data[k] <= 2'b00;
            end
        end else if (enable && left_click && mouse_x < 64) begin
            pixel_data[(mouse_y/2)*32 + (mouse_x/2)] <= state_choice; // update pixel_data to chosen colour based on clicks
        end
    end
    
    always @ (posedge left_click) begin
        if (enable) begin
            if (left_click && mouse_x > 63) begin
                state_choice <= state; // Set colour
            end
        end
    end
    
    always @ (pixel_index) begin
        if (enable) begin
            if (within_cursor && cursor_color != 16'b1111_11111_1111) color_chooser <= cursor_color;
            else if (red) color_chooser <= RED;
            else if (blue) color_chooser <= BLUE;
            else if (green) color_chooser <= GREEN;
            else if (eraser) color_chooser <= ERASER;
            else if (outline) color_chooser <= outline_color;
            else if (screen) begin
                case (pixel_data[(32*(row/2)+ col/2)])
                    0: color_chooser <= ERASER;
                    1: color_chooser <= BLUE;
                    2: color_chooser <= GREEN;
                    3: color_chooser <= RED;
                endcase
            end else color_chooser <= background_color;
        end
    end
    
    // Audio behaviour
    
    always @(posedge clk_hex_transmission) begin
        if (enable) begin
            counter = ~counter;
            if (counter == 1) begin
                if (arrayStage) begin
                    audio_gen_enable <= 1;
                    if (colour_toggler == 1) messageToSend <= messageColourArray[arrayStage];
                    else messageToSend <= messageArray[arrayStage];
                    if (arrayStage < (arraySize - 1)) begin
                        arrayStage <= arrayStage + 1;
                    end 
                    else begin
                        arrayStage <= 0;
                    end 
                end else if (message_gen_enable) begin
                    audio_gen_enable <= 1;
                    if (colour_toggler == 1) messageToSend <= messageColourArray[arrayStage];
                    else messageToSend <= messageArray[arrayStage];
                    arrayStage <= 1;
                end else begin
                    messageToSend <= 0;
                    audio_gen_enable <= 0;
                end
            end else audio_gen_enable <= 0;
        end
    end
    
    
endmodule
