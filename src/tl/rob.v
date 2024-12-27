localparam NUM_ENTRIES = 9;


reg [4:0] rob_head  = 0;


reg rob_valid [NUM_ENTRIES:0];
reg [10:0] rob_exc [NUM_ENTRIES:0];
reg [32:0] rob_val [NUM_ENTRIES:0];
reg [32:0] rob_reg [NUM_ENTRIES:0];
reg [31:0] rob_pc [NUM_ENTRIES:0];
reg rob_write [NUM_ENTRIES:0];
reg rob_load [NUM_ENTRIES:0];
reg rob_store [NUM_ENTRIES:0];
reg rob_jump [NUM_ENTRIES:0];


always @(posedge clk or posedge reset) begin
    #0.1
    if (reset) begin
        rob_head = 0;
    end else if (rob_valid[rob_head]) begin 
        rob_valid[rob_head] = 0;
        rob_head += 1;
        if (rob_head >= NUM_ENTRIES) begin
            rob_head = 0;
        end
    end
end

task write_to_rob;
    input [4:0] in_tail;
	input in_valid;
	input [10:0] in_exc;
	input [31:0] in_val;
    input [31:0] in_reg;
	input [31:0] in_pc;
    input in_write;
	input in_load;
	input in_store;
	input in_jump;

    begin 
        #0.1
        rob_valid[in_tail] =  in_valid;
        rob_exc[in_tail] =  in_exc;
        rob_val[in_tail] =  in_val;
        rob_pc[in_tail] =  in_pc;
        rob_write[in_tail] =  in_write;
        rob_load[in_tail] =  in_load;
        rob_store[in_tail] =  in_store;
        rob_jump[in_tail] =  in_jump;
        rob_reg[in_tail] = in_reg;

        //$display("    Rob write [%d]: v: %0d, exc: %0d, val: %0d, pc: %0d, load: %0d, store: %0d, jump: %0d, ", in_tail, in_valid, in_exc, in_val, in_pc, in_load, in_store, in_jump);
    end

endtask


task print_rob;
    begin 
        $display("    Rob: H: %0d", rob_head);
        for(i = 0; i < NUM_ENTRIES; i += 1) begin
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