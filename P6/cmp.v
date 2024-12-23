module cmp(
    input [31:0] A,
    input [31:0] B,
    input [1:0] cmpOp,
    output reg zero
);

always @(*) begin
    case(cmpOp)
        2'b00: zero = (A == B) ? 1 : 0;
        2'b01: zero = (A == B) ? 0 : 1;
        default: zero = 1'b0;
    endcase
end

endmodule