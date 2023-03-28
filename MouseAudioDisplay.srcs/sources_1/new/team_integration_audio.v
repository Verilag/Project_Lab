`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2023 00:32:42
// Design Name: 
// Module Name: audio
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

module find_peak(
    input enable, clk1khz,
    input [11:0] sample,
    input [31:0] max_sample,
    output reg [11:0] peak = 0
);
    reg [31:0] count = 0;
    reg [11:0] best = 2048;
    
    always @(posedge clk1khz) begin
        if (enable) begin
            if (count == max_sample) begin
                peak <= best;
                count <= 0;
                best <= 2048;
            end // count == transmission_period, update average
            else begin
                count = count + 1;
                best <= (best > sample)? best: sample;
            end // count < max_sample, accumulate
        end // enable
    end //one clock cycle
endmodule


module select_volume(
    input [11:0] peak,
    output reg [3:0] volume_state = 0
);

    parameter base = 2048;
    parameter step = 60;
    
    always @ (peak) begin
        if (peak > base + 9*step) volume_state = 9;
        else if (peak > base + 8*step) volume_state = 8;
        else if (peak > base + 7*step) volume_state = 7;
        else if (peak > base + 6*step) volume_state = 6;
        else if (peak > base + 5*step) volume_state = 5;
        else if (peak > base + 4*step) volume_state = 4;
        else if (peak > base + 3*step) volume_state = 3;
        else if (peak > base + 2*step) volume_state = 2;
        else if (peak > base + step) volume_state = 1;
        else volume_state = 0;
    end 
    
endmodule


module audio_input_task(
    input clk_100Mhz,
    input [11:0] audio_in, 
    output [3:0] volume_state
);

    wire clk1khz_signal;
    clock_gen_hz clk1khz(.clk_100Mhz(clk_100Mhz), .freq(1_000), .clk(clk1khz_signal));
    
    reg enable = 1; wire [11:0] peak;
    parameter max_sample = 31'd128;
    find_peak update(
        .enable(enable),
        .clk1khz(clk1khz_signal),
        .sample(audio_in),
        .max_sample(max_sample),
        .peak(peak)
    );
    
    select_volume update_volume_state(
        .peak(peak),
        .volume_state(volume_state)
    );
    
endmodule


module play_audio(
    input clk_100Mhz, // 100MHz clock
    input [3:0] number,
    output reg [11:0] audio_out = 0
);
    
    reg beep = 0;
    reg [3:0] prev_num = 0;
    reg [31:0] counter = 0;
    
    always @ (posedge clk_100Mhz) begin
        if (number != prev_num && number != 10) begin
            counter = 0; // Start counting from 0
            beep = 1; // Valid new number detected
        end
            
        if (beep) counter = counter + 1; // Increment counter
        
        if (counter >= 10_000_000 * (number+1)) begin 
            // End of beep duration
            counter = 0;
            beep = 0;
        end
        
        prev_num = number;
    end
    
    wire clk190hz_signal;
    clock_gen_hz clk190hz(.clk_100Mhz(clk_100Mhz), .freq(190), .clk(clk190hz_signal));
    
    always @ (posedge clk190hz_signal) begin
        if (beep) audio_out <= audio_out == 0
             ? 12'b1000_0000_0000 : 0;
        else audio_out <= 0;
    end

endmodule
