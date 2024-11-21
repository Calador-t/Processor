`timescale 1ns/1ps
module pc(
    input clk,
    input reset,
    input enable,
    output reg [31:0] pc
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'b0;
        else if (enable)
            pc <= pc + 1;
    end
endmodule

