

reg [31:0] in_pc = 0;
wire [31:0] pc;
reg pc_enable = 1;

reg32 pcReg (
	.in_data(in_pc),
	.clk(clk),
	.enable(pc_enable),
	.reset(reset),
	.out_data(pc)
);

always @(posedge clk) begin
	#0.1;
	
	in_pc <= pc + 1;
end
