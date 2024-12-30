// General flags
reg imem_finished = 0;
reg dmem_finished = 0;
reg [32:0] imem_address;
reg [32:0] dmem_r_address;
reg [32:0] dmem_w_address;
reg [32:0] __imem_a_buffer;
reg [32:0] __dmem_r_a_buffer;
reg [32:0] __dmem_w_a_buffer;
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

reg [19:0] va_to_pa = 'h8000;
reg [31:0] rm0;
reg [31:0] rm1;

reg [127:0] __mem_data [50000:0]; 



initial begin
	// Load instructions into memory here or use an external file.
	$readmemb("fetch/instructions.bin", __mem_data, 2048, 3000);
end


always @(posedge reset or posedge mem_reset) begin
	integer i;
	iwait_cycles = -1;
	dmem_read <= 0;
	dmem_write <= 0;
	imem_read <= 0;
	rm0 <= 0;
	rm1 <= 0;
	
	// PROCESSOR BOOTS WITH IRET
	__mem_data[256] = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100110000000000000000000000000;

	// CURRENTLY JUST HAVE TLBWRITE WHICH ADDS THE 8000 AUTOMATICALLY AND IRET AT THE EXCEPTION PLACE
	__mem_data[512] = 128'b00000000000000000000000000000000000000000000000000000000000000000110011000000000000000000000000001100100000000000000000000000000;
end


always @(posedge dmem_write or posedge dmem_read or posedge imem_read) begin
    // $display("  %h  mem: imem_write %d, imem_read %d, reset %d, mem_reset %d", 
	// 		f_pc,
	// 		imem_write,
	// 		imem_read,
    //         reset,
    //         mem_reset,
	// 	);
	// if(imem_write) begin
	// 	__imem_in_d_buffer <= imem_in_data;
	// 	__imem_a_buffer <= imem_address;
	// 	__iwrite_or_read <= 1'b1;
	// 	iwait_cycles = 0;
	// end else 
	if (imem_read) begin	
        $display("READING Imem ADDRESS %h", imem_address);
		__imem_a_buffer <= imem_address;
		__iwrite_or_read <= 1'b0;
		iwait_cycles = 0;
	end
	
	if(dmem_write) begin
		$display("WRITING mem ADDRESS %h", dmem_w_address);
		__dmem_in_d_buffer <= dmem_in_data;
		__dmem_w_a_buffer <= dmem_w_address;
		__dwrite_or_read <= 1'b1;
		dwait_cycles = 0;
	end else if (dmem_read) begin	
        $display("READING Dmem ADDRESS %h", dmem_r_address);
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
				#0.01 
				$display("    Mem: Read [%d] = %b", __imem_a_buffer, __mem_data[__imem_a_buffer]);
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


