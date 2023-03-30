`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2023 15:34:09
// Design Name: 
// Module Name: audio_cal
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


module jukebox (
    input enable,
    input clock_1ns, 
    input [15:0] sw, 
    
    output reg [15:0] led,
    output [11:0] audio_out
    );
    
    // ALL ENABLES GO HERE ///
    reg message_gen_enable = 0; // sw[15]
    reg audio_gen_enable = 0;
    reg audio_receive_enable = 0; // controlled by sw[14]

    /// END OF ENABLE ////
    
    // Anode and  segment display wiring
    wire [7:0] wire_led; // encoded message
    wire [6:0] seg_wire;
                
    wire [11:0] freq_transmit;
    
    assign freq_transmit = sw[3:0] * 100;

    // end of anode and segment display code
    
    /// FIXED PARAMETERS ////
//    parameter freq_high_transmit = 12'd1000;
//    parameter freq_high_detect = 12'd300;
//    parameter freq_start_transmit = 12'd1000;
//    parameter freq_start_detect = 12'd500;
    wire [31:0]transmission_period_ms, transmission_hex_period_ms, decimation, transmission_count;
    assign transmission_period_ms = 20; 
    //parameter transmission_period_ms = 32'd20; // MUST BE A FACTOR OF 1000
    assign transmission_hex_period_ms = (transmission_period_ms * 5);
    
    assign decimation = (1000 / transmission_period_ms);
    parameter sampling_freq = 32'd20_000;
    assign transmission_count = (sampling_freq / decimation);
    
    // END OF FIXED PARAMETERS ///
    //wire [3:0] messageToSend;
    //assign messageToSend = sw;
    reg [3:0] messageToSend;
    
        // WTF IS THIS
    parameter arraySize = 1;
    reg [3:0] messageArray = 4'b0100;
    reg [3:0] arrayStage = 0;

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
            led[8:1] <= wire_led; //encoded message
            
            message_gen_enable <= sw[15];
        end
    end 
      
    ///// AUDIO OUTPUT GENERATION ////
    audio_code_generator audio_msg_gen(
        .clk_100M(clock_1ns),
        .message(messageToSend),
        .clk_transmission(clk_transmission),
        .enable(audio_gen_enable),
        .freq_start_transmit(freq_transmit),
        .freq_high_transmit(freq_transmit),
        .led(wire_led),
        .audio_out(audio_out)
       );
    
   reg counter = 0;
   
    always @(posedge clk_hex_transmission) begin
        if (enable) begin
            counter = ~counter;
            if (counter == 1) begin
                if (arrayStage) begin
                    audio_gen_enable <= 1;
                    messageToSend <= messageArray[arrayStage];
                    if (arrayStage < (arraySize - 1)) begin
                        arrayStage <= arrayStage + 1;
                    end 
                    else begin
                        arrayStage <= 0;
                    end 
                end else if (message_gen_enable) begin
                    audio_gen_enable <= 1;
                    messageToSend <= messageArray[arrayStage];
                    arrayStage <= 1;
                end else begin
                    messageToSend <= 0;
                    audio_gen_enable <= 0;
                end
            end else audio_gen_enable <= 0;
        end
    end
    
endmodule
