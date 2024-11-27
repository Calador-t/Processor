
reg [31:0] rgs_out [31:0];
reg [31:0] rgs_in; // Only writen to one register per cycle => on wire enough.
reg [4:0] rgs_in_a;
reg rgs_enable = 0;
integer i;

	always @(posedge clk or posedge reset) begin
		if (reset) begin
			for(i = 0; i < 32; i += 1) begin
			
				rgs_out[i] = i;//32'b0; TODO rm index asignment just for testing
				#0.00001 $display("rg ini: %d", rgs_out[i]);
			end
		end
		else if (rgs_enable) begin // Should reg number i be writen to?
				rgs_out[rgs_in_a] = rgs_in;
				//#0.1 $display("    WR %d: %d", rgs_in_a, rgs_out[rgs_in_a]);
		end
	end
