
wire d_enable = 1; // TODO make wire
assign d_enable = ~( a_wait || c_wait); 

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

wire [31:0]d_r_d_a_val;
reg [31:0]d_r_d_a_val_in;
ff #(.BITS(32)) ff_d_r_d_a_val (
	.in(d_r_d_a_val_in),
	.clk(clk),
	.enable(d_enable),
	.reset(reset),
	.out(d_r_d_a_val)
);

wire [1:0] stld_size;
reg [1:0] stld_size_in;
ff #(.BITS(2)) ff_stld_size (
	.in(stld_size_in),
	.clk(clk),
	.enable(d_enable),
	.reset(reset),
	.out(stld_size)
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

wire [6:0] d_func;
reg [6:0] d_func_in;
ff #(.BITS(7)) ff_d_func(
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

reg [4:0] d_exception_in = 0; // 0 itlb miss, 1 dtlb miss, ...
wire [4:0] d_exception;
ff #(.BITS(5)) ff_d_exception (
	.in(f_exception),
	.clk(clk),
	.enable(d_enable),
	.reset(reset),
	.out(d_exception)
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
	#0.41
	if (reset) begin
		f_nop_in = 0;
	end else if (f_nop == 0) begin
		#0.05 // reset wait & nop to nood need overrite when it is 0
		d_wait = 0;
		d_nop_in = 0;
		
		#0.05
		d_func_in <= calc_func(f_instr[31:25]);
		#0.01

		d_r_d_a_in <= f_instr[24:20]; //Destination

		d_is_load_in <= (f_instr[31:25] == 'h10 || f_instr[31:25] == 'h11 || f_instr[31:25] == 'h12);
		d_is_store_in <= (f_instr[31:25] == 'h13 || f_instr[31:25] == 'h14 || f_instr[31:25] == 'h15);

		if (d_func_in == 17) begin
			d_r_a_in <= f_instr[19:0]; // LI WE WANT LITERAL
		end else begin
			$display("Trying bypass d_r_a");
			d_r_a_in <= try_bypass(f_instr[19:15]); //SRC1
			#0.1
			$display("HE In decode d_r_a_in %d %d", d_r_a_in, d_enable);	
			if (f_instr[31:29] == 1) begin
				d_r_b_in <= f_instr[14:0];
			end
		end

		d_w_in <= needs_write(f_instr[31:25]);
		if (d_func_in == 3) begin
			d_r_b_in <= f_instr[14:0];
		end if (f_instr[31:29] == 0) begin
			d_r_b_in <= try_bypass(f_instr[14:10]);
		end else begin		
			d_r_b_in <= {f_instr[24:20], f_instr[14:0]};
		end

		#0.01
		if (d_func_in == 13 || d_func_in == 10) begin
			stld_size_in <= 8;
		end else if (d_func_in == 14 || d_func_in == 11) begin
			stld_size_in <= 16;
		end else if (d_func_in == 15 || d_func_in == 12) begin
			stld_size_in <= 32;
		end
		#0.01
		if (d_is_store_in) begin // STW, we need memory address from 
			d_r_d_a_val_in <= try_bypass(f_instr[24:20]); //[stld_size_in:0]; //Destination
		end else if (d_func_in == 3) begin
			d_r_d_a_val_in <= try_bypass(f_instr[24:20]); // Store second operand for comp
		end

		if (f_exception != 0) begin
			$display("Exception in decode!");
			f_nop_in <= 1;
		end
		#0.01
		$display("In decode d_r_a_in %d", d_r_a_in);
	end
end

// 0: ADD, 1: SUB, 2: MUL, 3: beq => ret 1, 4: jump
function [6:0] calc_func;
	input [6:0] op;
	begin
		if (op == 'h1)
			calc_func = 1; //SUB
		else if (op == 'h2)
			calc_func = 2; //MUL
		else if (op == 'h30) 
			calc_func = 3; //BEQ
		else if (op == 'h31) 
			calc_func = 4; //JUMP
		else if (op == 'h10) 
			calc_func = 10; //LDB
		else if (op == 'h11) 
			calc_func = 11; //LDH
		else if (op == 'h12) 
			calc_func = 12; //LDW
		else if (op == 'h13) 
			calc_func = 13; //STB
		else if (op == 'h14) 
			calc_func = 14; //STH
		else if (op == 'h15) 
			calc_func = 15; //STW
		else if (op == 'h16)
			calc_func = 16; //MOV
		else if (op == 'h17) 
			calc_func = 17; //LI
		else if (op == 'h32) 
			calc_func = 32; // TLBWRITE
		else if (op == 'h33)
			calc_func = 33; // IRET
		else if (op == 'h34)
			calc_func = 34; // SPECIAL ADD FOR REGISTERS
		else
			calc_func = 0; //ADD
	end
endfunction 

// Tries to get vlaue if not possible stalls (set wait to true)
function [32:0] try_bypass;
	input [4:0] adr;
	if (d_func_in != 32 && d_func_in != 33) begin
		if (d_nop == 0 && adr == d_r_d_a) begin
			// Dependency from decode no bypass possible
			$display("  Stall %h: RAW r%0d unresolvable from decode", f_pc[11:0], adr);
			d_nop_in = 1;
			d_wait = 1;
			try_bypass = 32'bx;
		end else if (a_nop == 0 && adr == a_r_d_a && a_w) begin
			// Try bypass from alu first
			if (a_is_load == 0) begin
				try_bypass = a_res;
				$display(" Bypass %h: Decode Bypass from ALU got %d", f_pc[11:0], try_bypass);
			end
			else begin
				// value not ready yet, wait
				d_nop_in = 1;
				d_wait = 1;
				$display("  Stall %h: dependency unresolvable from alu", f_pc[11:0]);
				try_bypass =  32'bx;
			end
		end else if (a_nop == 0 && adr == c_r_d_a && c_w) begin
			// try bypass from cache
			if (c_nop == 0) begin
				try_bypass = c_res;
				$display(" Decode Bypass from Cache");
			end else begin
				d_nop_in = 1;
				d_wait = 1;
				$display("  Stall %h: dependency unresolvable from cache", f_pc[11:0]);
				try_bypass = 32'bx;
			end
		end else
			// No bypass, so hoppfully reg value is "correct" for this instr
			$display(" Bypass %h: Decode Value from Regs adr %d is %d", f_pc[11:0], adr, rgs_out[adr]);
			try_bypass = rgs_out[adr];
	end
endfunction

function needs_write;
	input [5:0] op;
	begin 
		if ((op == 'h13) || (op == 'h14) || (op == 'h15) || (op == 'h30) || (op == 'h31) || (op == 'h32) || (op == 'h33)) begin
			needs_write = 0;
		end else	
			needs_write = 1;
	end
endfunction
