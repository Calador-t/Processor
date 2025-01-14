reg signed [32:0] irm0; // PC of the instruction
reg signed [32:0] irm1; // VA to be translated
reg [31:0] itlb_va;
reg itlb_read;
reg itlb_hit;
reg itlb_miss;
reg itlb_wait;
reg page_walking_itlb;

reg [31:0] itlb_vpns [19:0];
reg [19:0] itlb_ppns [19:0];
reg [19:0] itlb_valids;
reg [2:0] itlb_page_protections [19:0]; // R,W,RW,EX 
reg [5:0] itlb_tail;

reg [31:0] page_table_root_addr;

// 2 level page table. 2 pages per table.

always @(posedge reset) begin
    if (reset) begin
        irm0 <= -1;
        irm1 <= -1;
        page_table_root_addr <= 'h5000;
        itlb_miss <= 0;
        itlb_wait <= 1;
        itlb_tail <= 0;
        page_walking_itlb <= 0;

        for (i = 0; i < 20; i = i + 1) begin
            itlb_vpns[i] <= 'bx;
            itlb_ppns[i] <= 'bx; 
            itlb_valids[i] <= 1'b0;
            itlb_page_protections[i] <= 'b0;
        end
    end
end

always @(posedge itlb_read) begin
    #0.3
    itlb_read <= 0;
    // $display("Itlb here");
    if (!f_nop_in) begin
        // $display("Itlb here2");
        if (!rm4 ) begin
            // $display("Itlb here3");
            itlb_hit <= 0;
            #0.01
            for (i = 0; i < 20; i = i + 1) begin 
                // $display("iaddr %h, paddr %h, want %h", itlb_vpns[i], itlb_ppns[i], itlb_va);
                // $display("%h", itlb_vpns[i] - itlb_va[31:12]==0);
                if (itlb_vpns[i] - itlb_va[31:12] == 0) begin
                    itlb_hit <= 1;
                    iaddr[31:12] <= itlb_ppns[i] ;
                    iaddr[11:0]   = itlb_va[11:0];
                end
            end
            #0.01

            if (itlb_hit) begin
                icache_read <= 1;
                // #0.1
                // $display("ITLB HIT, addr at itlb before %h, after %h", itlb_va, iaddr);
            end else begin
                // $display("ITLB MISS");
                if (f_exception_in == 0 && irm1 == -1 && irm0 == -1) begin
                    irm0 <= pc; // Save faulting PC
                    irm1 <= pc; // Save faulting memory @
                    f_exception_in <= 1;
                end 
                // else begin
                    // $display("Already exception in iTLB, we will be coming back");
                // end
            end
        end else begin 
            iaddr <= itlb_va;
            icache_read <= 1;
            itlb_read <= 0;
            // #0.1
            // $display("OFF addr at itlb %h", iaddr);
        end
    end
end