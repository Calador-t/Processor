always @(posedge clk or posedge reset) begin
    #0.2
    // $display("WB EXCEPTION %d", c_exception);

	if (reset == 0 && c_nop == 0) begin
        #0.2
        // $display("WB %h", c_swap_rm4);

        // if (c_swap_rm4) begin
        //     if (rm4) begin
        //         rm4 <= 0;
        //     end else begin
        //         rm4 <= 1;
        //     end
        //     #0.01
        //     $display("SUPERVISOR MODE %d", rm4);
        // end else 
        if (c_exception == 1) begin  // iTLB MISS
            pc_in <= 'h2000; // Jump to h2000
            pc_jump <= 1;
            rm4 <= 1; // Switch on supervisor mode
            rm0 <= irm0;
            rm1 <= irm1;
            f_nop_in <= 1;
            d_nop_in <= 1;
            // a_nop_in <= 1;
            // c_nop_in <= 1;
            $display("ITLB EXCEPTION, JUMPING TO 2K!");
            $display("%d", c_exception);
            $display("");
            $display("");
            $display("");
            $display("");
        end else if (c_exception == 2) begin // dTLB MISS
            pc_in <= 'h2010; // Jump to h2000
            pc_jump <= 1;
            rm4 <= 1; // Switch on supervisor mode
            f_nop_in <= 1;
            d_nop_in <= 1;
            a_nop_in <= 1;
            c_nop_in <= 1;
            rm0 <= drm0;
            rm1 <= drm1;
            $display("dTLB EXCEPTION, JUMPING TO 2K!");
            $display("%d", c_exception);
            $display("");
            $display("");
            $display("");
            $display("");
        end else if (c_w == 1) begin
            if (c_r_d_a < 32) begin
                rgs_out[c_r_d_a] = c_res;
            end
            #0.01
            for(i = 0; i < 32; i += 1) begin
				$display("Reg index %d = %d", i, rgs_out[i]);
				// #0.00001 $display("rg ini: %d", rgs_out[i]);
			end
            // #0.001 $display("    Wb: r[%0d] = %0d", c_r_d_a, rgs_out[c_res]);
        end
    end
end