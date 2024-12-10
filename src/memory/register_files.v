// module register_file(
//     input [4:0] address,
//     output [31:0] data
// );
//     reg [31:0] memory [0:23]; // Example memory size

//     initial begin
//         // Load instructions into memory here or use an external file.
//         $readmemb("memory/registers.bin", memory);
//     end

//     assign data = memory[address]; // Example address truncation
// endmodule

