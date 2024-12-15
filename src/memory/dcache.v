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

always @(posedge clk or posedge reset) begin
    pc_jump <= a_jump;
    if (a_jump && a_nop == 0) begin
        pc_in <= a_res;
    end
end


always @(posedge reset) begin
    for (i = 0; i < 3; i = i + 1) begin
        dcache_valid[i] <= 0;
        dcache_tags[i] <= 24'bx;
        dcache_data[i] <= 128'bx;
    end
    dcache_read = 0;
end


always @(posedge clk or posedge reset) begin
    // $display("A RES %d", a_res);
    // $display("C RES %d", c_res);
    // $display("C RESIN %d", );
    #0.1
    // $display("ENABLE %d, NOP %d, WAIT %d, STORE %d, LOAD %d", c_enable, a_nop, c_wait, a_is_store, a_is_load);
    if (reset) begin
        dcache_read <= 0;
        dmem_read <= 0;
        dmem_write <=0;
    end
    else if (!a_nop) begin
        // $display("in hereh");   
        if (c_wait) begin
            // $display("in hereh2");
            // $display("D_ADDR %d, WAIT %d", d_addr, c_wait);
            // $display("Reading from DMEM ");
            if (dmem_finished) begin
                // $display("Reading from DMEM Finished %d", out_dmem);
                
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
            // #0.01
            // $display("D_ADDR %d, WAIT %d", d_addr, c_wait);
            hit <= (dcache_valid[d_addr[5:4]] && dcache_tags[d_addr[5:4]] == d_addr[31:6]);
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
                // $display("DCHACHE MISS");
            end
        end else begin
            // $display("here %d", c_enable);
            c_res_in <= a_res;
        end
    end
end
