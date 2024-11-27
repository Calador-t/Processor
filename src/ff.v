module ff#(
    parameter BITS = 32  // Default data width is 8 bits
) (
	input [BITS-1:0] in, 
	input clk, 
	input enable, 
	input reset, 
	output reg [BITS-1:0] out
);
	
	always @(posedge clk or posedge reset) begin
		if (reset)
			out <= {BITS{1'b0}};
		else if (enable)
			out <= in;
	end

endmodule
