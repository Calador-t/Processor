wire reset_pc;

wire enable_pc = 1;
reg [31:0] pc = 0;
reg was_reseted = 1;
always @(posedge clk or posedge reset) begin
	if (reset_pc) begin
		pc <= 32'b0;
		was_reseted <= 1;
	end
	else if (enable_pc) begin
		if (was_reseted) begin
			was_reseted <= 0;
		end
		else begin
			pc <= pc + 1;
		end
	end
end
