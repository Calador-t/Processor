// dcache Memory: 16 entries of 128-bit data and associated 10-bit tags
// do lb sb...
// pipe the destination reg value
// change addressing offset
reg [127:0] dcache_data [0:3];
reg [25:0] dcache_tags [0:3];
reg dcache_valid [0:3]; // Valid bit for each dcache line
reg dcache_read;
reg dcache_write;
reg [31:0] d_addr;
integer dcache_index; // dcache index derived from address

reg c_enable = 1;

wire [31:0] c_pc;
ff #(.BITS(32)) ff_c_pc (
    .in(a_pc),
    .clk(clk),
    .enable(c_enable),
    .reset(reset),
    .out(c_pc)
);


wire [4:0] c_r_d_a;
reg [4:0] c_r_d_a_in;
ff #(.BITS(5)) ff_c_r_d_a (
    .in(a_r_d_a),
    .clk(clk),
    .enable(c_enable),
    .reset(reset),
    .out(c_r_d_a)
);

wire c_w;
ff #(.BITS(1)) ff_c_w (
    .in(a_w),
    .clk(clk),
    .enable(c_enable),
    .reset(reset),
    .out(c_w)
);

wire [31:0] c_res;
reg [31:0] c_res_in;
ff #(.BITS(32)) ff_c_res (
    .in(c_res_in),
    .clk(clk),
    .enable(c_enable),
    .reset(reset),
    .out(c_res)
);

reg c_nop_in = 0;
wire c_nop;
ff #(.BITS(1)) ff_c_nop (
    .in(a_nop || c_nop_in),
    .clk(clk),
    .enable(c_enable),
    .reset(reset),
    .out(c_nop)
);

reg c_wait = 0;

wire c_swap_rm4;
ff #(.BITS(1)) ff_c_swap_rm4 (
    .in(a_swap_rm4),
    .clk(clk),
    .enable(c_enable),
    .reset(reset),
    .out(c_swap_rm4)
);

reg [4:0] c_exception_in = 0; // 0 itlb miss, 1 dtlb miss, ...
wire [4:0] c_exception;
ff #(.BITS(5)) ff_c_exception (
	.in(a_exception),
	.clk(clk),
	.enable(c_enable),
	.reset(reset),
	.out(c_exception)
);


always @(posedge clk) begin // exception
    #0.01
    if (a_exception != 0) begin
        f_nop_in <= 1;
        d_nop_in <= 1;
        a_nop_in <= 1;
        $display("Dcache noping");
    end
end

always @(posedge clk) begin // jump logic
    #0.2
    // $display("CCACHE SWAP %h", a_swap_rm4);
    pc_jump <= a_jump;
    if (a_jump && a_nop == 0) begin
        pc_in <= a_res;
        // nop everything older and reset nop in programcounter
        a_nop_in <= 1;
        d_nop_in <= 1;
        f_nop_in <= 1;
        // f_wait <= 1;
        #0.001 
        $display("CACHE Jumping now to! %h", a_res_in);
        if (a_swap_rm4) begin
            $display("IRET RM1 %d", rm1);
            // pc_in <= rm1;
            rm4 <= 0;     
        end
    end
end


always @(posedge reset) begin
    for (i = 0; i < 3; i = i + 1) begin
        dcache_valid[i] <= 0;
        dcache_tags[i] <= 24'bx;
        dcache_data[i] <= 128'bx;
    end
    dcache_read <= 0;
    dmem_read <= 0;
    dmem_write <=0;
end

reg dhit = 0;


always @(posedge clk) begin
    #0.1
    if (!a_nop) begin
        if (c_wait) begin
            if (dmem_finished) begin
                dcache_tags[d_addr[3:2]] <= d_addr[31:6]; 
                dcache_data[d_addr[3:2]] <= out_dmem;
                dcache_valid[d_addr[3:2]] <= 1;
                #0.01
                if (a_is_load) begin
                    $display("Loading from %d in dcache byte %d index %d",dcache_data[d_addr[5:4]][(d_addr[3:2]* 32) +: 32], d_addr[3:2], d_addr[5:4]);
                    if (a_stld_size == 32) begin
                        c_res_in <= dcache_data[d_addr[5:4]][(d_addr[3:2]* 32) +: 32];
                    end else if (a_stld_size == 16) begin
                        c_res_in <= dcache_data[d_addr[5:4]][(d_addr[3:2]* 32 + d_addr[1:0]*8) +: 16];
                    end else begin
                        c_res_in <= dcache_data[d_addr[5:4]][(d_addr[3:2]* 32 + d_addr[1:0]*8) +: 8];
                    end
                end
                if (a_is_store) begin
                    $display("Storing %d in dcache byte %d index %d",rgs_out[a_r_d_a], d_addr[3:2], d_addr[5:4]);
                    if (a_stld_size == 32) begin
                        dcache_data[d_addr[5:4]][(d_addr[3:2]* 32) +: 32] <= a_r_d_a_val;
                    end else if (a_stld_size == 16) begin
                        dcache_data[d_addr[5:4]][(d_addr[3:2]* 32 + d_addr[1:0]*8) +: 16] <= a_r_d_a_val[15:0];
                    end else begin
                        dcache_data[d_addr[5:4]][(d_addr[3:2]* 32 + d_addr[1:0]*8) +: 8] <= a_r_d_a_val[7:0];
                    end
                end
                    
                c_wait <= 0;
                dmem_read <= 0;
                c_nop_in <= 0;
                dmem_write <= 0;
            end
        end else if (a_is_load || a_is_store) begin 
            d_addr <= a_res;
            dhit <= (dcache_valid[d_addr[5:4]] && dcache_tags[d_addr[5:4]] == d_addr[31:6]);
            #0.01
            if (hit) begin
                $display("DCACHE HIT size %d", a_stld_size);
                if (a_is_store) begin
                    $display("Storing %d in dcache byte %d index %d",rgs_out[a_r_d_a], d_addr[3:2], d_addr[5:4]);
                    if (a_stld_size == 32) begin
                        dcache_data[d_addr[5:4]][(d_addr[3:2]* 32) +: 32] <= a_r_d_a_val;
                    end else if (a_stld_size == 16) begin
                        dcache_data[d_addr[5:4]][(d_addr[3:2]* 32 + d_addr[1:0]*8) +: 16] <= a_r_d_a_val[15:0];
                    end else begin
                        dcache_data[d_addr[5:4]][(d_addr[3:2]* 32 + d_addr[1:0]*8) +: 8] <= a_r_d_a_val[7:0];
                    end
                end else if (a_is_load) begin
                    $display("Loading from %d in dcache byte %d index %d",dcache_data[d_addr[5:4]][(d_addr[3:2]* 32) +: 32], d_addr[3:2], d_addr[5:4]);
                    if (a_stld_size == 32) begin
                        c_res_in <= dcache_data[d_addr[5:4]][(d_addr[3:2]* 32) +: 32];
                    end else if (a_stld_size == 16) begin
                        c_res_in <= dcache_data[d_addr[5:4]][(d_addr[3:2]* 32 + d_addr[1:0]*8) +: 16];
                    end else begin
                        c_res_in <= dcache_data[d_addr[5:4]][(d_addr[3:2]* 32 + d_addr[1:0]*8) +: 8];
                    end
                end
            end else begin
                if (dcache_valid[d_addr[3:2]]) begin 
                    // miss and need to flush cache 
                    // this will overlap the read always so no need to sync or anything, maybe implement more coherently when doing reordering and stuff
                    dmem_in_data <= dcache_data[d_addr[3:2]];
                    dmem_w_address <= dcache_tags[d_addr[3:2]];
                    dmem_write <= 1;
                end
                dmem_r_address <= d_addr[31:4];
                dmem_read <= 1;
                c_wait <= 1;
                c_nop_in <= 1;
            end
        end else begin
            c_res_in <= a_res;
        end
    end
end
