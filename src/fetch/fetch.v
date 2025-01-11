assign reset_pc = reset;
// if 
assign f_enable = ~(d_wait || a_wait || t_wait || c_wait);

assign enable_inc = ~(f_wait || d_wait || a_wait || t_wait || c_wait);


reg [31:0] memory [0:1023];

wire f_enable = 1;

reg [4:0] f_exception_in = 0; // 1 itlb miss, 2 dtlb miss, ...
wire [4:0] f_exception;
ff #(.BITS(5)) ff_f_exception (
	.in(f_exception_in),
	.clk(clk),
	.enable(f_enable),
	.reset(reset),
	.out(f_exception)
);

reg [31:0] f_instr_in;
wire [31:0] f_instr;
ff f_instr_ff(
	.in(f_instr_in),
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

reg f_rob_full = 0;
wire [4:0] f_tail;
ff #(.BITS(5) ) ff_f_tail (
	.in(f_tail_ctr),
	.clk(clk),
	.enable(f_enable),
	.reset(reset),
	.out(f_tail)
);

wire [4:0] f_tail_ctr;
reg [4:0] f_tail_ctr_in = 0;
ff #(.BITS(5) ) ff_f_tail_ctr (
	.in(f_tail_ctr_in),
	.clk(clk),
	.enable(f_enable),
	.reset(reset),
	.out(f_tail_ctr)
);


reg f_wait_for_cache_in = 0;
wire f_wait_for_cache;
ff #(.BITS(1)) ff_f_wait_for_cache (
	.in(f_wait_for_cache_in),
	.clk(clk),
	.enable(f_enable),
	.reset(reset),
	.out(f_wait_for_cache)
);



reg f_wait = 0;

initial begin 
	print_memory();
end

always @(posedge clk or posedge reset) begin
	f_nop_in <= 0;
	f_exception_in <= 0;
	#0.01
    if (reset) begin
		// $display("reset");
        f_wait <= 0;
		f_wait_for_cache_in <= 0;
        imem_read <= 0;
        f_instr_in <= 32'bx; // Clear instruction register
		f_nop_in = 1;
    end else if (!f_wait) begin // Look into cache
		// $display("Forwarding to tlb");
		#0.01
		itlb_va <= pc;
		itlb_read <= 1;
	end else if (imem_read) begin  // getting from mem currently
		if (imem_finished) begin // finished mem look
			// $display("Reading from memory finished");
            icache_write <= 1;
		end else begin // keep looking
			// $display("Reading from memory");
			f_nop_in = 1;
			f_wait = 1;
			f_wait_for_cache_in <= 1;
		end
	end
end

task new_inst_found();
	begin
		if (~reset) begin
			#0.1
			f_wait_for_cache_in = 0;
			f_instr_in = cache_result;
			if (f_rob_full == 1) begin
				//f_tail_in = 4'bx;
				f_nop_in = 1;
			end else begin
				f_tail_ctr_in = f_tail_ctr + 1;
				if (f_tail_ctr_in >= ROB_NUM_ENTRIES)
					f_tail_ctr_in = 0;
				if (f_tail_ctr_in == rob_head)
					f_rob_full = 1;
			end
		end
	end
endtask