wire reset_pc;

wire enable_pc = 1;
wire enable_inc;
reg [31:0] pc = 0;
reg [31:0] pc_in = 0;
reg pc_jump = 0;
reg was_reseted = 1;
always @(posedge clk or posedge reset) begin
	// $display("PC %d %d %d %d", pc, enable_pc, enable_inc, was_reseted);
	// $display("WAIT F %d D %d A %d C %d", f_wait, d_wait, a_wait, c_wait);
	// $display("ENABLE INC %d ENABLE PC %d", enable_inc, enable_pc);
	if (reset_pc) begin
		pc <= 32'b0;
		was_reseted <= 1;
	end
	else if (enable_pc) begin
		if (was_reseted) begin
			was_reseted <= 0;
		end
		else begin
			if (pc_jump) begin

				pc <= pc_in;
			end else if(enable_inc) begin
				pc <= pc + 1;
			end
		end
	end
end
