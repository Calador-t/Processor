always @(posedge clk or posedge reset) begin
    #0.1
    if (~reset && m5_nop == 0 && ~(m5_pc === 32'bx)) begin
        //$display("!!!!!write rob mul: pc %d, tail %d", a_pc, m5_pc === 32'bx);
        
        write_to_rob(
            m5_tail,
            1,
            0, // TODO handle exceptions
            m5_res,
            m5_r_d_a,
            m5_pc,
            0,
            0,
            0,
            0);
    end
end
