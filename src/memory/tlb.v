// Doing just 20 entries for test rn
reg [31:0] vpn_table [19:0]; // TLB VPN entries
reg [19:0] ppn_table [19:0]; // TLB PPN entries
reg [19:0] valid_bits;       // Valid bit for each entry

integer i;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        valid_bits <= 0;
        for (i = 0; i < 20; i = i + 1) begin
            vpn_table[i] <= (i << 12);           // VA (Virtual Address) as VPN (Virtual Page Number), shifted to affect [31:12]
            ppn_table[i] <= (i << 12) + 32'h8000; // PA = VA + 0x8000
            valid_bits[i] <= 1'b1;                // Mark these entries as valid
        end
    end
end

always @(*) begin
    hit = 0;
    ppn = 0;
    for (i = 0; i < TLB_ENTRIES; i = i + 1) begin
        if (valid_bits[i] && vpn_table[i] == vpn) begin
            hit = 1;
            ppn = ppn_table[i];
        end
    end
end