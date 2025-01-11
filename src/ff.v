module ff#(
    parameter BITS = 32,  // Default data width is 8 bits
			  START_VAL = 0
) (
	input [BITS-1:0] in, 
	input clk, 
	input enable, 
	input reset, 
	output reg [BITS-1:0] out
);
	
	always @(posedge clk or posedge reset) begin
		if (reset)
			if (START_VAL === 1'bx) begin
				out <= {BITS{1'bx}};
			end else begin
				out <= {BITS{1'b0}};
			end
		else if (enable)
			out <= in;
	end

endmodule
