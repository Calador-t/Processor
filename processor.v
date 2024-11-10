`include "clock.v"
`include "reg32.v"



module processor_tb;

// Declare the clock signal
wire clk;

// Instantiate the clock generator
clock #(.PERIOD(10)) clk_gen (
	.clk(clk)
);



reg reset = 0;
reg enable = 1;
reg [31:0] in_data = 0;
wire [31:0] data = 0;

// Wires: in_pc, pc, pcEnable
`include "programcounter.v"

initial begin


$dumpfile("computation.vcd");
$dumpvars(0,processor_tb);



#50 $finish;



	
end


endmodule
