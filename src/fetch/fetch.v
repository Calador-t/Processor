`include "fetch/programcounter.v"
`include "fetch/instruction_cache.v"

assign reset_pc = reset;
// if 
assign f_enable = ~(d_wait || a_wait || c_wait);

assign enable_inc = ~(f_wait || d_wait || a_wait || c_wait);


reg [31:0] memory [0:1023];

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
	.enable(enable_inc),
	.reset(reset),
	.out(f_pc)
);

reg f_nop_in = 1;
wire f_nop;
ff #(.BITS(1)) ff_f_nop (
	.in(f_nop_in),
	.clk(clk),
	.enable(f_enable),
	.reset(reset),
	.out(f_nop)
);

reg f_wait = 0;

reg hit = 0;

initial begin 
	// Load instructions into memory here or use an external file.
	$readmemb("memory/memory.bin", __mem_data);
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
		$display("reset");
        f_wait <= 0;
        imem_read <= 0;
        f_instr_input <= 32'bx; // Clear instruction register
		f_nop_in = 0;
    end else if (!f_wait) begin // Look into cache
		// $display("Forwarding to cache");
		#0.01
		iaddr <= pc;
		icache_read <= 1;
	end else if (imem_read) begin  // getting from mem currently
		if (imem_finished) begin // finished mem look
			// $display("Reading from memory finished");
            icache_write <= 1;
		end else begin // keep looking
			// $display("Reading from memory");
		end
	end else begin
		// $display("Else branch %d", imem_read);
		f_nop_in = 1;
		f_wait = 1;
	end
	
end
