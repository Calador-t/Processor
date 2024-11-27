
reg d_enable = 1; // TODO make wire


wire [31:0] d_pc;
ff #(.BITS(32)) ff_d_pc (
	.in(f_pc),
	.clk(clk),
	.enable(wb_enable),
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

wire [1:0] d_func;
reg [1:0] d_func_in;
ff #(.BITS(2)) ff_d_func(
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



always @(posedge clk or posedge reset) begin
	if (reset) begin
		
	end else if (enable) begin
		#0.1
		d_func_in <= calc_func(f_instr[31:25]);
		d_r_d_a_in <= f_instr[24:20];
		d_is_load_in <= f_instr[31:25] == 'h11;
		d_is_store_in <= f_instr[31:25] == 'h13;
		d_r_a_in <= rgs_out[f_instr[19:15]];
		d_w_in <= needs_write(f_instr[31:25]);
		
		if (f_instr[31:29] == 0) begin
			d_r_b_in <= rgs_out[f_instr[14:10]];
		end
		else if (f_instr[31:29] == 1) begin

			d_r_b_in <= f_instr[14:0];
		end
		else begin		
			d_r_b_in <= {f_instr[24:20], f_instr[14:0]};
		end
	end
end

// 0 = ADD, 1 = SUB, 2 = MUL
function [1:0] calc_func;
	input [5:0] op;
	begin
		if (op == 1)
			calc_func = 1;
		else if (op == 2)
			calc_func = 2;
		else
			calc_func = 0;
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
