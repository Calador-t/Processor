`timescale 1ns/1ps

module decode(
    input clk,
    input reset,
    input [31:0] instruction,      // Fetched instruction
    output reg [31:0] instruction_out,
    output [6:0] opcode,
    output [31:0] data1,      // Data from source register 1
    output [31:0] data2       // Data from source register 2
);
    wire [4:0] src1, src2;          // Source and destination registers

    // Decode the instruction
    assign opcode = instruction[31:25];
    assign src1 = instruction[19:15];
    assign src2 = instruction[14:10];
    // Instantiate the register file
    register_file reg_file (
        .address(src1),
        .data(data1)
    );

    register_file reg_file2 (
        .address(src2),
        .data(data2)
    );


    // Display decode output for debugging
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            $display("DECODE: Instruction: %h, SRC1: %d, SRC2: %d, RESET", instruction, src1, src2);
        end else begin
    	    instruction_out <= instruction;
            $display("DECODE: Instruction: %h, SRC1: %d, SRC2: %d", instruction, src1, src2);
//            $display("Read Data1: %h, Read Data2: %h", data1, data2);
        end
    end
endmodule

