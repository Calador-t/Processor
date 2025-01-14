
wire m2_enable = 1;
assign m2_enable = ~(c_wait); 
wire [31:0] m2_pc;
ff #(.BITS(32)) ff_m2_pc (
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
reg m2_nop_in = 1;
ff #(.BITS(1), .START_VAL(1)) ff_m2_nop (
    .in(m2_nop_in),
    .clk(clk),
    .enable(m2_enable),
    .reset(reset),
    .out(m2_nop)
);
reg m2_wait = 0;
always @(posedge clk or posedge reset) begin
    #0.1
    if (reset) begin
        m2_nop_in = 1;
    end else if (m1_nop == 0) begin
        
        $display("!!!! M2 processing");
        m2_nop_in <= 0;
        m1_nop_in <= 1;
        #0.01
        a_wait = 1;
        a_nop_in <= 1;
    end else begin
        m2_nop_in <= 1;
    end
end