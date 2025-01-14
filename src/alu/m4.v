wire m4_enable = 1;
assign m4_enable = ~(c_wait); 
wire [31:0] m4_pc;
ff #(.BITS(32)) ff_m4_pc (
    .in(m3_pc),
    .clk(clk),
    .enable(m4_enable),
    .reset(reset),
    .out(m4_pc)
);
wire [4:0] m4_r_d_a;
ff #(.BITS(5)) ff_m4_r_d_a (
    .in(m3_r_d_a),
    .clk(clk),
    .enable(m4_enable),
    .reset(reset),
    .out(m4_r_d_a)
);
wire [31:0] m4_r_a;
ff #(.BITS(32)) ff_m4_r_a(
	.in(m3_r_a),
	.clk(clk),
	.enable(m4_enable),
	.reset(reset),
	.out(m4_r_a)
);
wire [31:0] m4_r_b;
ff #(.BITS(32)) ff_m4_r_b(
	.in(m3_r_b),
	.clk(clk),
	.enable(m4_enable),
	.reset(reset),
	.out(m4_r_b)
);
wire [4:0] m4_tail;
ff #(.BITS(5) ) ff_m4_tail (
    .in(m3_tail),
    .clk(clk),
    .enable(m4_enable),
    .reset(reset),
    .out(m4_tail)
);
wire m4_nop;
reg m4_nop_in = 1;
ff #(.BITS(1), .START_VAL(1)) ff_m4_nop (
    .in(m4_nop_in),
    .clk(clk),
    .enable(m4_enable),
    .reset(reset),
    .out(m4_nop)
);
reg m4_wait = 0;
always @(posedge clk or posedge reset) begin
    #0.1
    if (reset) begin
        m4_nop_in = 1;
    end else if (m3_nop == 0) begin
        #0.1
        $display("M4 processing");
        m4_nop_in = 0;
        m3_nop_in <= 1;
        m2_nop_in <= 1;
        m1_nop_in <= 1;
        a_wait = 1;
        a_nop_in <= 1;
    end else begin
        m4_nop_in = 1;
    end
end