reg a_enable = 1; // TODO make wire



wire [31:0] a_pc;
ff #(.BITS(32)) ff_a_pc (
    .in(d_pc),
    .clk(clk),
    .enable(wb_enable),
    .reset(reset),
    .out(a_pc)
);



wire [4:0] a_r_d_a;
ff #(.BITS(5)) ff_a_r_d_a (
    .in(d_r_d_a),
    .clk(clk),
    .enable(a_enable),
    .reset(reset),
    .out(a_r_d_a)
);

wire a_w;
ff #(.BITS(1)) ff_a_w (
    .in(d_w),
    .clk(clk),
    .enable(a_enable),
    .reset(reset),
    .out(a_w)
);

wire a_is_load;
ff #(.BITS(1)) ff_a_is_load (
    .in(d_is_load),
    .clk(clk),
    .enable(a_enable),
    .reset(reset),
    .out(a_is_load)
);

wire a_is_store;
ff #(.BITS(1)) ff_a_is_store (
    .in(d_is_store),
    .clk(clk),
    .enable(a_enable),
    .reset(reset),
    .out(a_is_store)
);

wire [31:0] a_res;
reg [31:0] a_res_in;
ff #(.BITS(32)) ff_a_res (
    .in(a_res_in),
    .clk(clk),
    .enable(a_enable),
    .reset(reset),
    .out(a_res)
);

always @(posedge clk or posedge reset) begin
	if (reset == 0 && enable == 1) begin
		#0.3
		if (d_func == 0) begin
			a_res_in = d_r_a + d_r_b;
			//#0.01 $display("Add: %0d", a_res_in);
		end else if (d_func == 1) begin
			a_res_in = d_r_a - d_r_b;
			//#0.01 $display("Sub: %0d", a_res_in);
		end else begin
			a_res_in = d_r_a * d_r_b;
			//#0.01 $display("Mul: %0d", a_res_in);
		end

	end
end
		

