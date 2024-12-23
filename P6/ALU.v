module alu(
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALUOp,
    output reg [31:0] result
);

always@(*)begin
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
end
endmodule