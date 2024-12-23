module alu(
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALUOp,
    output [31:0] C
);

reg [31:0] R;

always @(*) begin
    case (ALUOp)
        0: R = A + B;
        1: R = A - B;
        2: R = A & B;
        3: R = A | B;
        4: R = A >> B;
        5: R = $signed(A) >>> B;
        6: R = (A > B) ? 1 : 0;
        7: R = ($signed(A) > $signed(B)) ? 1 : 0;
    endcase
end

assign C = R;

endmodule