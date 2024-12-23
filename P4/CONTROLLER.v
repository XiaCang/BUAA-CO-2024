module controller(
    input [31:0] instr,
    output [2:0] regDst,
    output aluSrc,
    output memToReg,
    output regWrite,
    output memWrite,
    output branch,
    output jump,
    output jr,
    output [2:0] extOp,
    output [2:0] aluOp
);

wire _R;
wire _add;
wire _sub;
wire _lui;
wire _ori;
wire _lw;
wire _sw;
wire _beq;
wire _j;
wire _jr;
wire _jal;
wire _jalr;

assign _R = (instr[31:26] == 6'b000000);

assign _jr = ((instr[5:0] == 6'b001000) && _R);
assign _jalr = ((instr[5:0] == 6'b001001) && _R);
assign _add = ((instr[5:0] == 6'b100000) && _R);
assign _sub = ((instr[5:0] == 6'b100010) && _R);

assign _lui = (instr[31:26] == 6'b001111);
assign _ori = (instr[31:26] == 6'b001101);
assign _lw = (instr[31:26] == 6'b100011);
assign _sw = (instr[31:26] == 6'b101011);
assign _beq = (instr[31:26] == 6'b000100);
assign _j = (instr[31:26] == 6'b000010);
assign _jal = (instr[31:26] == 6'b000011);



assign regDst[2] = 0;
assign regDst[1] = _jal;
assign regDst[0] = _add | _sub | _jalr;

assign aluSrc = _ori | _lw | _sw | _lui;

assign memToReg = _lw;

assign regWrite = _add | _sub | _ori | _lui | _lw | _jal | _jalr;

assign memWrite = _sw;

assign branch = _beq;

assign jump = _j | _jal;

assign jr = _jr | _jalr;

assign extOp[2] = 0;
assign extOp[1] = _lui;
assign extOp[0] = _lw | _sw;

assign aluOp[2] = 0;
assign aluOp[1] = _sub | _add | _jr | _jalr | _lui | _sw | _lw;
assign aluOp[0] = _sub | _ori;


endmodule