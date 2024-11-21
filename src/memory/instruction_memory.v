module instruction_memory(
    input [31:0] address,
    output [31:0] instruction
);
    reg [31:0] memory [0:23]; // Example memory size

    initial begin
        // Load instructions into memory here or use an external file.
        $readmemb("memory/instructions.bin", memory);
    end

    assign instruction = memory[address[7:0]]; // Example address truncation
endmodule

