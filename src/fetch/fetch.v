`include "fetch/programcounter.v"
`include "fetch/instruction_cache.v"

assign reset_pc = reset;
// if 
assign f_enable = ~(d_wait || a_wait || t_wait || c_wait);

assign enable_inc = ~(f_wait || d_wait || a_wait || t_wait || c_wait);


reg [31:0] memory [0:1023];

wire f_enable = 1;


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

reg hit = 0;

initial begin 
	// Load instructions into memory here or use an external file.
	$readmemb("memory/memory.bin", __mem_data);
	print_memory();
end

always @(posedge clk or posedge reset) begin
	#0.1
    if (reset) begin
		$display("reset");
        f_wait <= 0;
        imem_read <= 0;
        f_instr_in <= 32'bx; // Clear instruction register
		f_nop_in = 1;
    end else if (f_wait_for_cache == 0) begin
		#0.1
		f_wait_for_cache_in = 1;
		f_nop_in = 1;
		#0.1
		if (cache_finished) begin // Look into cache
			#0.01
			iaddr <= pc;
			icache_read <= 1;
		/*end else if (imem_read) begin  // getting from mem currently
			if (imem_finished) begin // finished mem look
				$display("Reading from memory finished");
				icache_write <= 1;
			end else begin // keep looking
				$display("Reading from memory");
				f_nop_in = 1;
			end
		end else begin
			$display("Else branch %d", imem_read);
			f_nop_in = 1;
			f_wait = 1;*/
		end
	end
end

always @(posedge cache_finished or posedge reset) begin
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
		//$display("tail ctr_in %0d, ctr %0d, tail %0d, h %0d", f_tail_ctr_in, f_tail_ctr, f_tail, rob_head);
		/*$display("f_nop_in %0d, tail %0d, full %0d, inst_in %h|%h|%h|%h|%h", f_nop_in, f_tail, f_rob_full, 
			f_instr_in[31:25], // Opcode
			f_instr_in[24:20], // Dst
			f_instr_in[19:15], // Src1
			f_instr_in[14:10], // Src2
			f_instr_in[9:0],	// Rest
		);*/
	end
end