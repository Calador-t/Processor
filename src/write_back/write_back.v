
reg wb_enable = 1; // TODO make wire


wire [31:0] wb_pc;
ff #(.BITS(32)) ff_wb_pc (
    .in(a_pc),
    .clk(clk),
    .enable(wb_enable),
    .reset(reset),
    .out(wb_pc)
);


always @(posedge clk or posedge reset) begin
	if (reset == 0 && enable == 1) begin
		#0.3
        rgs_enable = a_w;
        rgs_in_a = a_r_d_a;
        rgs_in = a_res;
		
    end
end
