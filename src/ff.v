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
		if (reset) begin
			if (START_VAL == 1) begin
				out <= {BITS{1'b1}};
			end else begin
				out <= {BITS{1'b0}};
			end
		end	else if (enable) begin
			out <= in;
		end
	end

endmodule