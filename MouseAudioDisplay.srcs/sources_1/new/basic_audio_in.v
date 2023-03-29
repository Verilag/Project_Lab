`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2023 20:18:13
// Design Name: 
// Module Name: basic_audio_in
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


module basic_audio_in(
    input enable, clk_100Mhz,
    input [11:0] audio_in, 
    output [15:0] basic_audio_in_led, basic_audio_in_nums
);

    wire clk1khz_signal;
    clock_gen_hz clk1khz(.clk_100Mhz(clk_100Mhz), .freq(1_000), .clk(clk1khz_signal));
    
    wire [11:0] peak;
    parameter max_sample = 31'd128;
    basic_find_peak update(
        .enable(enable),
        .clk1khz(clk1khz_signal),
        .sample(audio_in),
        .max_sample(max_sample),
        .peak(peak)
    );
    
    wire [3:0] volume_state;
    basic_select_volume update_volume_state(
        .enable(enable),
        .peak(peak),
        .volume_state(volume_state)
    );

    assign basic_audio_in_led[8:0] = (2**volume_state) - 1;
    assign basic_audio_in_nums = 16'b1111_1111_1111_0000 & volume_state;
    
endmodule

module basic_find_peak(
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


module basic_select_volume(
    input enable,
    input [11:0] peak,
    output reg [3:0] volume_state = 0
);

    parameter base = 2048;
    parameter step = 60;
    
    always @ (peak) begin
        if (enable) begin
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
    end 
    
endmodule

