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
reg [31:0] page_translation = 0;
reg a_wait = 0;


// 0: ADD, 1: SUB, 2: MUL, 3: beq => ret 1, 4: jump
always @(posedge clk or posedge reset) begin
    #0.1
    a_nop_in <= 0;
    a_swap_rm4_in <= 0;
    a_jump_in <= 0;
    // $display("ALU NOP %h", d_nop);
    if (d_exception != 0) begin
		f_nop_in <= 1;
        d_nop_in <= 1;
	end
    if (reset == 0 && !d_nop && (d_func != 2 || d_exception != 0)) begin
        $display("Here %d", d_func);
		#0.1
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
            if (d_r_a == d_r_d_a_val) begin
                // a_res_in = d_r_b;
                // a_jump_in = 1;
                if (~(d_predict === 32'bx) && d_predict == d_r_b) begin
                    // Correct prediction
                    // => don't jump
                    $display("Correct prediction: %0h", d_predict);
                end else begin
                    // No prediction or wrong => jump to correct address
                    // d_r_b is offset
                    a_res_in = d_r_b;
                    a_jump_in = 1;
                    $display("targ: %0h", a_res_in);
                end
                set_prediction(d_pc, d_r_b, 1);
            end else begin
                // a_res_in = 0;
                // a_jump_in = 0;
                if (~(d_predict === 32'bx)) begin
                    // Jumped, but shouldn't have
                    $display("Rolback prediction: %0h", d_predict);
                    a_res_in = d_pc +4;
                    a_jump_in = 1;
                    $display("targ: %0h", a_res_in);
                    set_prediction(d_pc, d_r_b, 1);
                end else begin
                    $display("targ: %0h", a_res_in);
                    a_res_in = 0;
                    a_jump_in = 0;
                end
                set_prediction(d_pc, 0, 0);
            end
            #0.01
            print_bp();
            $display("%h: Beq val %d ?= %d -> ", d_pc, d_r_a, d_r_d_a_val, a_res_in);
		end else if (d_func == 4) begin
            $display("ALU jump");
            // a_res_in <= d_r_d_a + $signed(d_r_b);
            // a_jump_in = 1;
            if (~(d_predict === 32'bx) && d_predict == d_r_d_a + $signed(d_r_b)) begin
                // Correct prediction
                // => don't jump
            end else begin
                // d_r_b is offset
                $display("ALU jump");
                a_res_in <= d_r_d_a + $signed(d_r_b);
                a_jump_in = 1;
            end
            set_prediction(d_pc, d_r_d_a + $signed(d_r_b), 1);
            print_bp();
        end else if (d_func == 5) begin
            a_res_in <= d_r_a + $signed(d_r_b);
        end else if (d_func == 6) begin
            // a_res_in = d_r_a + $signed(d_r_b);
            // a_r_d_a <= d_r_a; // Move real destination
        end else if ((d_func > 9 && d_func < 16) || d_func == 17) begin
            a_res_in <= d_r_a;
            $display("Loading! %d", d_r_a);
        end else if (d_func == 32) begin //TLBWRITE
            $display("TLBWRITE");
            if (rm4) begin
                page_translation = rm1 + 'h8000;
                #0.01
                if (d_r_d_a == 0) begin
                    itlb_vpns[itlb_tail] <= rm1[31:12];
                    itlb_ppns[itlb_tail] <= page_translation[31:12];
                    itlb_valids[itlb_tail] = 1'b1;
                    itlb_page_protections[itlb_tail] <= 'b11;
                    #0.01
                    $display("TLBWRITE index %h, iaddr %h, paddr %h", itlb_tail, itlb_vpns[itlb_tail], itlb_ppns[itlb_tail]);
                    itlb_tail <= (itlb_tail + 1) % 20;
                end else begin
                    $display("rm1 %d rm0 %d", rm1, rm0);
                    dtlb_vpns[dtlb_tail] <= rm1[31:12];
                    dtlb_ppns[dtlb_tail] <= page_translation[31:12];
                    dtlb_valids[dtlb_tail] = 1'b1;
                    dtlb_page_protections[dtlb_tail] <= 'b11;
                    #0.01
                    $display("DTLBWRITE index %h, d_addr %h, paddr %h", dtlb_tail, dtlb_vpns[dtlb_tail], dtlb_ppns[dtlb_tail]);
                    #0.1
                    dtlb_tail <= (dtlb_tail + 1) % 20;
                end
            end else begin
                $display("UNPRIVILEGED TLBWRITE");
            end
        end else if (d_func == 33) begin
            a_swap_rm4_in <= 1;
            a_jump_in <= 1;
            a_res_in <= rm0;
            $display("IRET, SWAPPING rm4 and JUMPING TO rm0");
		end else begin
            a_res_in = 0;
            a_jump_in = 0;
        end
	end
end
		


