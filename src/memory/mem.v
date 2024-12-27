// General flags
reg imem_finished = 0;
reg dmem_finished = 0;
reg [9:0] imem_address;
reg [9:0] dmem_r_address;
reg [9:0] dmem_w_address;
reg [9:0] __imem_a_buffer;
reg [9:0] __dmem_r_a_buffer;
reg [9:0] __dmem_w_a_buffer;
reg mem_reset;

// in vars
reg [127:0] dmem_in_data;
reg [127:0] __dmem_in_d_buffer;
reg dmem_write;

// Mem read data
reg [127:0] out_imem;
reg [127:0] out_dmem;
reg imem_read;
reg dmem_read;

reg __iwrite_or_read = 0;
reg __dwrite_or_read = 0;
integer iwait_cycles;
integer dwait_cycles;

reg [127:0] __mem_data [5:0];



always @(posedge dmem_write or posedge dmem_read or posedge imem_read or posedge reset or posedge mem_reset) begin
    // $display("  %h  mem: imem_write %d, imem_read %d, reset %d, mem_reset %d", 
	// 		f_pc,
	// 		imem_write,
	// 		imem_read,
    //         reset,
    //         mem_reset,
	// 	);
	if (reset || mem_reset) begin
		integer i;
		iwait_cycles = -1;
		dmem_read <= 0;
		dmem_write <= 0;
		imem_read <= 0;
	end
	// if(imem_write) begin
	// 	__imem_in_d_buffer <= imem_in_data;
	// 	__imem_a_buffer <= imem_address;
	// 	__iwrite_or_read <= 1'b1;
	// 	iwait_cycles = 0;
	// end else 
	if (imem_read) begin
        // $display("READING Imem ADDRESS %d", imem_address);
		__imem_a_buffer <= imem_address;
		__iwrite_or_read <= 1'b0;
		iwait_cycles = 0;
	end
	
	if(dmem_write) begin
		// $display("WRITING mem ADDRESS %d", dmem_w_address);
		__dmem_in_d_buffer <= dmem_in_data;
		__dmem_w_a_buffer <= dmem_w_address;
		__dwrite_or_read <= 1'b1;
		dwait_cycles = 0;
	end else if (dmem_read) begin	
        // $display("READING Dmem ADDRESS %d", dmem_r_address);
		__dmem_r_a_buffer <= dmem_r_address;
		__dwrite_or_read <= 1'b0;
		dwait_cycles = 0;
	end 
end 

always @(posedge clk) begin
	// $display("MEM DW %d DR %d IM %d IW %d", dmem_write, dmem_read, imem_read, imem_write);
	if (iwait_cycles >= 0) begin
		iwait_cycles += 1;
		#0.01
        // $display("WAIT CYCLES %d", iwait_cycles);
		if (iwait_cycles >= 2) begin
			// if (__iwrite_or_read) begin
			// 	__mem_data[__imem_a_buffer] <= __imem_in_d_buffer;
			// 	// #0.01 $display("    Mem: Wirte [%d] = %d", __imem_a_buffer, __mem_data[__imem_a_buffer]);
			// end
			// else begin
				
			out_imem <= __mem_data[__imem_a_buffer];
				// #0.01 $display("    Mem: Read [%d] = %d", __imem_a_buffer, __mem_data[__imem_a_buffer]);
                // imem_read = 0;
			// end
			#0.01 
			iwait_cycles = -1;
			imem_finished = 1;
        end 
	end
	if (dwait_cycles >= 0) begin
		dwait_cycles += 1;
		#0.01
        // $display("WAIT CYCLES %d", iwait_cycles);
		if (dwait_cycles >= 2) begin
			if (dmem_write) begin
				__mem_data[__dmem_w_a_buffer] <= __dmem_in_d_buffer;
				#0.01 $display("    Mem: Wirte [%d] = %d", __dmem_w_a_buffer, __mem_data[__dmem_w_a_buffer]);
			end
			if (dmem_read) begin
				out_dmem <= __mem_data[__dmem_r_a_buffer];
				#0.01 $display("    Mem: Read [%d] = %d", __dmem_r_a_buffer, __mem_data[__dmem_r_a_buffer]);
				dmem_finished = 1;
			end
			#0.01 
			dwait_cycles = -1;
			dmem_write <= 0;

        end 
	end
end     


task print_memory();
	begin
		$display("Memory:");
		for(i = 0; i < 128; i += 1) begin
			// ignore empty memory
			if (~(__mem_data[i] === 128'bx)) begin
				//$display("    %h: %h|%h|%h|%h", i[6:0], __mem_data[i][127:96], __mem_data[i][95:64], __mem_data[i][63:32], __mem_data[i][31:0]);
				$display("    %h: %h|%h|%h|%h|%h | %h|%h|%h|%h|%h | %h|%h|%h|%h|%h | %h|%h|%h|%h|%h", 
					i[6:0],
					__mem_data[i][(96 + 25) +: 7], // Opcode
					__mem_data[i][(96 + 20) +: 5], // Dst
					__mem_data[i][(96 + 15) +: 5], // Src1
					__mem_data[i][(96 + 10) +: 5], // Src2
					__mem_data[i][96 +: 10],	// Rest

					__mem_data[i][(64 + 25) +: 7], // Opcode
					__mem_data[i][(64 + 20) +: 5], // Dst
					__mem_data[i][(64 + 15) +: 5], // Src1
					__mem_data[i][(64 + 10) +: 5], // Src2
					__mem_data[i][64 +: 10],	// Rest

					__mem_data[i][(32 + 25) +: 7], // Opcode
					__mem_data[i][(32 + 20) +: 5], // Dst
					__mem_data[i][(32 + 15) +: 5], // Src1
					__mem_data[i][(32 + 10) +: 5], // Src2
					__mem_data[i][32 +: 10],	// Rest

					__mem_data[i][(0 + 25) +: 7], // Opcode
					__mem_data[i][(0 + 20) +: 5], // Dst
					__mem_data[i][(0 + 15) +: 5], // Src1
					__mem_data[i][(0 + 10) +: 5], // Src2
					__mem_data[i][0 +: 10],	// Rest
				);
			end
			//$display("   %h|%h|%h|%h", __mem_data[i][]);
		end
		$display("");
	end
endtask