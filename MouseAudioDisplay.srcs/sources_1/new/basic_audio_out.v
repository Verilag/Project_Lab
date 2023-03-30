`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2023 20:18:13
// Design Name: 
// Module Name: basic_audio_out
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


module basic_audio_out(
    input clk_100Mhz, btnC, SW15,
    output reg [11:0] audio_out = 0
);

    reg [16:0] debounce_counter = 0;
    reg [32:0] countdown_1s = 0;
    reg btnC_debounced = 0;
    reg btnC_prev = 0;
    reg beep_active = 0;
    reg beep_toggle = 0;
    reg [31:0] beep_frequency = 190;

    wire clk190hz_signal;
    clock_gen clk190hz(.clk_100Mhz(clock_100Mhz), .freq(beep_frequency), .clk(clk190hz_signal));

    always @ (posedge clock_100Mhz) begin
        // Detect single button press
        if (btnC_debounced && !btnC_prev) begin
            beep_active <= 1;
            countdown_1s <= 100_000_000;
        end
        
        btnC_prev <= btnC_debounced;
        
        if (beep_active == 1) begin
            countdown_1s <= countdown_1s - 1;
        end
        
        if (countdown_1s < 1 && beep_active == 1) begin
            beep_active <= 0;
        end
        
        // Frequency control    
        beep_frequency <= SW15 ? 190 : 380;
        
        // Debounce logic
        debounce_counter <= debounce_counter + 1;
         
        if (debounce_counter == 10000) begin
            btnC_debounced <= btnC;
            debounce_counter <= 0;
        end
        
    end

    // Audio output control
    always @ (posedge clk190hz_signal) begin
        if (beep_active) begin
            if (audio_out == 0) begin
                audio_out <= SW15 ? 12'b1111_1111_1111 : 12'b1000_0000_0000;
            end else begin
                audio_out <= 0;
            end
        end else begin
            audio_out <= 0;
        end
    end

endmodule
