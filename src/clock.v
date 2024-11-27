`timescale 1ns/1ps

// Preclock is for debug and is called imediatly before clock is set
module clock(output reg clk);

	parameter PERIOD = 10;
	initial begin
		clk <= 0;
	end 

	always begin
		// make pre clock happen before clk to print end of cycle and make sure that the registers are filled
		#(PERIOD / 2) 
		clk = ~clk; // invert clk
	end

endmodule
