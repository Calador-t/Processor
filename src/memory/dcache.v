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
    .in((a_nop && m5_nop) || c_nop_in),
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

reg [4:0] c_exception_in = 0; // 1 itlb miss, 2 dtlb miss, ...
wire [4:0] c_exception;
ff #(.BITS(5)) ff_c_exception (
	.in(c_exception_in),
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
    #0.4
    pc_jump <= 0;
    #0.001
    // $display("dcache: a_jump %d", a_jump);
    if (a_jump && a_nop == 0) begin
        pc_in <= a_res;
        pc_jump <= a_jump;
        // nop everything older and reset nop in programcounter
        // f_wait <= 1;
        #0.001 
        $display("CACHE Jumping now to! %h", a_res);
        if (a_swap_rm4) begin
            $display("");
            $display("");
            $display("");
            $display("");
            $display("");
            $display("");
            // pc_in <= rm1;
            irm1 <= -1;
            irm0 <= -1;
            rm4 <= 0;     
        end
        #1
        a_nop_in <= 1;
        d_nop_in <= 1;
        f_nop_in <= 1;
        f_wait <= 0;
        d_wait <= 0;
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
integer sb_index = 0;
integer sb_conflict = 0;
integer j=0;

always @(posedge dcache_read) begin // we get here from dTLB, so we can skip most checks
    #0.1
    dhit <= (dcache_valid[d_addr[5:4]] && dcache_tags[d_addr[5:4]] == d_addr[31:6]);
    dcache_read <= 0;
    #0.01
    if (dhit) begin
        $display("DCACHE HIT size %d", a_stld_size);
        if (a_is_store) begin
            $display("Store buffer");
            if (~sb_valid[sb_tail]) begin
                sb_addresses[sb_tail] = d_addr;
                sb_data[sb_tail] = a_r_d_a_val;
                sb_valid[sb_tail] = 1;
                sb_tail = (sb_tail + 1) % 4;
            end else begin
                c_wait = 1;
                sb_drain = 1;
                c_nop_in = 1;
            end
            print_sb();
        end else if (a_is_load) begin
            $display("Loading %d bits from %d in dcache byte %d index %d", a_stld_size, dcache_data[d_addr[5:4]][(d_addr[3:2]* 32) +: 32], d_addr[3:2], d_addr[5:4]);
            sb_index = check_sb(d_addr);
            #0.01
            if (sb_index == 5) begin
                if (a_stld_size == 8) begin
                    c_res_in <= dcache_data[d_addr[5:4]][(d_addr[3:2]* 32 + d_addr[1:0]*8) +: 8];                
                end else if (a_stld_size == 16) begin
                    c_res_in <= dcache_data[d_addr[5:4]][(d_addr[3:2]* 32 + d_addr[1:0]*8) +: 16];
                end else begin
                    c_res_in <= dcache_data[d_addr[5:4]][(d_addr[3:2]* 32) +: 32];
                end
            end else begin
                c_res_in = sb_data[sb_index];
            end
        end
    end else begin
        $display("DCACHE MISS size %d", a_stld_size);
        if (dcache_valid[d_addr[5:4]]) begin 
            // miss and need to flush cache 
            // this will overlap the read always so no need to sync or anything, maybe implement more coherently when doing reordering and stuff
            for (i = 0; i < 4; i = i + 1) begin 
                j = (i + sb_head) % 4;
                if (sb_addresses[j][31:4] == ((dcache_tags[d_addr[5:4]] * 4) + d_addr[5:4]) && sb_valid[j]) begin
                    sb_drain = 1;
                    c_wait =1;
                    c_nop_in = 1;
                end
            end
            #0.01
            if (~sb_drain)begin
                $display("FLUSH CACHE ADDRESS %d", ((dcache_tags[d_addr[5:4]] * 4) + d_addr[5:4]));
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");
                $display("");

                dmem_in_data <= dcache_data[d_addr[5:4]];
                dmem_w_address <= ((dcache_tags[d_addr[5:4]] * 4) + d_addr[5:4]);
                dmem_write <= 1;
            end
        end
        if (~sb_drain) begin
            dmem_r_address <= d_addr[31:4];
            dmem_read <= 1;
            c_wait <= 1;
            c_nop_in <= 1;
        end
    end
end

// reg [31:0] test;
always @(posedge clk) begin
    #0.001
    // for (i = 0; i < 3; i = i + 1) begin
    //     test[31:6] = dcache_tags[i];
    //     test[5:4] = i;
    //     test[3:0] = 0;
    //     $display("%d, tag %d, daddr[31:6]: %d,d_addr %d, set %d, test %d", i, dcache_tags[i], d_addr[31:6], d_addr, d_addr[5:4], test);
    // end
    c_exception_in <= a_exception;
    #0.1
    if (c_wait) begin
        if (sb_drain) begin
            drain_sb();
            sb_drain = 0;
        end if (dmem_finished) begin
            #0.01
            dcache_tags[d_addr[5:4]] <= d_addr[31:6]; 
            dcache_data[d_addr[5:4]] <= out_dmem;
            dcache_valid[d_addr[5:4]] <= 1;
            #0.01
            c_wait <= 0;
            dmem_read <= 0;
            c_nop_in <= 0;
            dmem_write <= 0;
            dmem_finished <= 0;
            #0.01
            if (a_is_load) begin
                $display("Loading %d bits from %d in dcache byte %d index %d", a_stld_size, dcache_data[d_addr[5:4]][(d_addr[3:2]* 32) +: 32], d_addr[3:2], d_addr[5:4]);
                if (a_stld_size == 8) begin
                    c_res_in <= dcache_data[d_addr[5:4]][(d_addr[3:2]* 32 + d_addr[1:0]*8) +: 8];
                end else if (a_stld_size == 16) begin
                    c_res_in <= dcache_data[d_addr[5:4]][(d_addr[3:2]* 32 + d_addr[1:0]*8) +: 16];
                end else begin
                    c_res_in <= dcache_data[d_addr[5:4]][(d_addr[3:2]* 32) +: 32];
                end
            end
            if (a_is_store) begin
                if (~sb_valid[sb_tail]) begin
                    $display("Going into store buffer %d", sb_tail);
                    sb_addresses[sb_tail] = d_addr;
                    sb_data[sb_tail] = a_r_d_a_val;
                    sb_valid[sb_tail] = 1;
                    sb_tail = (sb_tail + 1) % 4;
                end else begin
                    $display("SB FULL draining next cycle");
                    c_wait = 1;
                    sb_drain = 1;
                    c_nop_in = 1;
                end
                print_sb();
            end
        end
    end else if ((a_is_load || a_is_store) && !a_nop) begin
        $display("Sending %d to dTLB", a_res);
        dtlb_va <= a_res;
        dtlb_read <= 1;
    end else begin
        drain_sb();
        if (a_nop == 1 && m5_nop == 0) begin
            c_res_in <= m5_res;
            $display("!!!!!! Made mult: %d", m5_res);
        end else begin
            c_res_in <= a_res;
        end;
    end
end
