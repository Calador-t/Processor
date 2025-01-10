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
reg [31:0] in_data = 0;
wire [31:0] data = 0;


`include "rgs.v"
`include "ff.v"
`include "fetch/fetch.v"
`include "decode/decode.v"
`include "alu/alu.v"
`include "mul/m1.v"
`include "mul/m2.v"
`include "mul/m3.v"
`include "mul/m4.v"
`include "mul/m5.v"
`include "tl/tl_m.v"
`include "tl/tl.v"
`include "memory/dcache.v"
`include "write_back/write_back.v"
`include "memory/mem.v"



initial begin


#1 reset = 1;
#1 reset = 0;
$display("R2 . ", rgs_out[2]);

#150 $finish;



	
end


always @(posedge clk or posedge reset) begin
	if (~reset) begin
		#0.001 print_pipeline();
	end
end


task print_pipeline;
begin
	$display("");
	// Display Rob
	if (1) begin
		print_rob();
		$display("");
	end
	//$display("ICACHE %d | %d | %d | %d", icache_data[0], icache_data[1], icache_data[2], icache_data[3]);
	//$display("DCACHE %d | %d | %d | %d", dcache_data[0], dcache_data[1], dcache_data[2], dcache_data[3]);
	if (f_wait_for_cache) begin
		$display("  %h  F: wait cache, tail: %0d nop: %d", 
			f_pc[11:0],
			f_tail, 
			f_nop,
		);
	end else begin
		$display("  %h  F: %h|%h|%h|%h|%h, tail: %0d nop: %d", 
			f_pc[11:0],
			f_instr[31:25], // Opcode
			f_instr[24:20], // Dst
			f_instr[19:15], // Src1
			f_instr[14:10], // Src2
			f_instr[9:0],	// Rest
			f_tail, 
			f_nop,
		);
	end
	//if (d_func === 6'bx || d_func != 2) begin
		$display("  %h  D: f: %d, d_a: %0d, w: %d, r_a: %0d, r_b: %0d, load: %d, store: %d, tail: %0d, nop: %d", 
			d_pc[11:0],
			d_func, 
			d_r_d_a, 
			d_w, 
			d_r_a, 
			d_r_b, 
			d_is_load,
			d_is_store,
			d_tail,
			d_nop,
		);
	//end else begin
		// Mul instruction is executed
		if (a_jump) begin
			$display("  %h  ALU: Jump to %0d, tail: %0d, nop: %d", 
				a_pc[11:0],
				a_res,
				a_tail,
				a_nop,
			);
		end else begin
			$display("  %h  ALU: res: %0d, d_a: %0d, w: %d, is_load: %d, is_store: %d, jump: %d, tail: %0d, nop: %d", 
				a_pc[11:0],
				a_res, 
				a_r_d_a, 
				a_w,
				a_is_load,
				a_is_store,
				a_jump,
				a_tail,
				a_nop,
			);
		end
	//end
	if (~(m1_pc === 32'bx)) begin
		$display("  %h  M1: d_a: %0d, r_a: %0d, r_b: %0d, tail: %0d, nop: %d", 
			m1_pc[11:0],
			m1_r_d_a, 
			m1_r_a, 
			m1_r_b, 
			m1_tail,
			m1_nop,
		);
	end
	if (~(m2_pc === 32'bx)) begin
		$display("  %h  M2: d_a: %0d, r_a: %0d, r_b: %0d, tail: %0d, nop: %d", 
			m2_pc[11:0],
			m2_r_d_a, 
			m2_r_a, 
			m2_r_b, 
			m2_tail,
			m2_nop,
		);
	end
	if (~(m3_pc === 32'bx)) begin
		$display("  %h  M3: d_a: %0d, r_a: %0d, r_b: %0d, tail: %0d, nop: %d", 
			m3_pc[11:0],
			m3_r_d_a, 
			m3_r_a, 
			m3_r_b, 
			m3_tail,
			m3_nop,
		);
	end
	if (~(m4_pc === 32'bx)) begin
		$display("  %h  M4: d_a: %0d, r_a: %0d, r_b: %0d, tail: %0d, nop: %d", 
			m4_pc[11:0],
			m4_r_d_a, 
			m4_r_a, 
			m4_r_b, 
			m4_tail,
			m4_nop,
		);
	end
	if (~(m5_pc === 32'bx)) begin
		$display("  %h  M5: d_a: %0d, res: %0d, tail: %0d, nop: %d", 
			m5_pc[11:0],
			m5_r_d_a, 
			m5_res,
			m5_tail,
			m5_nop,
		);
	end
	
	if (rob_valid[rob_head] == 1) begin
		$display("  %h  TL: rob[%0d], valid: %d, res: %0d, d_a: %0d, is_load: %d, is_store: %d, jump: %d", 
			rob_pc[rob_head][11:0],
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
			rob_pc[rob_head][11:0],
			rob_head,
		);
	if (c_w) begin
		$display("  %h  WB: rgs[%0d] = %0d, nop: %d", 
			c_pc[11:0],
			c_r_d_a, 
			c_res,
			c_nop,
		);
	end else 
		$display("  %h  WB: no write, nop: %d",
			c_pc[11:0],
			c_nop,
		);
	$display("___________________________________________________");
	$display("");
end
endtask

endmodule
