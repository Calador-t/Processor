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
        if (icache_valid[iaddr[5:4]] && icache_tags[iaddr[5:4]] == iaddr[31:6]) begin
            
            f_instr_input <= icache_data[pc[5:4]][(pc[3:2]* 32) +: 32];
            // $display("iCache Hit: addr %h Byte = %0d, Index = %0d, Tag = %0h", iaddr, iaddr[3:2], iaddr[5:4], iaddr[31:6]);
            f_nop_in <= 0;
        end else begin // cache miss, get from mem and update
 			#0.2
			// $display("icache Miss: Reading from memory and updating icache addr %h", iaddr);
            // $display("CACHE ADDR %d", iaddr[31:4]);
            // $display("CACHE ADDR FULL %d", iaddr);
			imem_address <= iaddr[31:4];
        	imem_read <= 1;
			f_wait = 1;
			f_nop_in = 1;
        end
        #0.01
        icache_read <= 0;
    end else if (icache_write) begin
        icache_tags[iaddr[5:4]] <= iaddr[31:6]; 
        icache_data[iaddr[5:4]] <= out_imem; // Store 128-bit line
        icache_valid[iaddr[5:4]] <= 1;
        #0.01
        f_instr_input <= icache_data[iaddr[5:4]][(iaddr[3:2]* 32) +: 32];
        // $display("Cache Fetch done: addr %h Byte = %0d, Index = %0d, Tag = %0h", iaddr, iaddr[3:2], iaddr[5:4], iaddr[31:6]);
    
        #0.01


        imem_read = 0;
        f_wait = 0;
        f_nop_in = 0;
        imem_finished = 0;
        icache_write = 0;
    end

end
