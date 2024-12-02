always @(posedge clk or posedge reset) begin
	if (reset == 0) begin
        #0.3
        if (c_w == 1 && c_nop == 0) begin
            rgs_out[c_r_d_a] = c_res;
            #0.001 $display("    Wb: r[%0d] = %0d", c_r_d_a, rgs_out[c_r_d_a]);
        end
    end
end
