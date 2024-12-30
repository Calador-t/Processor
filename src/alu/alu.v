wire a_enable = 1; // TODO make wire
assign a_enable = ~(c_wait); 


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

wire [31:0] a_r_d_a_val;
ff #(.BITS(32)) ff_a_r_d_a_val (
    .in(d_r_d_a_val),
    .clk(clk),
    .enable(a_enable),
    .reset(reset),
    .out(a_r_d_a_val)
);

wire [1:0] a_stld_size;
ff #(.BITS(2)) ff_a_stld_size (
	.in(stld_size),
	.clk(clk),
	.enable(d_enable),
	.reset(reset),
	.out(a_stld_size)
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
    .enable(a_enable),
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

reg a_swap_rm4_in = 0;
wire a_swap_rm4;
ff #(.BITS(1)) ff_a_swap_rm4 (
    .in(a_swap_rm4_in),
    .clk(clk),
    .enable(a_enable),
    .reset(reset),
    .out(a_swap_rm4)
);

reg [4:0] a_exception_in = 0; // 0 itlb miss, 1 dtlb miss, ...
wire [4:0] a_exception;
ff #(.BITS(5)) ff_a_exception (
	.in(d_exception),
	.clk(clk),
	.enable(a_enable),
	.reset(reset),
	.out(a_exception)
);

reg a_wait = 0;


// 0: ADD, 1: SUB, 2: MUL, 3: beq => ret 1, 4: jump
always @(posedge clk or posedge reset) begin
    #0.01
    a_nop_in <= 0;
    a_swap_rm4_in <= 0;
    a_jump_in <= 0;
    // $display("ALU NOP %h", d_nop);
    if (d_exception != 0) begin
		f_nop_in <= 1;
        d_nop_in <= 1;
	end
    
	if (reset == 0 && !d_nop) begin
		#0.3
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
            $display("ALU jump");
            a_res_in <= d_r_d_a + $signed(d_r_b);
            a_jump_in = 1;
        end else if (d_func == 5) begin
            a_res_in <= d_r_a + $signed(d_r_b);
        end else if (d_func == 6) begin
            // a_res_in = d_r_a + $signed(d_r_b);
            // a_r_d_a <= d_r_a; // Move real destination
        end else if (d_func == 17) begin
            a_res_in <= d_r_a;
        end else if (d_func == 32) begin //TLBWRITE
            if (rm4) begin
                itlb_vpns[itlb_tail] <= rm1;
                itlb_ppns[itlb_tail] <= rm1[31:12] + 'h8000;
                itlb_valids[itlb_tail] = 1'b0;
                itlb_page_protections[itlb_tail] <= 'b11;
                #0.01
                $display("TLBWRITE index %h, iaddr %h, paddr %h", itlb_tail, itlb_vpns[itlb_tail], itlb_ppns[itlb_tail]);
                itlb_tail <= (itlb_tail + 1) % 20;
            end else begin
                $display("UNPRIVILEGED TLBWRITE");
            end
        end else if (d_func == 33) begin
            a_swap_rm4_in <= 1;
            a_jump_in <= 1;
            a_res_in <= rm1;
            $display("IRET, SWAPPING rm4 and JUMPING");

		end else begin
            a_res_in = 0;
            a_jump_in = 0;
        end
        
	end
end
		

