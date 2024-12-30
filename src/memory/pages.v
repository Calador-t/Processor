// Doing just 20 entries for test rn
reg [31:0] vpn_table [19:0];
reg [19:0] ppn_table [19:0];
reg [19:0] valid_bits;
reg [2:0] page_protections [19:0]; // R,W,RW,EX 

reg lookup;
reg [19:0] ppn;
reg [19:0] page_table_addr
integer i;

always @(posedge reset) begin
    if (reset) begin
        valid_bits <= 0;
        lookup <= 0;
        ppn <= 0;

        for (i = 0; i < 20; i = i + 1) begin
            vpn_table[i] <= (i << 12);           // VA
            ppn_table[i] <= (i << 12) + 32'h8000; // PA = VA + 0x8000
            valid_bits[i] <= 1'b1;
            page_protections[i] <= 'b0;
            $display("%d vpn %d ppn %d", i, vpn_table[i], ppn_table[i]);
        end
    end
end

always @(posedge lookup) begin
    for (i = 0; i < 20; i = i + 1) begin
        if (valid_bits[i] && vpn_table[i] == tr1) begin
            ppn <= ppn_table[i];
        end
    end
    lookup <= 0;
end 