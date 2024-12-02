
wire d_enable = 1; // TODO make wire
assign d_enable = ~(a_wait || c_wait); 

wire [31:0] d_pc;
ff #(.BITS(32)) ff_d_pc (
	.in(f_pc),
	.clk(clk),
	.enable(d_enable),
	.reset(reset),
	.out(d_pc)
);

wire [4:0]d_r_d_a;
reg [4:0]d_r_d_a_in;
ff #(.BITS(5) ) ff_d_r_d_a (
	.in(d_r_d_a_in),
	.clk(clk),
	.enable(d_enable),
	.reset(reset),
	.out(d_r_d_a)
);

wire d_w;
reg d_w_in;
ff #(.BITS(1) ) ff_d_w(
	.in(d_w_in),
	.clk(clk),
	.enable(d_enable),
	.reset(reset),
	.out(d_w)
);

wire [0:0] d_is_load;
reg [0:0] d_is_load_in;
ff #(.BITS(1)) ff_d_is_load(
	.in(d_is_load_in),
	.clk(clk),
	.enable(d_enable),
	.reset(reset),
	.out(d_is_load)
);

wire [0:0] d_is_store;
reg [0:0] d_is_store_in;
ff #(.BITS(1)) ff_d_is_store(
	.in(d_is_store_in),
	.clk(clk),
	.enable(d_enable),
	.reset(reset),
	.out(d_is_store)
);

wire [2:0] d_func;
reg [2:0] d_func_in;
ff #(.BITS(3)) ff_d_func(
	.in(d_func_in),
	.clk(clk),
	.enable(d_enable),
	.reset(reset),
	.out(d_func)
);

wire [31:0] d_r_a;
reg [31:0] d_r_a_in;
ff #(.BITS(32)) ff_d_r_a(
	.in(d_r_a_in),
	.clk(clk),
	.enable(d_enable),
	.reset(reset),
	.out(d_r_a)
);

wire [31:0] d_r_b;
reg [31:0] d_r_b_in;
ff #(.BITS(32)) ff_d_r_b(
	.in(d_r_b_in),
	.clk(clk),
	.enable(d_enable),
	.reset(reset),
	.out(d_r_b)
);

reg d_nop_in = 0;
wire d_nop;
ff #(.BITS(1)) ff_d_nop (
	.in(f_nop || d_nop_in),
	.clk(clk),
	.enable(d_enable),
	.reset(reset),
	.out(d_nop)
);

reg d_wait = 0;



always @(posedge clk or posedge reset) begin
	if (reset) begin
		f_nop_in = 0;
	end else begin
		#0.05 // reset wait & nop to nood need overrite when it is 0
		d_wait = 0;
		d_nop_in = 0;
		#0.05
		d_func_in <= calc_func(f_instr[31:25]);
		d_r_d_a_in <= f_instr[24:20];
		d_is_load_in <= f_instr[31:25] == 'h11;
		d_is_store_in <= f_instr[31:25] == 'h13;
		d_r_a_in <= try_bypass(f_instr[19:15]);
		d_w_in <= needs_write(f_instr[31:25]);
		if (f_instr[31:29] == 0) begin
			d_r_b_in <= try_bypass(f_instr[14:10]);
		end
		// Put offset in r_b
		else if (f_instr[31:29] == 1) begin
			d_r_b_in <= f_instr[14:0];
		end
		else begin		
			d_r_b_in <= {f_instr[24:20], f_instr[14:0]};
		end
	end
end

// 0: ADD, 1: SUB, 2: MUL, 3: beq => ret 1, 4: jump
function [2:0] calc_func;
	input [5:0] op;
	begin
		if (op == 'h1)
			calc_func = 1;
		else if (op == 'h2)
			calc_func = 2;
		else if (op == 'h30)
			calc_func = 3;
		else if (op == 'h31)
			calc_func = 4;
		else
			calc_func = 0;
	end
endfunction 

// Tries to get vlaue if not possible stalls (set wait to true)
function [32:0] try_bypass;
	input [4:0] adr;
	begin
		if (d_nop == 0 && adr == d_r_d_a) begin
			// Dependency from decode no bypass possible
			//$display("  Stall %h: RAW r%0d unresolvable from decode", f_pc[11:0], adr);
			d_nop_in = 1;
			d_wait = 1;
			try_bypass = 32'bx;
		end else if (a_nop == 0 && adr == a_r_d_a && a_w) begin
			// Try bypass from alu first
			if (a_is_load == 0) begin
				try_bypass = a_res;
			end
			else begin
				// value not ready yet, wait
				d_nop_in = 1;
				d_wait = 1;
				//$display("  Stall %h: dependency unresolvable from alu", f_pc[11:0]);
				try_bypass =  32'bx;
			end
		end else if (a_nop == 0 && adr == c_r_d_a && c_w) begin
			// try bypass from cache
			if (c_nop == 0) begin
				try_bypass = c_res;
			end else begin
				d_nop_in = 1;
				d_wait = 1;
				//$display("  Stall %h: dependency unresolvable from cache", f_pc[11:0]);
				try_bypass = 32'bx;
			end
		end else
			// No bypass, so hoppfully reg value is "correct" for this instr
			try_bypass = rgs_out[adr];
	end
endfunction

function needs_write;
	input [5:0] op;
	begin 
		if ((op == 'h12) || (op == 'h30) || (op == 'h31) || (op == 'h32) || (op == 'h33)) begin
			needs_write = 0;
		end else	
			needs_write = 1;
	end
endfunction
