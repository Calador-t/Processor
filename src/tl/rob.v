localparam ROB_NUM_ENTRIES = 9;


reg [4:0] rob_head  = 0;


reg rob_valid [ROB_NUM_ENTRIES:0];
reg [4:0] rob_exc [ROB_NUM_ENTRIES:0];

reg [31:0] rob_val [ROB_NUM_ENTRIES:0];
reg [4:0] rob_reg [ROB_NUM_ENTRIES:0];
reg [31:0] rob_pc [ROB_NUM_ENTRIES:0];
// for jumps it saves the tail of the next instruction after the jump
reg [31:0] rob_add_miss [ROB_NUM_ENTRIES:0];
reg rob_write [ROB_NUM_ENTRIES:0];
reg rob_load [ROB_NUM_ENTRIES:0];
reg rob_store [ROB_NUM_ENTRIES:0];
reg rob_jump [ROB_NUM_ENTRIES:0];


always @(posedge clk or posedge reset) begin
    #0.11
    if (reset) begin
        rob_head = 0;
    end else if (rob_valid[rob_head]) begin 
        if (rob_exc[rob_head] == 1) begin  // iTLB MISS
            pc_in <= 'h2000; // Jump to h2000
            pc_jump <= 1;
            rm4 <= 1; // Switch on supervisor mode
            rm0 <= irm0;
            rm1 <= irm1;
            f_nop_in <= 1;
            d_nop_in <= 1;
            // a_nop_in <= 1;
            // c_nop_in <= 1;
            $display("ITLB EXCEPTION, JUMPING TO 2K!");
            $display("%d", rob_exc[rob_head]);
            $display("");
            $display("");
            $display("");
            $display("");
        end else if (rob_exc[rob_head] == 2) begin // dTLB MISS
            pc_in <= 'h2010; // Jump to h2000
            pc_jump <= 1;
            rm4 <= 1; // Switch on supervisor mode
            f_nop_in <= 1;
            d_nop_in <= 1;
            a_nop_in <= 1;
            c_nop_in <= 1;
            rm0 <= drm0;
            rm1 <= drm1;
            $display("dTLB EXCEPTION, JUMPING TO 2K!");
            $display("%d", rob_exc[rob_head]);
            $display("");
            $display("");
            $display("");
            $display("");
        end else if (rob_write[rob_head] == 1) begin
            if (rob_reg[rob_head] < 32) begin
                rgs_out[rob_reg[rob_head]] = rob_val[rob_head];
            end
            #0.01
            for(i = 0; i < 32; i += 1) begin
				$display("Reg index %d = %d", i, rgs_out[i]);
				// #0.00001 $display("rg ini: %d", rgs_out[i]);
			end
            // #0.001 $display("    Wb: r[%0d] = %0d", c_r_d_a, rgs_out[c_res]);
        end
        rob_valid[rob_head] = 0;
        if (rob_jump[rob_head] == 1) begin
            rob_head = rob_add_miss[rob_head];    
        end else begin 
            rob_head += 1;
        end
        if (rob_head >= ROB_NUM_ENTRIES) begin
            rob_head = 0;
        end
    end
end

task write_to_rob;
    input [4:0] in_tail;
	input in_valid;
	input [4:0] in_exc;
	input [31:0] in_val;
    input [4:0] in_reg;
	input [31:0] in_pc;
    input [31:0] in_add_miss;
    input in_write;
	input in_load;
	input in_store;
	input in_jump;

    begin
        rob_valid[in_tail] =  in_valid;
        rob_exc[in_tail] =  in_exc;
        rob_val[in_tail] =  in_val;
        rob_pc[in_tail] =  in_pc;
        rob_add_miss[in_tail] = in_add_miss;
        rob_write[in_tail] =  in_write;
        rob_load[in_tail] =  in_load;
        rob_store[in_tail] =  in_store;
        rob_jump[in_tail] =  in_jump;
        rob_reg[in_tail] = in_reg;

        //$display("    Rob write [%0d]: v: %0d, exc: %0d, val: %0d, pc: %0d, load: %0d, store: %0d, jump: %0d, ", in_tail, in_valid, in_exc, in_val, in_pc, in_load, in_store, in_jump);
    end

endtask


task print_rob;
    begin 
        $display("    Rob: H: %0d", rob_head);
        for(i = 0; i < ROB_NUM_ENTRIES; i += 1) begin
			$display("        %0d: pc: %h v: %0d, exc: %0b, val: %0d, reg: %0d, load: %d, store: %d, jump: %d",
                i,
                rob_pc[i][11:0],
                rob_valid[i],
                rob_exc[i],
                rob_val[i],
                rob_reg[i],
                rob_load[i],
                rob_store[i],
                rob_jump[i]);
			end
    end
endtask