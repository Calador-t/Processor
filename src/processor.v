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
reg enable = 1;
reg [31:0] in_data = 0;
wire [31:0] data = 0;

// Wires: in_pc, pc, pcEnable
`include "rgs.v"
`include "mem.v"
`include "ff.v"
`include "fetch/fetch.v"
`include "decode/decode.v"
`include "alu/alu.v"
`include "write_back/write_back.v"

initial begin


#1 reset = 1;
#1 reset = 0;

#100 $finish;



	
end


always @(posedge clk or posedge reset) begin
	if (~reset) begin
		#0.1
		print_pipeline();
	end
end

task print_pipeline;
begin 	
	// if Pc == 0 in still in reseting stage => not started to work
	$display("");
	
	$display("%h  F", pc[11:0]);
	$display("%h  D: %h|%h|%h|%h|%h", 
		f_pc[11:0],
		f_instr[31:25], // Opcode
		f_instr[24:20], // Dst
		f_instr[19:15], // Src1
		f_instr[14:10], // Src2
		f_instr[9:0]	// Rest
	);
	$display("%h  ALU: f: %d, d_a: %0d, w: %d, r_a: %0d, r_b: %0d, load: %d, store: %d", 
		d_pc[11:0],
		d_func, 
		d_r_d_a, 
		d_w, 
		d_r_a, 
		d_r_b, 
		d_is_load, 
		d_is_store
	);
	$display("%h  Memory: res: %0d, d_a: %0d, w: %d, is_load: %d, is_store: %d", 
		a_pc[11:0],
		a_res, 
		a_r_d_a, 
		a_w, 
		a_is_load, 
		a_is_store
	);
	if (a_w) begin
		$display("%h  WB: rgs[%0d] = %0d", 
			a_pc[11:0],
			a_r_d_a, 
			a_res
		);
	end else 
		$display("%h  WB: no write",
			a_pc[11:0],
		);
end
endtask

endmodule
