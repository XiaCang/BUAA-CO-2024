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
    output [2:0] aluOp,
    output [2:0] memByteen,
    output [1:0] cmpOp,
    output [2:0] mdop,
    output hlsel,
    output hlread,
    output hlwrite,
    output mdstart,
    output RI,
    output eret,
    output c0read,
    output c0write,
    output syscall
);

wire _R;
wire _add;
wire _addi;
wire _sub;
wire _lui;
wire _ori;
wire _or;
wire _andi;
wire _and;

wire _beq;
wire _bne;
wire _jr;
wire _jal;

wire _slt;
wire _sltu;


wire _lb;
wire _lh;
wire _lw;
wire _sb;
wire _sh;
wire _sw;

wire _mult;
wire _multu;
wire _div;
wire _divu;

wire _mfhi;
wire _mflo;
wire _mthi;
wire _mtlo;
wire _nop;

wire _eret;
wire _mfc0;
wire _mtc0;
wire _syscall;
assign _R = (instr[31:26] == 6'b000000);
assign _nop = ((instr[5:0] == 6'b000000) && _R);
assign _jr = ((instr[5:0] == 6'b001000) && _R);
assign _add = ((instr[5:0] == 6'b100000) && _R);
assign _sub = ((instr[5:0] == 6'b100010) && _R);
assign _and = ((instr[5:0] == 6'b100100) && _R);
assign _or = ((instr[5:0] == 6'b100101) && _R);
assign _slt = ((instr[5:0] == 6'b101010) && _R);
assign _sltu = ((instr[5:0] == 6'b101011) && _R);
assign _mult = ((instr[5:0] == 6'b011000) && _R);
assign _multu = ((instr[5:0] == 6'b011001) && _R);
assign _div = ((instr[5:0] == 6'b011010) && _R);
assign _divu = ((instr[5:0] == 6'b011011) && _R);
assign _mfhi = ((instr[5:0] == 6'b010000) && _R);
assign _mflo = ((instr[5:0] == 6'b010010) && _R);
assign _mthi = ((instr[5:0] == 6'b010001) && _R);
assign _mtlo = ((instr[5:0] == 6'b010011) && _R);
assign _addi = (instr[31:26] == 6'b001000);
assign _andi = (instr[31:26] == 6'b001100);
assign _lui = (instr[31:26] == 6'b001111);
assign _ori = (instr[31:26] == 6'b001101);
assign _lb = (instr[31:26] == 6'b100000);
assign _lh = (instr[31:26] == 6'b100001);
assign _lw = (instr[31:26] == 6'b100011);
assign _sb = (instr[31:26] == 6'b101000);
assign _sh = (instr[31:26] == 6'b101001);
assign _sw = (instr[31:26] == 6'b101011);
assign _beq = (instr[31:26] == 6'b000100);
assign _bne = (instr[31:26] == 6'b000101);
assign _jal = (instr[31:26] == 6'b000011);

assign _eret = (instr == 32'h42000018);
assign eret = _eret;

assign _mfc0 = (instr[31:26] == 6'b010000 && instr[25:21] == 5'b00000);
assign _mtc0 = (instr[31:26] == 6'b010000 && instr[25:21] == 5'b00100);
assign _syscall = (instr == 32'h0000000c);
assign syscall = _syscall;

assign c0read = _mfc0;
assign c0write = _mtc0;
// 000 rt
// 001 rd
// 010 ra
// 011 zero
assign regDst[2] = 0;
assign regDst[1] = _jal;
assign regDst[0] = _add | _sub | _and | _mfhi | _mflo | _or | _slt | _sltu ;

assign aluSrc = _ori | _lb | _lh | _lw | _sw | _lui | _addi | _andi | _sb | _sh;

assign memToReg = _lw | _lb | _lh;

assign regWrite = _add | _sub | _ori | _lui | _lw | _jal | _addi | _and | 
                    _andi | _lb | _lh | _mfhi | _mflo | _or | _slt | _sltu | _mfc0;

assign memWrite = _sw | _sb | _sh;

assign branch = _beq | _bne;

assign jump =  _jal;

assign jr = _jr;

// 000 无符号 
// 001 有符号
assign extOp[2] = 0;
assign extOp[1] = _lui;
assign extOp[0] = _lw | _lh | _lb | _sw | _sb | _sh | _addi;

// 000 &
// 001 |
// 010 +
// 011 -
// 100 < ? 1 : 0
// 101 < ? 1 : 0 signed
assign aluOp[2] = _slt | _sltu;
assign aluOp[1] = _sub | _add | _addi | _jr  | _lui | _sw | _sb | _sh | _lw | _lh | _lb  | _mfhi | _mflo;
assign aluOp[0] = _sub | _ori | _slt | _or;

// 000 word
// 001 ubyte
// 010 byte
// 011 uhalfword
// 100 halfword
assign memByteen[2] = _lh | _sh;
assign memByteen[1] = _lb | _sb;
assign memByteen[0] = 0;

// 00 =
// 01 !=
assign cmpOp[1] = 0;
assign cmpOp[0] = _bne;

// 000 mul
// 001 mulu
// 010 div
// 011 divu
assign mdop[2] = 0;
assign mdop[1] = _div | _divu;
assign mdop[0] = _divu | _multu;

//是否读取hi和lo
assign hlread = _mfhi | _mflo;
// 0 hi 1 lo
assign hlsel = _mflo | _mtlo;
assign hlwrite = _mthi | _mtlo;
assign mdstart = _div | _divu | _mult | _multu;

assign RI = !(_add | _sub | _and | _or | _slt | _sltu | _addi | _andi |
                 _ori | _lui | _lw | _lh | _lb | _sw | _sh | _sb | _jal | 
                 _mthi | _mtlo | _mfhi | _mflo | _mult | _multu | _div | _divu | 
                 _beq | _bne  | _jr | _nop | _eret | _mfc0 | _mtc0 | _syscall);
endmodule