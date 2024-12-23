

module regwritemux(
    input [31:0] aluout,
    input [31:0] memout,
    input [31:0] pc,
    input memToReg,
    input jump,
    output reg [31:0] out
);

reg [31:0] _mux1;

always @(*) begin
    _mux1 = memToReg ? memout : aluout;
    out = jump ? (pc + 4) : _mux1;
end


endmodule