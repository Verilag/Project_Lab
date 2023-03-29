`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////


module audio_generator (
    input clk_100M, enable, [11:0]sound_freq, //[11:0]freq_high_transmit, [11:0]freq_start_transmit,
    output reg [11:0] audio_out
    

    // Delete this comment and include Basys3 inputs and outputs here
    );

    // Delete this comment and write your codes and instantiations here
    wire clkSound;
    
    
    // Instantiate the clock_gen module with named port connections
    clock_gen_hz clk_sound (
        .clk_100Mhz (clk_100M),
        .freq (sound_freq*2),
        .clk (clkSound)
    );
    
    always @(posedge clkSound) begin
        if (enable == 1) begin
            if (audio_out == 0) audio_out <= 12'b1111_1111_1111;
            else audio_out <= 0;
        end
        else audio_out <= 0;
    end

endmodule
