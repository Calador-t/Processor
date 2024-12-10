// icache Memory: 16 entries of 128-bit data and associated 10-bit tags
reg [127:0] icache_data [0:3];
reg [27:0] icache_tags [0:3];
reg icache_valid [0:15]; // Valid bit for each icache line
reg icache_read;
reg icache_write;
reg [31:0] icache_pc;
integer icache_index; // icache index derived from address
integer ic_i;

always @(posedge reset) begin
    for (i = 0; i < 3; i = i + 1) begin
        icache_valid[i] <= 0;
        icache_tags[i] <= 24'bx;
        icache_data[i] <= 128'bx;
    end
    icache_read = 0;
end


always @(posedge icache_read or posedge icache_write or posedge reset) begin
    if (reset) begin
        icache_read <= 0;
    end else if (icache_read) begin
        $display("Reading from cache, pc %d", icache_pc);
        if (icache_valid[icache_pc[3:2]] && icache_tags[icache_pc[3:2]] == icache_pc[31:4]) begin
            $display("Cache Hit: Byte = %0d, Index = %0d, Tag = %0h", pc[1:0], pc[3:2], pc[31:4]);
            f_instr_input <= icache_data[pc[3:2]][(pc[1:0]* 32) +: 32];
        end else begin // cache miss, get from mem and update
 			#0.01
			$display("icache Miss: Reading from memory and updating icache");
			mem_address <= icache_pc;
        	mem_read <= 1;
			f_wait = 1;
			f_nop_in = 1;
        end
        icache_read <= 0;
    end else if (icache_write) begin
        $display("Bringing in new cache line");
        // $display("Writing to cache, pc %d, 1:0=%d, 3:2=%d, 31:4=%d", icache_pc, icache_pc[3:2], icache_pc[1:0], icache_pc[31:4]);
        icache_tags[icache_pc[3:2]] <= icache_pc[31:4]; 
        icache_data[icache_pc[3:2]] <= out_mem; // Store 128-bit line
        icache_valid[icache_pc[3:2]] <= 1;
        #0.01
        f_instr_input <= icache_data[icache_pc[3:2]][(icache_pc[1:0]* 32) +: 32];
        // $display("WRITING LINE %d", out_mem);
        // $display("INSTRUCTION %d | %d", f_instr_input, icache_data[icache_pc[3:2]][(icache_pc[1:0]* 32) +: 32]);

        mem_read = 0;
        f_wait = 0;
        f_nop_in = 0;
        mem_finished = 0;
        icache_write = 0;
    end

end
