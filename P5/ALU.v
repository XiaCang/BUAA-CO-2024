module alu(
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALUOp,
    output reg [31:0] result,
    output reg zero
);

always@(*)begin
    zero = (A == B) ? 1 : 0;
    case(ALUOp)
        3'b000:begin
            result = A & B;
        end
        3'b001:begin
            result = A | B;
        end
        3'b010:begin
            result = A + B;
        end
        3'b011:begin
            result = A - B;
        end
        default : begin
            result = result;
        end
    endcase
end
endmodule