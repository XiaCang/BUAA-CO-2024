module regdestmux(
    input [4:0] rt,
    input [4:0] rd,
    input [2:0] regDst,
    output reg [4:0] out
);

always @(*) begin
    case (regDst)
        3'b000: out = rt;
        3'b001: out = rd;
        3'b010: out = 5'b11111;
        default: out = 5'b00000;
    endcase 
end
endmodule
