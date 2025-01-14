`include "clock.v"
`include "reg32.v"
`include "ff.v"

module processor_tb;

// Declare the clock signal
wire clk;
// Instantiate the clock generator
clock #(.PERIOD(10)) clk_gen (
	.clk(clk)
);



reg reset = 0;
//reg enable = 1;
reg [31:0] 	in_data = 0;
wire [31:0] data = 0;
integer cycle_num = 0;

`include "rgs.v"
`include "fetch/fetch.v"
`include "decode/decode.v"
`include "alu/alu.v"
`include "mul/m1.v"
`include "mul/m2.v"
`include "mul/m3.v"
`include "mul/m4.v"
`include "mul/m5.v"
`include "tl/tl_m.v"
`include "tl/rob.v"
//`include "tl/tl.v"
`include "memory/dcache.v"
//`include "write_back/write_back.v"
`include "memory/mem.v"
`include "memory/dtlb.v"
`include "fetch/itlb.v"
`include "fetch/instruction_cache.v"
`include "fetch/programcounter.v"



initial begin
$dumpfile("test.vcd");
$dumpvars(0,processor_tb);

#1 reset = 1;
#1 reset = 0;
cycle_num = 0;
#150 $finish;
	
end


always @(posedge clk or posedge reset) begin
	if (~reset) begin
		cycle_num += 1;
		$display("Cycle: %0d", cycle_num);
		$display(" PC " , pc);
		$display("  En inc", enable_inc);
		#0.001 print_pipeline();
		$display(" PC " , pc);
		#9.0 $display("  En Fetch fe %d, dw %d, aw %d, cw %d, ", f_enable, d_wait, a_wait, c_wait);
		$display("f_n_i %d, f_e %d, e_inc %d", f_nop_in, f_enable, enable_inc);
	end
end


task print_pipeline;
begin
	$display("___________________________________________________");
	$display("");
	// Display Rob
	if (1) begin
		print_rob();
		$display("");
	end
	//$display("ICACHE %d | %d | %d | %d", icache_data[0], icache_data[1], icache_data[2], icache_data[3]);
	//$display("DCACHE %d | %d | %d | %d", dcache_data[0], dcache_data[1], dcache_data[2], dcache_data[3]);
	/*if (f_wait_for_cache) begin
		$display("  %h  F: wait cache, tail: %0d nop: %d", 
			f_pc,
			f_tail, 
			f_nop,
		);
	end else*/ begin
		$display("  %h  F: %h|%h|%h|%h|%h, tail: %0d exc: %d, nop: %d", 
			f_pc,
			f_instr[31:25], // Opcode
			f_instr[24:20], // Dst
			f_instr[19:15], // Src1
			f_instr[14:10], // Src2
			f_instr[9:0],	// Rest
			f_tail,
			f_exception,
			f_nop,
		);
	end
	//if (d_func === 6'bx || d_func != 2) begin
		$display("  %h  D: f: %d, d_a: %0d, w: %d, r_a: %0d, r_b: %0d, load: %d, store: %d, tail: %0d, exc: %d, nop: %d", 
			d_pc,
			d_func, 
			d_r_d_a, 
			d_w, 
			d_r_a, 
			d_r_b, 
			d_is_load,
			d_is_store,
			d_tail,
			d_exception,
			d_nop,
		);
	//end else begin
		// Mul instruction is executed
		if (a_jump) begin
			$display("  %h  ALU: Jump to %0d, tail: %0d, exc: %d, nop: %d", 
				a_pc,
				a_res,
				a_tail,
				a_exception,
				a_nop,
			);
		end else begin
			$display("  %h  ALU: res: %0d, d_a: %0d, w: %d, is_load: %d, is_store: %d, jump: %d, tail: %0d, exc: %d, nop: %d", 
				a_pc,
				a_res, 
				a_r_d_a, 
				a_w,
				a_is_load,
				a_is_store,
				a_jump,
				a_tail,
				a_exception,
				a_nop,
			);
		end
	//end
	if (~(m1_pc === 32'bx)) begin
		$display("  %h  M1: d_a: %0d, r_a: %0d, r_b: %0d, tail: %0d, nop: %d", 
			m1_pc,
			m1_r_d_a, 
			m1_r_a, 
			m1_r_b, 
			m1_tail,
			m1_nop,
		);
	end
	if (~(m2_pc === 32'bx)) begin
		$display("  %h  M2: d_a: %0d, r_a: %0d, r_b: %0d, tail: %0d, nop: %d", 
			m2_pc,
			m2_r_d_a, 
			m2_r_a, 
			m2_r_b, 
			m2_tail,
			//m2_exception,
			m2_nop,
		);
	end
	if (~(m3_pc === 32'bx)) begin
		$display("  %h  M3: d_a: %0d, r_a: %0d, r_b: %0d, tail: %0d, nop: %d", 
			m3_pc,
			m3_r_d_a, 
			m3_r_a, 
			m3_r_b, 
			m3_tail,
			//m3_exception,
			m3_nop,
		);
	end
	if (~(m4_pc === 32'bx)) begin
		$display("  %h  M4: d_a: %0d, r_a: %0d, r_b: %0d, tail: %0d, nop: %d", 
			m4_pc,
			m4_r_d_a, 
			m4_r_a, 
			m4_r_b, 
			m4_tail,
			//m4_exception,
			m4_nop,
		);
	end
	if (~(m5_pc === 32'bx)) begin
		$display("  %h  M5: d_a: %0d, res: %0d, tail: %0d, nop: %d", 
			m5_pc,
			m5_r_d_a, 
			m5_res,
			m5_tail,
			//m5_exception,
			m5_nop,
		);
	end
	
	if (rob_valid[rob_head] == 1) begin
		$display("  %h  TL: rob[%0d], valid: %d, res: %0d, d_a: %0d, is_load: %d, is_store: %d, jump: %d", 
			rob_pc[rob_head],
			rob_head,
			rob_valid[rob_head],
			rob_val[rob_head], 
			rob_reg[rob_head], 
			rob_load[rob_head], 
			rob_store[rob_head],
			rob_jump[rob_head],	
		);
	end else
		$display("  %h  TL: rob[%0d], not valid",
			rob_pc[rob_head],
			rob_head,
		);
	/*if (c_w) begin
		$display("  %h  WB: rgs[%0d] = %0d, nop: %d", 
			c_pc,
			c_r_d_a, 
			c_res,
			c_nop,
		);
	end else 
		$display("  %h  WB: no write, nop: %d",
			c_pc,
			c_nop,
		);*/
	$display("");
end
endtask

endmodule
