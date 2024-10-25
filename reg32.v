
module reg32(input [31:0] inData, input clk, input enable, input reset, output reg [31:0] outData);
	

	always @(posedge clk or posedge reset) begin
		if (reset)
			outData <= 32'b0;
		else if (enable)
			//$display("    Reg Changed: %d", inData);
			outData <= inData;

		$display("    Reg Changed: %d", outData);
	end

endmodule
