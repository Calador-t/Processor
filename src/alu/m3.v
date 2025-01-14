wire m3_enable = 1;
assign m3_enable = ~(c_wait); 
wire [31:0] m3_pc;
ff #(.BITS(32)) ff_m3_pc (
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
ff #(.BITS(5)) ff_m3_tail (
    .in(m2_tail),
    .clk(clk),
    .enable(m3_enable),
    .reset(reset),
    .out(m3_tail)
);
wire m3_nop;
reg m3_nop_in = 1;
ff #(.BITS(1), .START_VAL(1)) ff_m3_nop (
    .in(m3_nop_in),
    .clk(clk),
    .enable(m3_enable),
    .reset(reset),
    .out(m3_nop)
);
reg m3_wait = 0;
always @(posedge clk or posedge reset) begin
    #0.1
    if (reset) begin
        m3_nop_in = 1;
    end else if (m2_nop == 0) begin
        $display("M3 processing ", m3_enable);
        m3_nop_in <= 0;
        m2_nop_in <= 1;
        m1_nop_in <= 1;
        a_wait = 1;
        a_nop_in <= 1;
    end else begin
        m3_nop_in <= 1;
    end
end