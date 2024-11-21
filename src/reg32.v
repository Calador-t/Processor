module reg32(
	input [31:0] in_data, 
	input clk, 
	input enable, 
	input reset, 
	output reg [31:0] out_data
);
	
	always @(posedge clk or posedge reset) begin
		if (reset)
			out_data <= 32'b0;
		else if (enable)
			out_data <= in_data;
	end

endmodule
