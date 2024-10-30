`include "clock.v"
`include "reg32.v"
`include "alu.v"

module processor_tb;

// Declare the clock signal
wire clk;

// Instantiate the clock generator
clock #(.PERIOD(2)) clk_gen (
	.clk(clk)
);



reg reset = 0;
reg enable = 1;
// ALU and register signals
reg [31:0] inData1, inData2;       // ALU inputs before loading into reg32
reg [3:0] op;                      // ALU operation code
wire [31:0] src1, src2;      // Outputs of reg32 modules, inputs to ALU
wire [31:0] aluResult;             // ALU output
wire [31:0] finalResult;           // Output of reg32 for the ALU result

// Instantiate reg32 modules for ALU inputs and output
reg32 reg1 (
    .inData(inData1),
    .clk(clk),
    .enable(enable),
    .reset(reset),
    .outData(src1)
);

reg32 reg2 (
    .inData(inData2),
    .clk(clk),
    .enable(enable),
    .reset(reset),
    .outData(src2)
);

reg32 resultReg (
    .inData(aluResult),
    .clk(clk),
    .enable(enable),
    .reset(reset),
    .outData(finalResult)
);

// Instantiate the ALU, using reg32 outputs as inputs
alu alu_inst (
    .src1(src1),
    .src2(src2),
    .op(op),
    .result(aluResult)
);



initial begin
    $dumpfile("computation.vcd");
    $dumpvars(0, processor_tb);
    
    // Display header
    $display("Testing ALU Operations with reg32");
    $monitor("Time=%0t | src1=%d | src2=%d | op=%b | aluResult=%d | finalResult=%d",
              $time, src1, src2, op, aluResult, finalResult);

    //ADD
    $display("Adding");
    inData1 = 10;
    inData2 = 5;
    op = 4'b0000; // ADD operation
    #4; // Wait for registers to latch inputs
    if (finalResult !== 15) $display("ADD failed: Expected 15, got %d", finalResult);
    
    
    //SUB
    $display("Subtracting");
    inData1 = 20;
    inData2 = 10;
    op = 4'b0001; // SUB operation
    #4;
    if (finalResult !== 10) $display("SUB failed: Expected 15, got %d", finalResult);

    //MUL
    $display("Multiplying");
    inData1 = 5;
    inData2 = 6;
    op = 4'b0010; // MUL operation
    #4;
    if (finalResult !== 30) $display("MUL failed: Expected 12, got %d", finalResult);

    #2 $finish;
end

endmodule
