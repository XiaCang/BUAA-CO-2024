module alusrcmux(
    input [31:0] regnum,
    input [31:0] imm32,
    input aluSrc,
    output reg [31:0] out
);

always @(*) begin
    if(aluSrc) begin
        out = imm32;
    end
    else begin
        out = regnum;
    end
end
endmodule