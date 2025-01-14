reg signed [32:0]  drm0; // PC of the instruction
reg signed [32:0]  drm1; // VA to be translated
reg [31:0] dtlb_va;
reg dtlb_read;
reg hit;
reg dtlb_miss;
reg dtlb_wait;
reg page_walking_dtlb;

reg [31:0] dtlb_vpns [19:0];
reg [19:0] dtlb_ppns [19:0];
reg [19:0] dtlb_valids;
reg [2:0] dtlb_page_protections [19:0]; // R,W,RW,EX 
reg [5:0] dtlb_tail;

// reg [31:0] page_table_root_addr;

// 2 level page table. 2 pages per table.

always @(posedge reset) begin
    if (reset) begin
        drm0 <= -1;
        drm1 <= -1;
        page_table_root_addr <= 'h5000;
        dtlb_miss <= 0;
        dtlb_wait <= 1;
        dtlb_tail <= 0;
        page_walking_dtlb <= 0;

        for (i = 0; i < 20; i = i + 1) begin
            dtlb_vpns[i] <= 'bx;
            dtlb_ppns[i] <= 'bx; 
            dtlb_valids[i] <= 1'b0;
            dtlb_page_protections[i] <= 'b0;
        end
    end
end

always @(posedge dtlb_read) begin
    #0.2
    dtlb_read <= 0;
    
    if (!rm4 ) begin
        hit <= 0;
        #0.01
        for (i = 0; i < 20; i = i + 1) begin 
            // $display("vaddr %h, paddr %h, want %h, root %h, padding %h", dtlb_vpns[i], dtlb_ppns[i], dtlb_va, dtlb_va[31:12], dtlb_va[11:0]);
            if (dtlb_vpns[i] == dtlb_va[31:12] && dtlb_valids[i]) begin
                // $display("Hit! %d, %d", dtlb_vpns[i], dtlb_va[31:12]);
                hit <= 1;
                d_addr[31:12] <= dtlb_ppns[i];
                d_addr[11:0] <= dtlb_va[11:0];
            end
        end
        #0.01

        if (hit) begin
            dcache_read <= 1;
            #0.1
            $display("dtlb HIT, addr at dtlb before %h, after %h, should be %h", dtlb_va, d_addr, dtlb_va + 'h8000);
        end else if (a_exception == 0) begin
            $display("dtlb MISS %d %d",drm0, drm1);
            if (drm0 == -1 && drm1 == -1) begin
                drm0 <= a_pc; // Save faulting PC
                drm1 <= dtlb_va; // Save faulting memory @
                c_exception_in <= 2;
                #0.01
                $display("dtlb MISS: setting pc/rm0 to %d and addr to  %d", a_pc, dtlb_va);
            end
            
        end
    end else begin 
        d_addr <= dtlb_va;
        dcache_read <= 1;
        #0.1
        $display("OFF addr at dtlb %h", d_addr);
    end

end