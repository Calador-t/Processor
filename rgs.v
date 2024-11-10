
reg [31:0] out_rgs [31:0];
reg [31:0] in_rgs; // Only writen to one register per cycle => on wire enough.
reg rgs_enable [31:0];
integer i;

	always @(posedge clk or posedge reset) begin
		for(i = 0; i < 32; i += 1) begin
			if (reset) begin
				out_rgs[i] = 32'b0;
			end
			else if (rgs_enable[i]) begin// Should reg number i be writen to?
				out_rgs[i] = in_rgs;
				$display("    WR %d: %d", i, out_rgs[i]);
			end
			//$display("    Reg %d: %d", i, out_rgs[i]);
		end
	end 

