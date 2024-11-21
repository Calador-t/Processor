module alu(
    input [31:0] instruction,
    input [31:0] src1,
    input [31:0] src2,
    input [6:0] op,
    output reg [31:0] result 
);

    always @(*) begin
        case (op)
            4'b0000: result = src1 + src2;   // ADD
            4'b0001: result = src1 - src2;   // SUB
            4'b0010: result = src1 * src2;   // MUL
            default: result = 0;
        endcase
	$display("ALU:    Instruction: %h, SRC1: %d, SRC2: %d, OP: %d, RESULT: %d", instruction, src1, src2, op, result);
    end
endmodule


//Each instruction is 32bits. TODOO:
//LDB 80(r1) ->r0  	// Load Byte; base register + offset
//LDW 80(r1) ->r0 	// Load Word; base register + offset
//STB r0 ->80(r1) 	// Store Byte; base register + offset
//STW r0 ->80(r1) 	// Store Word; base register + offset
//BEQ r1, offset 	// if r1==r2, PC=PC+offset
//JUMP r1, offset	// PC = r1 + offset
//
//OPCODES
//
