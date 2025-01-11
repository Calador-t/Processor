wire m2_enable = 1;
assign m2_enable = ~(c_wait); 


wire [31:0] m2_pc;
ff #(.BITS(32), .START_VAL(1'bx)) ff_m2_pc (
    .in(m1_pc),
    .clk(clk),
    .enable(m2_enable),
    .reset(reset),
    .out(m2_pc)
);



wire [4:0] m2_r_d_a;
ff #(.BITS(5)) ff_m2_r_d_a (
    .in(m1_r_d_a),
    .clk(clk),
    .enable(m2_enable),
    .reset(reset),
    .out(m2_r_d_a)
);

wire [31:0] m2_r_a;
ff #(.BITS(32)) ff_m2_r_a(
	.in(m1_r_a),
	.clk(clk),
	.enable(m2_enable),
	.reset(reset),
	.out(m2_r_a)
);

wire [31:0] m2_r_b;
ff #(.BITS(32)) ff_m2_r_b(
	.in(m1_r_b),
	.clk(clk),
	.enable(m2_enable),
	.reset(reset),
	.out(m2_r_b)
);

wire [4:0] m2_tail;
ff #(.BITS(5) ) ff_m2_tail (
    .in(m1_tail),
    .clk(clk),
    .enable(m2_enable),
    .reset(reset),
    .out(m2_tail)
);


wire m2_nop;
ff #(.BITS(1)) ff_m2_nop (
    .in(m1_nop),
    .clk(clk),
    .enable(m2_enable),
    .reset(reset),
    .out(m2_nop)
);

reg m2_wait = 0;

