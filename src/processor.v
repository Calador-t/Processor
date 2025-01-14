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


`include "rgs.v"
`include "fetch/fetch.v"
`include "fetch/branch_predictor.v"
`include "fetch/itlb.v"
`include "fetch/instruction_cache.v"
`include "fetch/programcounter.v"
`include "decode/decode.v"
`include "alu/alu.v"
`include "alu/m1.v"
`include "alu/m2.v"
`include "alu/m3.v"
`include "alu/m4.v"
`include "alu/m5.v"
`include "memory/dcache.v"
`include "memory/sb.v"
`include "write_back/write_back.v"
`include "memory/mem.v"
`include "memory/dtlb.v"





initial begin
$dumpfile("test.vcd");
$dumpvars(0,processor_tb);

#1 reset = 1;
#1 reset = 0;

// #700 $finish;
	
end

integer cycle_num = 0;
always @(posedge clk or posedge reset) begin
	if (~reset) begin
		cycle_num += 1;
		$display("Cycle: %d", cycle_num);
		#0.9
		print_pipeline();
	end
end


task print_pipeline;
begin
	// $display("RM4 %d", rm4);
	// $display("ICACHE %d | %d | %d | %d", icache_data[0], icache_data[1], icache_data[2], icache_data[3]);
	// $display("DCACHE %b | %b | %b | %b", dcache_data[0], dcache_data[1], dcache_data[2], dcache_data[3]);
	$display("  %h  F", pc);
	$display("  %h  D: %h|%h|%h|%h|%h nop: %d", 
		f_pc,
		f_instr[31:25], // Opcode
		f_instr[24:20], // Dst
		f_instr[19:15], // Src1
		f_instr[14:10], // Src2
		f_instr[9:0],	// Rest
		f_nop,
	);
	$display("  %h  ALU: f: %d, d_a: %0d, w: %d, r_a: %0d, r_b: %0d, load: %d, store: %d, nop: %d", 
		d_pc,
		d_func, 
		d_r_d_a, 
		d_w, 
		d_r_a, 
		d_r_b, 
		d_is_load,
		d_is_store,
		d_nop,
	);
	if (a_jump)
		$display("  %h  Cache: Jump to %0d, nop: %d", 
			a_pc,
			a_res,
			a_nop,
		);
	else
		$display("  %h  Cache: res: %0d, d_a: %0d, w: %d, is_load: %d, is_store: %d, jump: %d, nop: %d", 
			a_pc,
			a_res, 
			a_r_d_a, 
			a_w, 
			a_is_load, 
			a_is_store,
			a_jump,
			a_nop,
		);
	if (c_w) begin
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
		);
	$display("___________________________________________________");
	$display("");
end
endtask

endmodule
