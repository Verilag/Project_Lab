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


module audio_cal (
    input enable,
    input clock_1ns, 
    input [15:0] sw, 
    input [11:0] data_stream,
    
    output reg [15:0] led,
    output [15:0] seg_wire_freq,
    output [11:0] audio_out
    );
    
    wire clk50M;
    
    clock_gen_hz clk50Mhz (
           .clk_100Mhz (clock_1ns),
           .freq (50000000),
           .clk (clk50M)
    );
    
    // ALL ENABLES GO HERE ///
    reg message_gen_enable = 0; // sw[15]
    reg audio_gen_enable = 0;
    reg audio_receive_enable = 0; // controlled by sw[14]

    /// END OF ENABLE ////
    
    // Anode and  segment display wiring
    wire [7:0] wire_led; // encoded message
    wire [6:0] seg_wire;
                
    wire [11:0] freq_high_transmit;
    wire [11:0] freq_high_detect;
    wire [11:0] freq_start_transmit;
    wire [11:0] freq_start_detect;
    
    assign freq_high_transmit = 550; // sw[3:0] * 50;
    assign freq_high_detect = 450;// sw[10:7] * 50;
    assign freq_start_transmit = 700; // sw[3:0] * 50;
    assign freq_start_detect = 550;// sw[10:7] * 50;
    
    // end of anode and segment display code
    
    /// FIXED PARAMETERS ////
//    parameter freq_high_transmit = 12'd1000;
//    parameter freq_high_detect = 12'd300;
//    parameter freq_start_transmit = 12'd1000;
//    parameter freq_start_detect = 12'd500;
    wire [31:0]transmission_period_ms, transmission_hex_period_ms, decimation, transmission_count;
    assign transmission_period_ms = (sw[0] ? 20 : 50 ); 
    //parameter transmission_period_ms = 32'd20; // MUST BE A FACTOR OF 1000
    assign transmission_hex_period_ms = (transmission_period_ms * 5);
    
    assign decimation = (1000 / transmission_period_ms);
    parameter sampling_freq = 32'd20_000;
    assign transmission_count = (sampling_freq / decimation);
    
    // END OF FIXED PARAMETERS ///
    //wire [3:0] messageToSend;
    //assign messageToSend = sw;
    reg [3:0] messageToSend;
    
    // AUDIO INPUT RELATED WIRES //
    wire [11:0] input_sample; // peak input for every MAX samples
    wire [11:0] freq_wire; // frequency estimate for over samp_time. See audio listener for parameters
    //wire [11:0] signal_threshold; // signal_threshold choice
    
    wire [3:0] message_wire; // 4-bit message
    wire [3:0] message_state; // 0 to 8, message states
    wire message_received_flag;
    // END OF AUDIO INPUT RELATED WIRES //
    
    // STATE OUR LED assignments !!
    // led[0] - message has been received flag
    // led[8:1] - message? wtf
    // led[11:9] - used for debugging to display message state
    // led[15:12] transmitted message

    // WTF IS THIS
    parameter arraySize = 16;
    reg [3:0] messageArray [31:0];
    reg [3:0] arrayStage = 0;
    
    initial begin
        messageArray[0] = 4'b0000;
        messageArray[1] = 4'b0001;
        messageArray[2] = 4'b0010;
        messageArray[3] = 4'b0011;
        messageArray[4] = 4'b0100;
        messageArray[5] = 4'b0101;
        messageArray[6] = 4'b0110;
        messageArray[7] = 4'b0111;
        messageArray[8] = 4'b1000;
        messageArray[9] = 4'b1001;
        messageArray[10] = 4'b1010;
        messageArray[11] = 4'b1011;
        messageArray[12] = 4'b1100;
        messageArray[13] = 4'b1101;
        messageArray[14] = 4'b1110;
        messageArray[15] = 4'b1111;
    end

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
            led[8:1] <= wire_led; //encoded message
            led[11:9] <= message_state[2:0]; //message state
            led[15:12] <= message_wire; // decoded message
            
            message_gen_enable <= sw[15];
            audio_receive_enable <= sw[14];
        end
    end 
      
    reg [1:0] display_state = 2'b00;
    reg [3:0] send_to_seg;
    
//    always @(posedge clk360hz_signal) begin
//        if (enable) begin
//            case(display_state)
//            0: begin
//                an <= 4'b1110;
//                send_to_seg <= seg_wire_freq[3:0];
//                display_state <= 1;
//            end
//            1: begin
//                an <= 4'b1101;
//                send_to_seg <= seg_wire_freq[7:4];
//                display_state <= 2;
//            end
//            2: begin
//                an <= 4'b1011;
//                send_to_seg <= seg_wire_freq[11:8];
//                display_state <= 3;
//            end
//            3: begin
//                an <= 4'b0111;
//                send_to_seg <= seg_wire_freq[15:12];
//                display_state <= 0;
//            end
//            endcase
//        end
//    end
    
//    bin_to_seg( //segment code
//        .seg(seg_wire),
//        .bin(send_to_seg),
//        .clock(clk360hz_signal)
//        );
   
   /// end of random assignment code
   
   /// AUDIO INPUT GENERATION //////
   audio_listener listen(
       .enable(audio_receive_enable),
       .data_stream(data_stream),
       .base_clock(clock_1ns), 
       .sampling_clock(clk20khz_signal), 
       .decimation(decimation),
       .transmission_count(transmission_count),
       .detected_freq(freq_wire),
       .seg_wire_freq(seg_wire_freq)
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
    
    // END OF DECODING //
   
   
   /// AUDIO INPUT GENERATION ENDS HERE ////

    ///// AUDIO OUTPUT GENERATION ////
    audio_code_generator audio_msg_gen(
        .clk_100M(clock_1ns),
        .message(messageToSend),
        .clk_transmission(clk_transmission),
        .enable(audio_gen_enable),
        .freq_start_transmit(freq_start_transmit),
        .freq_high_transmit(freq_high_transmit),
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
