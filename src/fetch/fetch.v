assign reset_pc = reset;
// if 
// assign f_enable = ;

assign enable_inc = ~(f_wait || d_wait || a_wait || c_wait);


reg [31:0] memory [0:1023];

wire f_enable = ~(d_wait || a_wait || c_wait);

reg [4:0] f_exception_in = 0; // 1 itlb miss, 2 dtlb miss, ...
wire [4:0] f_exception;
ff #(.BITS(5)) ff_f_exception (
	.in(f_exception_in),
	.clk(clk),
	.enable(f_enable),
	.reset(reset),
	.out(f_exception)
);

reg [31:0] f_instr_input;
wire [31:0] f_instr;
ff f_instr_ff(
	.in(f_instr_input),
	.clk(clk),
	.enable(f_enable),
	.reset(reset),
	.out(f_instr)
);

wire [31:0] f_pc;
ff #(.BITS(32)) ff_f_pc (
	.in(pc),
	.clk(clk),
	.enable(enable_inc),
	.reset(reset),
	.out(f_pc)
);

reg f_nop_in = 1;
wire f_nop;
ff #(.BITS(1)) ff_f_nop (
	.in(f_nop_in),
	.clk(clk),
	.enable(f_enable),
	.reset(reset),
	.out(f_nop)
);

wire [31:0] f_predict;
reg [31:0] f_predict_in;
ff #(.BITS(32)) ff_f_predict (
	.in(f_predict_in),
	.clk(clk),
	.enable(f_enable),
	.reset(reset),
	.out(f_predict)
);


reg f_wait = 0;

always @(posedge clk or posedge reset) begin
	f_nop_in <= 0;
	f_exception_in <= 0;
	#0.01
	f_predict_in = predict_pc(pc);
	if (~(f_predict_in === 32'bx)) begin
		// validcadress was found
		$display("");
		$display("");
		$display("");
		$display("");
		$display("predict jump: pc %0h to %0h", pc, f_predict_in);
		$display("");
		pc_has_prediction = 1;
		pc_predicted_in = f_predict_in;
	end
    if (reset) begin
		// $display("reset");
        f_wait <= 0;
        imem_read <= 0;
        f_instr_input <= 32'bx; // Clear instruction register
		f_nop_in = 1;

    end else if (!f_wait) begin // Look into cache
		$display("Forwarding to tlb");
		itlb_va <= pc;
		itlb_read <= 1;
		#0.5
		imem_read <= 0;
		imem_finished <= 0;
	end else if (imem_read) begin  // getting from mem currently
		if (imem_finished) begin // finished mem look
			$display("Reading from memory finished");
            icache_write <= 1;
		end else begin // keep looking
			$display("Reading from memory");
			f_nop_in = 1;
			f_wait = 1;
		end
	end else begin
		// $display("Else branch %d", imem_read);
		f_nop_in = 1;
		f_wait = 1;
	end
end
