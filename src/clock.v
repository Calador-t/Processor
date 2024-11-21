`timescale 1ns/1ps

module clock(output reg clk);

	parameter PERIOD = 10;
	integer cycle = -1;
	initial begin
		clk <= 0;
	end 

	always begin
		if (clk == 0) begin
			cycle <= cycle + 1;
			if (cycle >= 0) // Ignore first step with -1
				$display("Cycle: %d", cycle);
		end
		#(PERIOD / 2) clk = ~clk; // invert clk
	end

endmodule
