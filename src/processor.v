module processor(
    input clk,
    input reset
);
    // Wires for inter-stage communication
    wire [31:0] pc, next_pc, instruction;
    wire [5:0] opcode;
    wire [4:0] rs, rt, rd;
    wire [15:0] immediate;
    wire [31:0] alu_result, memory_data;

    // Fetch Stage
    pc pc_inst(.clk(clk), .reset(reset), .enable(1'b1), .next_pc(next_pc), .current_pc(pc));
    instruction_memory imem(.address(pc), .instruction(instruction));

    // Decode Stage
    decode decode_inst(.instruction(instruction), .opcode(opcode), .rs(rs), .rt(rt), .rd(rd), .immediate(immediate));

    // ALU Stage
    alu alu_inst(.src1(rs), .src2(rt), .op(opcode[3:0]), .result(alu_result));

    // Memory Stage
    data_memory dmem(.clk(clk), .mem_write(opcode == 6'b101011), .mem_read(opcode == 6'b100011),
                     .address(alu_result), .write_data(rt), .read_data(memory_data));

endmodule

