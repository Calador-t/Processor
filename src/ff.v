module reg32#(
    parameter BITS = 32  // Default data width is 8 bits
) (
	input [BITS-1:0] in_data, 
	input clk, 
	input enable, 
	input reset, 
	output reg [BITS-1:0] out_data
);
	
	always @(posedge clk or posedge reset) begin
		if (reset)
			out_data <= {BITS{1'b0}};
		else if (enable)
			out_data <= in_data;
	end

endmodule
