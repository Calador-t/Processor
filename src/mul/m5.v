wire m5_enable = 1;
assign m5_enable = ~(c_wait); 


wire [31:0] m5_pc;
ff #(.BITS(32), .START_VAL(1'bx)) ff_m5_pc (
    .in(m4_pc),
    .clk(clk),
    .enable(m5_enable),
    .reset(reset),
    .out(m5_pc)
);



wire [4:0] m5_r_d_a;
ff #(.BITS(5)) ff_m5_r_d_a (
    .in(m4_r_d_a),
    .clk(clk),
    .enable(m5_enable),
    .reset(reset),
    .out(m5_r_d_a)
);

wire [31:0] m5_res;
reg [31:0] m5_res_in;
ff #(.BITS(32)) ff_m5_r_res(
	.in(m5_res_in),
	.clk(clk),
	.enable(m5_enable),
	.reset(reset),
	.out(m5_res)
);

wire [4:0] m5_tail;
ff #(.BITS(5) ) ff_m5_tail (
    .in(m5_tail),
    .clk(clk),
    .enable(m5_enable),
    .reset(reset),
    .out(m5_tail)
);


wire m5_nop;
ff #(.BITS(1)) ff_m5_nop (
    .in(m4_nop),
    .clk(clk),
    .enable(m5_enable),
    .reset(reset),
    .out(m5_nop)
);

reg m5_wait = 0;


always @(posedge clk or posedge reset) begin
    #0.1
    if (~reset && m4_nop == 0 && ~(m4_pc === 32'bx)) begin
        m5_res_in = m4_r_a * m4_r_b;
        //#0.01
        //$display("Res: %d = %d * %d, %d %d", m5_res_in, m4_r_a, m4_r_b, m4_pc, m4_pc === 32'bx);
    end
end
