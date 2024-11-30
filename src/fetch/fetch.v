`include "fetch/programcounter.v"

assign reset_pc = reset;
// if 
assign enable_inc = ~(f_wait || d_wait || a_wait || c_wait); 
assign f_enable = enable_inc;
reg [31:0] memory [0:35];
wire f_enable = 1;


reg [31:0] f_instr_input;
wire [31:0] f_instr;
ff f_instr_ff(
	.in(f_instr_input),
	.clk(clk),
	.enable(f_enable),
	.reset(reset),
	.out(f_instr)
);

wire [31:0] f_pc;
ff #(.BITS(32)) ff_f_pc (
	.in(pc),
	.clk(clk),
	.enable(f_enable),
	.reset(reset),
	.out(f_pc)
);

reg f_nop_in = 0;
wire f_nop;
ff #(.BITS(1)) ff_f_nop (
	.in(f_nop_in),
	.clk(clk),
	.enable(f_enable),
	.reset(reset),
	.out(f_nop)
);

reg f_wait = 0;



initial begin 
	// Load instructions into memory here or use an external file.
	$readmemb("memory/instructions.bin", memory);
end


// Optional: Logic to use the instruction (for example, display it)
always @(posedge clk or posedge reset) begin
	if (reset) begin
		f_nop_in = 0;
		f_instr_input = 32'b0;
		
	end else begin
		f_nop_in = 0;
		// wait for pc to be finished
		#0.1 f_instr_input <= memory[pc]; // Lines start with one but pc starts at 0 => read one earlier
	end
end

