`include "clock.v"
`include "reg32.v"

module processor_tb;

// Declare the clock signal
wire clk;

// Instantiate the clock generator
clock #(.PERIOD(2)) clk_gen (
	.clk(clk)
);



reg reset = 0;
reg enable = 1;
reg [31:0] inData;
wire [31:0] data = 0;

reg32 rt (
	.inData(inData),
	.clk(clk),
	.enable(enable),
	.reset(reset),
	.outData(data)
); 

/*parameter period = 1;
parameter cycle = period / 2.0;

reg clk = 0;
parameter [2:0] cycles_left = 1;
*/

initial begin



$dumpfile("computation.vcd");
$dumpvars(0,processor_tb);
//$monitor(data);
$monitor("   InData: %d", inData);

$display("aa");
#0.1 inData <= 2;

#0.1 inData <= 3;
#0.5 inData <= 4;
#1 inData <= 5;

#1 reset = 1;

$display("bb");
//$monitor("Data: %d", data)
//$monitor("Clk: %d", clk); 
/*
$display("Asa = %d", t);
while (cycles_left < 0) begin

	#1 cycles_left = cycles_left - 1;
	$display("Test");
end


#1 a=1'b0;
#4 b=1'b1;
#5 a=1'b1;
$display("Start");*/
#5 $finish;



	
end


endmodule
