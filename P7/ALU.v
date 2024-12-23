module alu(
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALUOp,
    output reg [31:0] result,
    output reg Overflow
);

reg carry;

always@(*)begin
    case(ALUOp)
        3'b000:begin
            result = A & B;
        end
        3'b001:begin
            result = A | B;
        end
        3'b010:begin
            {carry, result} = {A[31], A} + {B[31], B};
        end
        3'b011:begin
            {carry, result} = {A[31], A} - {B[31], B};
        end
        3'b100:begin
            result = A < B ? 32'b1 : 0;
        end
        3'b101:begin
            result = $signed(A) < $signed(B) ? 32'b1 : 0;
        end
        default : begin
            result = result;
        end
    endcase

    Overflow = (carry != result[31] && (ALUOp == 3'b010 || ALUOp == 3'b011)) ? 1 : 0;
end
endmodule