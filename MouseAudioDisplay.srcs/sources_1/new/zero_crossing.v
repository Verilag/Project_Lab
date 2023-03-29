`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2023 04:17:33
// Design Name: 
// Module Name: zero_crossing
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


module zero_crossing(
    input enable,
    input sampling_clock, // signal with given sampling frequency
    input [7:0] decimation_factor, // need to multiply this to the counter to get the true frequency
    input [15:0] sampling_time, // amount of samples collected
    
    input [11:0] zero_threshold, //fixed parameter for counting zeros. Typically 2048
    input [7:0] debounce_delay, // parameter to produce debouncing. 
    // Not too large compared to sampling frequency AND operating signal frequency 
    input [11:0] data_stream, // 12-bit audio data-stream
    output reg [11:0] detected_freq // counter for the frequency
    );
    reg [1:0] transition_state = 2'b00;
    reg [31:0] crossing_counter = 0;
    reg [15:0] sample_count = 0;
    reg [7:0] debounce_count = 0;
    
    always @(posedge sampling_clock) begin
        if (enable) begin
            if (sample_count == sampling_time) begin
                detected_freq  <= crossing_counter * decimation_factor / 2;
                crossing_counter <= 0;
                sample_count <= 0;
            end // sample_count == sampling_time
            else begin
                sample_count <= sample_count + 1;
                case (transition_state)
                2'b00: begin
                    if (data_stream > zero_threshold) begin // enter debounce state
                        transition_state <= 2'b01;
                        debounce_count <= 0;
                    end //conditional on data > zero
                end // state 00
                2'b01: begin
                    if (debounce_count == debounce_delay) begin // successful crossing
                        transition_state <= 2'b11;
                        crossing_counter <= crossing_counter + 1;
                    end // debounce count = debounce delay
                    else if (data_stream > zero_threshold) begin // debounce 
                        debounce_count = debounce_count + 1;
                    end // data > zero
                    else begin // data < zero
                        transition_state <= 2'b00; // return to state 00
                    end // data < zero
                end //state 01
                2'b11: begin // state 11
                    if (data_stream < zero_threshold) begin // enter debounce state
                        transition_state <= 2'b10;
                        debounce_count <= 0;
                    end // condition on data < zero
                end //state 11
                2'b10: begin
                    if (debounce_count == debounce_delay) begin //successful crossing
                        transition_state <= 2'b00;
                        crossing_counter <= crossing_counter + 1;
                    end // debounce count = debounce delay
                    else if (data_stream < zero_threshold) begin // debounce
                        debounce_count = debounce_count + 1;
                    end // data < zero
                    else begin // data > zero
                        transition_state <= 2'b11; // return to state 11
                    end // data > zero
                end //state 10
                endcase
            end // still sampling
        end // enable
    end // posedge sampling_clock
endmodule
