
// General flags
reg mem_finished = 0;
reg [9:0] mem_address;
reg [9:0] __mem_a_buffer;
reg mem_reset;

// in vars
reg [127:0] mem_in_data;
reg [127:0] __mem_in_d_buffer;
reg mem_write;

// Mem read data
reg [127:0] out_mem;
reg mem_read;

reg __iwrite_or_read = 0;
integer wait_cycles;

reg [127:0] __mem_data [0:1023];



always @(posedge mem_write or posedge mem_read or posedge reset or posedge mem_reset) begin
    $display("  %h  mem: mem_write %d, mem_read %d, reset %d, mem_reset %d", 
			f_pc,
			mem_write,
			mem_read,
            reset,
            mem_reset,
		);
	if (reset || mem_reset) begin
		integer i;
		wait_cycles = -1;
		// for(i = 0; i < $size(__mem_data); i = i + 1) begin
		// 	__mem_data[i] <= 32'b0;
		// end	
	end
	else if(mem_write) begin
		__mem_in_d_buffer <= mem_in_data;
		__mem_a_buffer <= mem_address;
		__iwrite_or_read <= 1'b1;
		wait_cycles = 0;
	end
	else if (mem_read) begin	
        $display("READING mem ADDRESS %d", mem_address);
		__mem_a_buffer <= mem_address;
		__iwrite_or_read <= 1'b0;
		wait_cycles = 0;
	end 
	else
		$display("mem.v: Shouldn't be reached");
end 

always @(posedge clk) begin
	if (wait_cycles >= 0) begin
		wait_cycles += 1;
		#0.01
        // $display("WAIT CYCLES %d", wait_cycles);
		if (wait_cycles >= 5) begin
			if (__iwrite_or_read) begin
				__mem_data[__mem_a_buffer] <= __mem_in_d_buffer;
				#0.01 $display("    Mem: Wirte [%d] = %d", __mem_a_buffer, __mem_data[__mem_a_buffer]);
			end
			else begin
				
				out_mem <= __mem_data[__mem_a_buffer];
				#0.01 $display("    Mem: Read [%d] = %d", __mem_a_buffer, __mem_data[__mem_a_buffer]);
                // mem_read = 0;
			end
			#0.01 wait_cycles = -1;
			mem_finished = 1;
        end 
	end
end     


