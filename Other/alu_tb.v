`timescale  1ns / 1ps

module tb_alu;

// alu Inputs
reg   [31:0]  A                            = 0 ;
reg   [31:0]  B                            = 0 ;
reg   [2:0]  ALUOp                         = 0 ;

// alu Outputs
wire  [31:0]  C                            ;



alu  u_alu (
    .A                       ( A      [31:0] ),
    .B                       ( B      [31:0] ),
    .ALUOp                   ( ALUOp  [2:0]  ),

    .C                       ( C      [31:0] )
);

initial
begin
    $dumpfile("alu.vcd");   
    $dumpvars();

    A = 32'b11000000000000000000000000010001;
    B = 32'b11000000000000000000000000010001;
    ALUOp = 3'b000;

    #10

    ALUOp = 3'b001;

    #10 

    ALUOp = 3'b010;

    #10

    ALUOp = 3'b011;

    #10
    B = 32'b00000000000000000000000000000001;

    ALUOp = 3'b100;

    #10

    ALUOp = 3'b101;

    #10


    $finish;
end

endmodule