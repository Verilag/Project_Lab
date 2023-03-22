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
    input enable, sampling_clock,
    input [11:0] sample,
    input [31:0] max_sample,
    output reg [11:0] peak
);
    reg [31:0] count = 0;
    reg [11:0] best = 2048;
    
    always @(posedge sampling_clock) begin
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
    input slow_clock,
    input [11:0] data,
    output reg [3:0] volume_state
);

    always @(posedge slow_clock) begin
        if (data < 2064) volume_state <= 0;
        else if (data < 2090) volume_state <= 1;
        else if (data < 2100) volume_state <= 2;
        else if (data < 2112) volume_state <= 3;
        else if (data < 2150) volume_state <= 4;
        else if (data < 2176) volume_state <= 5; 
        else if (data < 2224) volume_state <= 6;
        else if (data < 2304) volume_state <= 7;
        else if (data < 2560) volume_state <= 8;
        else volume_state <= 9;
    end 
    
endmodule

module audio_input_task(
    input clk_100M,
    input [11:0] audio_in, 
    output [3:0] volume_state
);

    wire clk10_signal, clk1k_signal;
    clock_gen_hz clk10(.clk_100M(clk_100M), .freq(10), .clk(clk10_signal));
    clock_gen_hz clk1k(.clk_100M(clk_100M), .freq(1_000), .clk(clk1k_signal));
    
    reg enable = 1; wire [11:0] peak;
    parameter max_sample = 31'd128;
    find_peak update(
        .enable(enable),
        .sampling_clock(clk1k_signal),
        .sample(audio_in),
        .max_sample(max_sample),
        .peak(peak)
    );
    
    select_volume update_volume_state(
        .slow_clock(clk10_signal),
        .data(peak),
        .volume_state(volume_state)
    );
    
endmodule


module play_audio(
    input clk_100M, // 100MHz clock
    input [3:0] number,
    output reg [11:0] audio_out = 0
);
    
    reg beep = 0;
    reg [3:0] prev_num = 0;
    reg [31:0] counter = 0;
    
    always @ (posedge clk_100M) begin
        if (number != prev_num) begin
            counter = 0; // Start counting from 0
            beep = number != 10; // Valid new number detected
        end
            
        if (beep) counter = counter + 1; // Increment counter
        
        if (counter >= 10_000_000 * (number+1)) begin 
            // End of beep duration
            counter = 0;
            beep = 0;
        end
        
        prev_num = number;
    end
    
    wire clk190_signal;
    clock_gen_hz clk190(.clk_100M(clk_100M), .freq(190), .clk(clk190_signal));
    
    always @ (posedge clk190_signal) begin
        if (beep) audio_out <= audio_out == 0
             ? 12'b1000_0000_0000 : 0;
        else audio_out <= 0;
    end

endmodule
