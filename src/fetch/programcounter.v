wire reset_pc;

wire enable_pc = 1;
wire enable_inc;
reg [31:0] pc = 'h1000;
reg [31:0] pc_in = 'h1000;
reg pc_jump = 0;
reg was_reseted = 1;
always @(posedge clk or posedge reset) begin
	// $display("PC %d %d %d %d", pc, enable_pc, enable_inc, was_reseted);
	// $display("WAIT F %d D %d A %d C %d", f_wait, d_wait, a_wait, c_wait);
	// $display("ENABLE INC %d ENABLE PC %d", enable_inc, enable_pc);
	if (reset_pc) begin
		pc <= 'h1000; // PROCESSOR BOOT ADDRESS
		was_reseted <= 1;
	end

	else if (enable_pc) begin
		// $display("PC ENABLED");
		if (was_reseted) begin
			// $display("PC RESET");
			was_reseted <= 0;
		end
		else begin
			if (pc_jump) begin
				$display("JUMPING TO %h", pc_in);
				pc <= pc_in;
				// f_nop_in <= 0;
				f_wait <= 0;
				pc_jump <= 0;
			end else if(enable_inc) begin
				// $display("NO JUMP");
				pc <= pc + 4;
			end
		end
	end
end
