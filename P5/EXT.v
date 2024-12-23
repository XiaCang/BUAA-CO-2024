module ext(
    input [15:0] imm16,
    input [2:0] extOp,
    output reg [31:0] out32
);

always @(*) begin
    case (extOp)
        3'b000:  out32 = {16'b0, imm16};
        3'b001:  out32 = {{16{imm16[15]}}, imm16};
        3'b010:  out32 = {imm16, 16'b0};
        default:  out32 = {16'b0, imm16};
    endcase
end

endmodule