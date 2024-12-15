// icache Memory: 16 entries of 128-bit data and associated 10-bit tags
reg [127:0] icache_data [0:3];
reg [25:0] icache_tags [0:3];
reg icache_valid [0:3]; // Valid bit for each icache line
reg icache_read;
reg icache_write;
reg [31:0] iaddr;
integer icache_index; // icache index derived from address

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
        // $display("Reading from cache, pc %d", iaddr);
        if (icache_valid[iaddr[5:4]] && icache_tags[iaddr[5:4]] == iaddr[31:6]) begin
            // $display("Cache Hit: addr %d Byte = %0d, Index = %0d, Tag = %0h", iaddr, iaddr[:0], iaddr[5:4], iaddr[31:4]);
            f_instr_input <= icache_data[pc[5:4]][(pc[3:2]* 32) +: 32];
        end else begin // cache miss, get from mem and update
 			#0.01
			// $display("icache Miss: Reading from memory and updating icache addr %d", iaddr);
			imem_address <= iaddr[31:4];
        	imem_read <= 1;
			f_wait = 1;
			f_nop_in = 1;
        end
        icache_read <= 0;
    end else if (icache_write) begin // This isn't really write into icache but bringing in new line, do we need write for icache?
        // $display("Bringing in new cache line");
        // $display("Writing to cache, pc %d, :0=%d, 5:4=%d, 31:4=%d", iaddr, iaddr[5:4], iaddr[:0], iaddr[31:4]);
        icache_tags[iaddr[5:4]] <= iaddr[31:6]; 
        icache_data[iaddr[5:4]] <= out_imem; // Store 128-bit line
        icache_valid[iaddr[5:4]] <= 1;
        #0.01
        f_instr_input <= icache_data[iaddr[5:4]][(iaddr[3:2]* 32) +: 32];
        // $display("WRITING LINE %d", out_mem);
        // $display("INSTRUCTION %d | %d", f_instr_input, icache_data[iaddr[5:4]][(iaddr[:0]* 32) +: 32]);

        imem_read = 0;
        f_wait = 0;
        f_nop_in = 0;
        imem_finished = 0;
        icache_write = 0;
    end

end
