wire m1_enable = 1;
assign m1_enable = ~(t_wait || c_wait); 


wire [31:0] m1_pc;
reg [31:0] m1_pc_in = 32'bx;
ff #(.BITS(32), .START_VAL(1'bx)) ff_m1_pc (
    .in(m1_pc_in),
    .clk(clk),
    .enable(m1_enable),
    .reset(reset),
    .out(m1_pc)
);



wire [4:0] m1_r_d_a;
ff #(.BITS(5)) ff_m1_r_d_a (
    .in(d_r_d_a),
    .clk(clk),
    .enable(m1_enable),
    .reset(reset),
    .out(m1_r_d_a)
);

wire [31:0] m1_r_a;
reg [31:0] m1_r_a_in;
ff #(.BITS(32)) ff_mx_r_a(
	.in(m1_r_a_in),
	.clk(clk),
	.enable(m1_enable),
	.reset(reset),
	.out(m1_r_a)
);

wire [31:0] m1_r_b;
reg [31:0] m1_r_b_in;
ff #(.BITS(32)) ff_m1_r_b(
	.in(m1_r_b_in),
	.clk(clk),
	.enable(m1_enable),
	.reset(reset),
	.out(m1_r_b)
);

wire [4:0] m1_tail;
ff #(.BITS(5) ) ff_m1_tail (
    .in(d_tail),
    .clk(clk),
    .enable(m1_enable),
    .reset(reset),
    .out(m1_tail)
);


reg m1_nop_in = 1;
wire m1_nop;
ff #(.BITS(1)) ff_m1_nop (
    .in(m1_nop_in),
    .clk(clk),
    .enable(m1_enable),
    .reset(reset),
    .out(m1_nop)
);

reg m1_wait = 0;

always @(posedge clk or posedge reset) begin
    #0.1
    if (~reset && d_func == 2) begin
        //$display("M1 correct args, %d", d_r_b);
        m1_nop_in = 0;
        m1_pc_in = d_pc;
        m1_r_a_in = d_r_a;
        m1_r_b_in = d_r_b;
    end else begin
        //$display("M1 invalid args");
        m1_nop_in = 1;
        // This shows that mul is was not a mul inst (usefull for debug printing)
        m1_pc_in = 32'bx;
        m1_r_a_in = 32'bx;
        m1_r_b_in = 32'bx;
    end
end
