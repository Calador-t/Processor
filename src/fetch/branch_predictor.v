// direct maped Cache
reg [31:0] bp_pc [0:7];
reg bp_jump [0:7];
reg [31:0] bp_target [0:7];
integer i_bp;
always @(posedge reset) begin
    if (reset) begin
        $display("Reset BP");
        for(i_bp = 0; i_bp < 8; i_bp += 1) begin
            bp_pc[i_bp] <= 32'bx;
        end
    end
end

function [31:0] predict_pc;
    input [31:0] in_pc;
    //$display("!!! Branch Predict %b, %b", in_pc, in_pc[4:2]);
    // Check if has a prediction for the correct pc
    if (bp_pc[in_pc[4:2]] == in_pc) begin
        if (bp_jump[in_pc[4:2]] == 1) begin
            // jump done last time predict
            predict_pc = bp_target[in_pc[4:2]];
        end else begin
            // no jump done last time, do nothing
            predict_pc = 32'bx;
        end
    end else begin  
        // No prediction for this pc
        predict_pc = 32'bx;
    end
    
    
endfunction
function set_prediction;
    input [31:0] in_pc;
    input [31:0] target;
    input jump;
    // Check if has a prediction
    bp_pc[in_pc[4:2]] = in_pc;
    bp_jump[in_pc[4:2]] = jump;
    bp_target[in_pc[4:2]] = target;
    if (jump == 0) begin
            $display("  [%0d] %h -> no jump", i_bp,  bp_pc[in_pc[4:2]]);
        end else begin
            $display("  [%0d] %h -> %h", i_bp,  bp_pc[in_pc[4:2]], bp_target[in_pc[4:2]]);
        end
endfunction

task print_bp;
    $display();
    $display();
    $display();
    $display();
    $display("bp_pc: ");
    for(i_bp = 0; i_bp < 8; i_bp += 1) begin
        if (bp_jump[i_bp] == 0) begin
            $display("  [%0d] %h -> no jump", i_bp,  bp_pc[i_bp]);
        end else begin
            $display("  [%0d] %h -> %h", i_bp,  bp_pc[i_bp], bp_target[i_bp]);
        end
    end
endtask