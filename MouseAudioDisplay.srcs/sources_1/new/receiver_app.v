`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.03.2023 12:17:35
// Design Name: 
// Module Name: receiver_app
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


module receiver_app(
    input enable,
    input clock_1ns, 
    input [15:0] sw, 
    input [11:0] data_stream,
    input [12:0] pixel_index,
    
    output reg [15:0] led,
    output reg [15:0] colour_chooser,
    output reg [15:0] seg_wire_freq
    );
    
    reg audio_receive_enable = 0; // controlled by sw[14]
    
    wire [11:0] freq_high_detect;
    wire [11:0] freq_start_detect;
    
    assign freq_high_detect = 450;// sw[10:7] * 50;
    assign freq_start_detect = 550;// sw[10:7] * 50;
    
    wire [31:0]transmission_period_ms, transmission_hex_period_ms, decimation, transmission_count;
    assign transmission_period_ms = (sw[0] ? 20 : 50 ); 
    assign decimation = (1000 / transmission_period_ms);
    parameter sampling_freq = 32'd20_000;
    assign transmission_count = (sampling_freq / decimation);
    
    // AUDIO INPUT RELATED WIRES //
    wire [11:0] input_sample; // peak input for every MAX samples
    wire [11:0] freq_wire; // frequency estimate for over samp_time. See audio listener for parameters
    //wire [11:0] signal_threshold; // signal_threshold choice
    
    wire [3:0] message_wire; // 4-bit message
    wire [3:0] message_state; // 0 to 8, message states
    wire message_received_flag;
    
    // ALL CLOCKS HERE
    wire clk20khz_signal; // used for all audio input functions
    wire clk360hz_signal; // used for segment display in zero crossing
    wire clk_transmission; // 100ms clock
    wire clk_hex_transmission;

    clock_gen_ms clkTransmission(
        .clk_100Mhz (clock_1ns),
        .ms (transmission_period_ms),
        .clk (clk_transmission)
    );
    
    clock_gen_ms clkHexTransmission(
        .clk_100Mhz (clock_1ns),
        .ms (transmission_hex_period_ms),
        .clk(clk_hex_transmission)
    );
    
    clock_gen_hz clk20khz (
        .clk_100Mhz (clock_1ns),
        .freq (sampling_freq),
        .clk (clk20khz_signal)
    );
    
    clock_gen_hz clk360hz ( //display clock
        .clk_100Mhz (clock_1ns),
        .freq (360),
        .clk (clk360hz_signal)
    );
    /////// CLOCK ENDS HERE //////////
   
  // Random assignment code
    always @(posedge clk20khz_signal) begin
        if (enable) begin
            led[0] <= message_received_flag; // wtf is this
            led[11:9] <= message_state[2:0]; //message state
            led[15:12] <= message_wire; // decoded message
            audio_receive_enable <= sw[14];
        end
    end 
    
    wire [15:0] seg_wire_freq_dummy;
    
    audio_listener listen(
       .enable(audio_receive_enable),
       .data_stream(data_stream),
       .base_clock(clock_1ns), 
       .sampling_clock(clk20khz_signal), 
       .decimation(decimation),
       .transmission_count(transmission_count),
       .detected_freq(freq_wire),
       .seg_wire_freq(seg_wire_freq_dummy)
    );

    // DECODING //
    code_receiver decode(
        .enable(audio_receive_enable),
        .sampling_clock(clk20khz_signal), // sampling frequency
        .transmission_clock(clk_transmission),
        .transmission_time(transmission_count), //transmission_period in milliseconds
        .input_freq(freq_wire),
        .freq_start_detect(freq_start_detect),
        .freq_high_detect(freq_high_detect),
        .message(message_wire),
        .message_ready_flag(message_received_flag),
        .led_message_state(message_state) // debugging code
    );
    
      
    // Message to display/segment
    
    reg [1023:0] pixel_grayscale = 0;
    reg [1:0] pixel_colour [1023:0];
    reg [7:0] counter = 0;
    
    always @(posedge message_received_flag) begin
        if (enable) begin
            // if message received
            if (message_received_flag) begin
                // Multiplexer for display/numpad
                if (sw[15]) begin
                    if (sw[10]) begin
                        // Grayscale image code
                       pixel_grayscale <= (pixel_grayscale << 4) + message_wire;
                       if (counter < 256) begin
                            counter <= counter + 1;
                        end
                        else begin
                            counter <= 0;
                        end
                    end else begin
                        // Colour image code
                    end 
                end else begin
                    // Numpad code
                    seg_wire_freq <= (seg_wire_freq << 4) + message_wire;
                end                
            end
        end
    end
    
    // display module
    parameter ERASER = 16'b11111_111111_11111;
    parameter BLACK = 16'b0;
    parameter background_color = 16'b0;
    
    wire [6:0] row, col;
    assign col = pixel_index % 96;
    assign row = pixel_index / 96;
    wire screen;
    assign screen = (col < 64);
    
    always @(pixel_index) begin
        if (enable) begin
            if (sw[10]) begin
                if (screen) begin
                    case (pixel_grayscale[(32*(row/2)+ col/2)])
                        0: colour_chooser <= ERASER;
                        1: colour_chooser <= BLACK;
                    endcase
                end else colour_chooser <= background_color;
            end
        end
    end
        
endmodule
