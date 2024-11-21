`timescale 1ns/1ps

module fetch(
    input clk,
    input reset,
    input enable,
    output [31:0] instruction  // Register output for instruction
);
    wire [31:0] current_pc;

    // Instantiate the Program Counter (PC) module
    pc program_counter (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .pc(current_pc)
    );
    
    // Instantiate the Instruction Memory module
    instruction_memory imem (
        .address(current_pc),  // Connect the current PC to the address input
        .instruction(instruction) // Instruction fetched from memory
    );

    // Optional: Logic to use the instruction (for example, display it)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            $display("FETCH:  Instruction: %h, Current PC %h, RESET", instruction, current_pc);
            // Reset logic (if any)
        end else if (enable) begin
            $display("FETCH:  Instruction: %h, Current PC %h", instruction, current_pc);
        end
    end
endmodule

