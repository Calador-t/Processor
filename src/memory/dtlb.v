reg [31:0]  drm0; // PC of the instruction
reg [31:0]  drm1; // VA to be translated
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
        drm0 <= 0;
        drm1 <= 0;
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
    if (!f_nop_in) begin
        if (!rm4 ) begin
            hit <= 0;
            #0.01
            for (i = 0; i < 20; i = i + 1) begin 
                $display("daddr %h, paddr %h, want %h", dtlb_vpns[i], dtlb_ppns[i], dtlb_va);
                if (dtlb_vpns[i] == dtlb_va[31:12]) begin
                    $display("Hit!");
                    hit <= 1;
                    d_addr <= dtlb_ppns[i] + dtlb_va[11:0];
                end
            end
            #0.01

            if (hit) begin
                dcache_read <= 1;
                #0.1
                $display("dtlb HIT, addr at dtlb before %h, after %h", dtlb_va[31:12], d_addr);
            end else if (a_exception == 0) begin
                drm0 <= a_pc; // Save faulting PC
                drm1 <= dtlb_va; // Save faulting memory @
                c_exception_in <= 2;
                #0.01
                $display("dtlb MISS setting pc/rm0 to %d and addr to  %d", a_pc, dtlb_va);
            end
        end else begin 
            d_addr <= dtlb_va;
            dcache_read <= 1;
            #0.1
            $display("OFF addr at dtlb %h", d_addr);
        end
    end
end