
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

reg __write_or_read = 0;
integer wait_cycles;

reg [127:0] __mem_data [1023:0];

always @(posedge mem_write or posedge mem_read or posedge reset or posedge mem_reset) begin
	if (reset || mem_reset) begin
		integer i;
		wait_cycles = -1;
		for(i = 0; i < $size(__mem_data); i = i + 1) begin
			__mem_data[i] <= 128'b0;
		end	
	end
	else if(mem_write) begin
		__mem_in_d_buffer <= mem_in_data;
		__mem_a_buffer <= mem_address;
		__write_or_read <= 1'b1;
		wait_cycles = 0;
	end
	else if (mem_read) begin	
		__mem_a_buffer <= mem_address;
		__write_or_read <= 1'b0;
		wait_cycles = 0;
	end 
	else
		$display("mem.v: Shouldn't be reached");
end 

always @(posedge clk) begin
	if (wait_cycles >= 0) begin
		wait_cycles += 1;
		if (wait_cycles >= 5) begin
			if (__write_or_read) begin
				__mem_data[__mem_a_buffer] <= __mem_in_d_buffer;
				#0.01 $display("    Mem: Wirte [%d] = %d", __mem_a_buffer, __mem_data[__mem_a_buffer]);
			end
			else begin
				out_mem <= __mem_data[__mem_a_buffer];
				#0.01 $display("    Mem: Read [%d] = %d", __mem_a_buffer, __mem_data[__mem_a_buffer]);
			end
			wait_cycles = -1;
			mem_finished = 1;
			mem_finished = 0;
		end
	end
end 


