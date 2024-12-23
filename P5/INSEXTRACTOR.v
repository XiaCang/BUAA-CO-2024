module insextractor(
    input [31:0] instr,
    output reg [4:0] rs,
    output reg [4:0] rt,
    output reg [4:0] rd,
    output reg [15:0] imm16,
    output reg [25:0] imm26
);

always @(*) begin
    rs = instr[25:21];
    rt = instr[20:16];
    rd = instr[15:11];
    imm16 = instr[15:0];
    imm26 = instr[25:0];
end

endmodule