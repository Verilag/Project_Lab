//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 30.03.2023 02:09:54
//// Design Name: 
//// Module Name: numpad_audio
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////


//module numpad_audio(
//    input clk1Mhz, speed_toggler, send, // SW15!
//    input [15:0] message, 
//    output [15:0] led,
//    output [11:0] audio_out
//);  

//    wire [3:0] full_message [3:0];
//    assign full_message[0] = message[15:12];
//    assign full_message[1] = message[11:8];
//    assign full_message[2] = message[7:4];
//    assign full_message[3] = message[3:0];

//    reg message_gen_enable = 0;
//    reg audio_gen_enable = 0;
    
//    parameter freq_high_transmit = 550;
//    parameter freq_start_transmit = 700;
    
//    wire [31:0] transmission_period_ms, transmission_hex_period_ms, decimation, transmission_count;
//    assign transmission_period_ms = (speed_toggler ? 20 : 50);
//    assign transmission_hex_period_ms = (transmission_period_ms * 5);
    
//    reg [3:0] messageToSend;
//    reg [31:0] arrayStage = 0;
    
//    wire clk_transmission, clk_hex_transmission, clk20khz_signal;
//    clock_gen_hz clk20khz (.clk_100Mhz(clk1Mhz), .freq(20_000), .clk(clk20khz_signal));
//    clock_gen_ms clkTrans(.clk_100Mhz(clk1Mhz), .ms(transmission_period_ms), .clk(clk_transmission));
//    clock_gen_ms clkHexTrans(.clk_100Mhz(clk1Mhz), .ms(transmission_hex_period_ms), .clk(clk_hex_transmission));
    
//    wire [7:0] wire_led;
//    always @(posedge clk20khz_signal) begin
//        if (enable) begin
//            led[8:1] <= wire_led; //encoded message
//            message_gen_enable <= send_message;
//        end
//    end 
    
//    audio_code_generator audio_gen(
//       .clk_100M(clk1Mhz),
//       .message(messageToSend),
//       .clk_transmission(clk_transmission),
//       .enable(audio_gen_enable),
//       .freq_start_transmit(freq_start_transmit),
//       .freq_high_transmit(freq_high_transmit),
//       .audio_out(audio_out),
//       .led(wire_led)
//    );
    
//    reg counter = 0;
//    always @(posedge clk_hex_transmission) begin
//        if (enable) begin
//            counter = ~counter;
//            if (counter == 1) begin
//                if (arrayStage) begin
//                    audio_gen_enable <= 1;
//                    if (colour_toggler == 1) messageToSend <= full_message[arrayStage];
//                    else messageToSend <= messageArray[arrayStage];
//                    if (arrayStage < (arraySize - 1)) begin
//                        arrayStage <= arrayStage + 1;
//                    end 
//                    else begin
//                        arrayStage <= 0;
//                    end 
//                end else if (message_gen_enable) begin
//                    audio_gen_enable <= 1;
//                    if (colour_toggler == 1) messageToSend <= full_message[arrayStage];
//                    else messageToSend <= messageArray[arrayStage];
//                    arrayStage <= 1;
//                end else begin
//                    messageToSend <= 0;
//                    audio_gen_enable <= 0;
//                end
//            end else audio_gen_enable <= 0;
//        end
//    end

//endmodule
