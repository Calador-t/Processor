wire m3_enable = 1;
assign m3_enable = ~(c_wait); 


wire [31:0] m3_pc;
ff #(.BITS(32), .START_VAL(1'bx)) ff_m3_pc (
    .in(m2_pc),
    .clk(clk),
    .enable(m3_enable),
    .reset(reset),
    .out(m3_pc)
);



wire [4:0] m3_r_d_a;
ff #(.BITS(5)) ff_m3_r_d_a (
    .in(m2_r_d_a),
    .clk(clk),
    .enable(m3_enable),
    .reset(reset),
    .out(m3_r_d_a)
);

wire [31:0] m3_r_a;
ff #(.BITS(32)) ff_m3_r_a(
	.in(m2_r_a),
	.clk(clk),
	.enable(m3_enable),
	.reset(reset),
	.out(m3_r_a)
);

wire [31:0] m3_r_b;
ff #(.BITS(32)) ff_m3_r_b(
	.in(m2_r_b),
	.clk(clk),
	.enable(m3_enable),
	.reset(reset),
	.out(m3_r_b)
);

wire [4:0] m3_tail;
ff #(.BITS(5) ) ff_m3_tail (
    .in(m2_tail),
    .clk(clk),
    .enable(m3_enable),
    .reset(reset),
    .out(m3_tail)
);


wire m3_nop;
ff #(.BITS(1)) ff_m3_nop (
    .in(m2_nop),
    .clk(clk),
    .enable(m3_enable),
    .reset(reset),
    .out(m3_nop)
);

reg m3_wait = 0;

