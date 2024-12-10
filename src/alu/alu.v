wire a_enable = 1; // TODO make wire
assign d_enable = ~(c_wait); 


wire [31:0] a_pc;
ff #(.BITS(32)) ff_a_pc (
    .in(d_pc),
    .clk(clk),
    .enable(a_enable),
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

wire a_jump;
reg a_jump_in;
ff #(.BITS(1)) ff_a_jump (
    .in(a_jump_in),
    .clk(clk),
    .enable(wb_enable),
    .reset(reset),
    .out(a_jump)
);

reg a_nop_in = 0;
wire a_nop;
ff #(.BITS(1)) ff_a_nop (
    .in(d_nop || a_nop_in),
    .clk(clk),
    .enable(a_enable),
    .reset(reset),
    .out(a_nop)
);

reg a_wait = 0;


// 0: ADD, 1: SUB, 2: MUL, 3: beq => ret 1, 4: jump
always @(posedge clk or posedge reset) begin
	if (reset == 0) begin
		#0.3
        // $display("D_NOP %d, A_NOP %d", d_nop, a_nop_in); 
		if (d_func == 0) begin
			a_res_in = d_r_a + d_r_b;
            a_jump_in = 0;
		end else if (d_func == 1) begin
			a_res_in = d_r_a - d_r_b;
            a_jump_in = 0;
		end else if (d_func == 2) begin
            a_res_in = d_r_a * d_r_b;
            a_jump_in = 0;
        end else if (d_func == 3) begin
            if (d_r_a == 0) begin
                // d_r_b is offset
                a_res_in = d_r_b;
                a_jump_in = 1;
            end else begin
                a_res_in = 0;
                a_jump_in = 0;
            end
            //$display("Beq val %0d", a_jump_in);
		end else if (d_func == 4) begin
            // d_r_b is offset
            a_res_in = d_r_a + $signed(d_r_b);
            a_jump_in = 1;
		end else begin
            a_res_in = 0;
            a_jump_in = 0;
        end
        
	end
end
		

