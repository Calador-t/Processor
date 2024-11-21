`timescale 1ns/1ps

module test;
    reg clk;
    reg reset;
    reg enable;

//    reg [31:0] next_pc;

    wire [6:0] opcode;
    wire [6:0] opcode_alu;
    wire [31:0] instruction;
    wire [31:0] instruction_out;
    wire [31:0] instruction_out_decode;
    wire [31:0] instruction_in_alu;
    wire [31:0] data1;
    wire [31:0] data2;
    wire [31:0] data1_alu;
    wire [31:0] data2_alu;
    wire [31:0] result;

    fetch fetch_stage (
        .clk(clk),
        .reset(reset),
        .enable(enable),
	.instruction(instruction)
    );

    reg32 instruction_register (
        .in_data(instruction), // Input: fetched instruction
        .clk(clk),                      // Clock signal
        .enable(enable),                // Enable storing the instruction
        .reset(reset),                  // Reset signal
        .out_data(instruction_out)      // Output: instruction to pass to decode stage
    );

    decode decode_stage (
        .clk(clk),
        .reset(reset),
        .instruction(instruction_out),
        .opcode(opcode),
	.instruction_out(instruction_out_decode),
        .data1(data1),
        .data2(data2)
    );
   

    reg32 instruction_alu (
        .in_data(instruction_out_decode), // Input: fetched instruction
        .clk(clk),                      // Clock signal
        .enable(enable),                // Enable storing the instruction
        .reset(reset),                  // Reset signal
        .out_data(instruction_in_alu)      // Output: instruction to pass to decode stage
    );

    reg32 src1 (
        .in_data(data1), // Input: fetched instruction
        .clk(clk),                      // Clock signal
        .enable(enable),                // Enable storing the instruction
        .reset(reset),                  // Reset signal
        .out_data(data1_alu)      // Output: instruction to pass to decode stage
    );
    
    reg32 src2 (
        .in_data(data2), // Input: fetched instruction
        .clk(clk),                      // Clock signal
        .enable(enable),                // Enable storing the instruction
        .reset(reset),                  // Reset signal
        .out_data(data2_alu)      // Output: instruction to pass to decode stage
    );
    
//    reg32 opcode (
//        .in_data(opcode), // Input: fetched instruction
 //       .clk(clk),                      // Clock signal
 //       .enable(enable),                // Enable storing the instruction
 //       .reset(reset),                  // Reset signal
 //       .out_data(opcode_alu)      // Output: instruction to pass to decode stage
 //   );


   alu alu (
	.instruction(instruction_in_alu),
	.src1(data1_alu),
	.src2(data2_alu),
	.op(opcode),
	.result(result)
    );


//    reg32 alu_result (
//        .in_data(result), // Input: fetched instruction
//        .clk(clk),                      // Clock signal
//        .enable(enable),                // Enable storing the instruction
//        .reset(reset),                  // Reset signal
//        .out_data(result_out)      // Output: instruction to pass to decode stage
//    );

    // Clock generation
    always #5 clk = ~clk; // 10 ns period clock

    // Test stimulus
    initial begin
        clk = 0;
        reset = 1;
        enable = 0;

        // Apply reset
        #10 reset = 0;

        #10 enable = 1;

        // Wait some time
        #50 $finish;
    end
endmodule

