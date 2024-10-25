`timescale 1ns/1ps

module clock(output reg clk);

	parameter PERIOD = 1;
	integer cycle = -1;
	initial begin
		clk <= 0;
		$monitor("Clk: $d", cycle);
		//while (true)
		$display("alal");
	end 

	always begin
		cycle <= cycle + 1;
		$display("Cycle: $d", cycle);
		#(PERIOD / 2) clk = ~clk; // invert clk
	end

endmodule
