reg t_enable = 1;

wire [31:0] t_pc;
ff #(.BITS(32)) ff_t_pc (
    .in(rob_valid[rob_head] ? rob_pc[rob_head] : 32'bx),
    .clk(clk),
    .enable(t_enable),
    .reset(reset),
    .out(t_pc)
);


wire [4:0] t_r_d_a;
reg [4:0] t_r_d_a_in;
ff #(.BITS(5)) ff_t_r_d_a (
    .in(rob_valid[rob_head] ? rob_reg[rob_head] : 5'bx),
    .clk(clk),
    .enable(t_enable),
    .reset(reset),
    .out(t_r_d_a)
);

wire [31:0] t_r_d_a_val;
ff #(.BITS(32)) ff_t_r_d_a_val (
    .in(rob_valid[rob_head] ? rob_val[rob_head] : 32'bx),
    .clk(clk),
    .enable(a_enable),
    .reset(reset),
    .out(t_r_d_a_val)
);


wire t_w;
ff #(.BITS(1)) ff_t_w (
    .in(rob_valid[rob_head] ? rob_write[rob_head] : 1'bx),
    .clk(clk),
    .enable(t_enable),
    .reset(reset),
    .out(t_w)
);

wire [31:0] t_res;
reg [31:0] t_res_in;
ff #(.BITS(32)) ff_t_res (
    .in(rob_valid[rob_head] ? rob_val[rob_head] : 32'bx),
    .clk(clk),
    .enable(t_enable),
    .reset(reset),
    .out(t_res)
);


wire t_is_load;
reg t_is_load_in = 0;
ff #(.BITS(1)) ff_t_is_load (
    .in(rob_valid[rob_head] ? rob_load[rob_head] : 1'bx),
    .clk(clk),
    .enable(t_enable),
    .reset(reset),
    .out(t_is_load)
);

wire t_is_store;
ff #(.BITS(1)) ff_t_is_store (
    .in(rob_valid[rob_head] ? rob_store[rob_head] : 1'bx),
    .clk(clk),
    .enable(t_enable),
    .reset(reset),
    .out(t_is_store)
);


wire t_jump;
ff #(.BITS(1)) ff_t_jump (
    .in(rob_valid[rob_head] ? rob_jump[rob_head] : 1'bx),
    .clk(clk),
    .enable(wb_enable),
    .reset(reset),
    .out(t_jump)
);


wire [1:0] t_stld_size;
ff #(.BITS(2)) ff_t_stld_size (
	.in(a_stld_size),
	.clk(clk),
	.enable(d_enable),
	.reset(reset),
	.out(t_stld_size)
);


reg t_nop_in = 0;
wire t_nop;
ff #(.BITS(1)) ff_t_nop (
    .in(a_nop || t_nop_in),
    .clk(clk),
    .enable(t_enable),
    .reset(reset),
    .out(t_nop)
);

reg t_wait = 0;

`include "tl/rob.v"

always @(posedge clk or posedge reset) begin
    #0.4
    if (~reset && a_nop == 0) begin
        //$display("write rob: pc %h, tail %d", a_pc[11:0], a_tail);
        write_to_rob(
            a_tail,
            1,
            0, // TODO handle exceptions
            a_res,
            a_r_d_a,
            a_pc,
            a_w,
            a_is_load,
            a_is_store,
            a_jump);
    end
end
