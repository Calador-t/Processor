reg [31:0] sb_addresses [3:0];
reg [31:0] sb_data [3:0];
reg sb_valid [3:0];
reg [2:0] sb_head;
reg [2:0] sb_tail;
reg sb_store;
reg sb_drain;
reg sb_drain_next;
reg sb_done;

always @(posedge reset) begin
    if (reset) begin
        sb_head = 0;
        sb_tail = 0;
        sb_drain = 0;
        sb_store = 0;

        for (i = 0; i < 4; i = i + 1) begin
            sb_addresses[i] <= 'bx;
            sb_data[i] <= 'bx; 
            sb_valid[i] <= 1'b0;
        end
    end
end

task drain_sb;
begin
    if (sb_valid[sb_head]) begin
        $display("Training SB %d", sb_head);
        $display("");   
        $display("");
        $display("");
        $display("");
        $display("");
        $display("");
        $display("");
        $display("");
        $display("");
        $display("");
        $display("");
        $display("");
        $display("");
        $display("");
        $display("");
        $display("");
        $display("");
        $display("");
        $display("");
        $display("");
        $display("");
        $display("");
        dcache_data[sb_addresses[sb_head][5:4]][(sb_addresses[sb_head][3:0]* 8) +: 32] = sb_data[sb_head];
        sb_valid[sb_head] = 0;
        sb_head = (sb_head +1) %4;
        c_wait = 0;
        c_nop_in = 0;
    end 
end
endtask

function [2:0] check_sb;
	input [31:0] addr;
        integer j;
        check_sb = 5;
        for (i = 0; i < 4; i = i + 1) begin 
            j = (i + sb_head) % 4;
            if (sb_addresses[j] == addr && sb_valid[j]) begin
                check_sb = j;
            end
        end
endfunction 

task print_sb;
begin
    for (i = 0; i < 4; i = i + 1) begin
        $display("SB index %d, data %d, address %d, valid %d", i, sb_data[i], sb_addresses[i], sb_valid[i]);
    end
end
endtask