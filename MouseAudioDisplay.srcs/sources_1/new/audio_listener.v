`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2023 16:48:26
// Design Name: 
// Module Name: audio_listener
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


module display_on_seg(
    input [11:0] signal_wire,
    output reg [15:0] display_hex,
    input display_clock
    );
    // display on segment display
    
    always @(posedge display_clock) begin
            display_hex[3:0] <= signal_wire % 10;
            display_hex[7:4] <= (signal_wire / 10) % 10;
            display_hex[11:8] <= (signal_wire / 100) % 10;
            display_hex[15:12] <= (signal_wire / 1000);
            
        end // end of display clock
    
endmodule

module update_peak(
    input enable,
    input sampling_clock,
    input [11:0] sample,
    input [31:0] max_sample,
    output reg [11:0] peak
    );
    reg [31:0] count = 0;
    reg [11:0] best = 0;
    
    always @(posedge sampling_clock) begin
        if (enable) begin
            if (count == max_sample) begin
                peak <= best;
                count <= 0;
                best <= 0;
            end // count == transmission_period, update average
            else begin
                count = count + 1;
                best <= (best > sample)? best: sample;
            end // count < max_sample, accumulate
            end // enable
    end//one clock cycle
endmodule

module audio_listener(
    input base_clock, // 1ns clock
    input enable,
    input sampling_clock, // 20khz clock signal. For sampling
    input [11:0] data_stream,
    input [7:0] decimation,
    input [31:0] transmission_count,
    output [11:0] detected_freq,
    output [15:0] seg_wire_freq
    );

    wire [11:0] freq_wire;
    
    // assign peak_output = peak_wire;
    assign detected_freq = freq_wire;
    
    parameter zero = 2048;
    parameter delay = 5; //  sampling_freq / delay = max detectable freq
    
    zero_crossing init_freq_detect(
        .enable(enable),
        .sampling_clock(sampling_clock), // signal with given sampling frequency
        .decimation_factor(decimation), // need to multiply this to the counter to get the true frequency
        .sampling_time(transmission_count), // amount of samples collected
        
        .zero_threshold(zero), //fixed parameter for counting zeros. Typically 2048
        .debounce_delay(delay), // parameter to produce debouncing. 
        // Not too large compared to sampling frequency AND operating signal frequency 
        .data_stream(data_stream), // 12-bit audio data-stream
        .detected_freq(freq_wire) // counter for the frequency
    );
        
    /// This part of the code is only used 
    // for displaying frequency signal on the segment display
        
     display_on_seg init_display(
       .signal_wire(freq_wire),
       .display_hex(seg_wire_freq),
       .display_clock(sampling_clock)
       );
    
    // END OF FREQUENCY DISPLAY //
    
endmodule