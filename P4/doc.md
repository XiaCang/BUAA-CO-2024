# P4 Verilog CPU 设计文档

23373526 华家璇

## 一、设计草稿

本CPU设计实现了包括add,sub,ori,lui,lw,sw,beq,jal,jr,nop在内的命令，具体实现如下

### （一） 部件设计

#### 1. ALU  

##### 端口定义如下

| 端口名      | 方向 | 描述        |
| :-------:  | ---- | :----:     |
| A[31:0]    | I    | 输入数据A   |
| B[31:0]    | I    | 输入数据B   |
| ALUOp[2:0] | I    | 操作码      |
| result[31:0]| O    | 输出        |
| zero      | O    | 输出        |

##### 功能定义如下

| ALUOp  | O            |
| ------ | :----:       |
| 000    | A&B          |
| 001    | A|B          |
| 010    | A+B          |
| 011    | A-B          |

zero = (A == B) ? 1 : 0

```verilog
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
```

#### 2. GRF

##### 端口定义如下

| 端口名         | 方向 | 描述          |
| :-------:     | ---- | :----:         |
| clk           | I    | 时钟信号       |
| reset         | I    | 异步复位       |
| wenable       | I    | 写使能         |
| waddr[4:0]    | I    | 写地址         |
| raddr2[4:0]   | I    | 读地址1        |
| raddr1[4:0]   | I    | 读地址2        |
| wdata[31:0]   | I    | 写入数据       |
| rdata1[31:0]  | O    | ra1寄存器数据  |
| rdata2[31:0]  | O    | ra2寄存器数据  |
| PC[31:0]      | O    | pc寄存器数据   |

##### 功能定义如下

1. we信号为高电平时，写使能有效，在clk上升沿到来时写入数据WD到waddr对应的寄存器中
2. 始终输出ra1寄存器数据到d1，ra2寄存器数据到d2
3. 异步复位re有效时，将所有寄存器数据清零


```verilog
module grf(
    input clk,
    input reset,
    input [4:0] raddr1,
    input [4:0] raddr2,
    input [4:0] waddr,
    input [31:0] wdata,
    input wenable,
    input [31:0] PC,
    output [31:0] rdata1,
    output [31:0] rdata2

);

reg [31:0] regfile [31:0];

assign rdata1 = regfile[raddr1];
assign rdata2 = regfile[raddr2];
integer i;
always @(posedge clk) begin
    if(reset) begin
        i=0;
        for (i=0;i<32;i=i+1) begin
            regfile[i]=32'b0;
        end
    end
    else begin 
        if(wenable && waddr!=0) begin
            regfile[waddr]=wdata;
        end
    end
end
```

#### 3. EXT

##### 端口定义如下

| 端口名         | 方向 | 描述           |
| :-------:     | ---- | :----:        |
| imm16[15:0]   | I    | 输入的立即数    |  
| extOp[1:0]    | I    | 操作码         |
| out32[31:0]   | O    | 扩展后的立即数  |

##### 功能定义如下

| extOp  | out32                |
| ------ | :----:               |
| 00     | 无符号扩展imm16到32位  |
| 01     | 符号扩展imm16到32位    |
| 10     | 将imm16加载到高16位    |

```verilog

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
```

#### 4. DM

##### 端口定义如下

| 端口名         | 方向 | 描述                    |  
| :-------:     | ---- | :----:                 |
| clk           | I    |时钟信号                 |  
| reset         | I    |异步复位信号             |
| memWrite      | I    |写使能                  |
| pc[31:0]      | I    |pc地址                  |
| addr[31:0]    | I    |地址                    |
| writeData[31:0] | I    |写入数据                |
| readData[31:0]  | O    |读取的位于addr地址的数据 |

```verilog
module dm(
    input clk,
    input reset,
    input memWrite,
    input [31:0] pc,
    input [31:0] addr,
    input [31:0] writeData,
    output reg [31:0] readData
);

reg [31:0] mem [3071:0];

integer i=0;

always @(*) begin
    readData = mem[addr[13:2]];
end

always @(posedge clk) begin
    if (reset) begin
        for (i=0; i<3071; i=i+1) begin
            mem[i] <= 32'b0;
        end
    end
    else if (memWrite) begin
        mem[addr[13:2]] <= writeData;
    end
end

always @(posedge clk) begin
    if (memWrite & ~reset) begin
        $display("@%h: *%h <= %h", pc, addr, writeData);
    end
end

endmodule
```

#### 5. IM

##### 端口定义如下

| 端口名             | 方向 | 描述                    |  
| :-------:         | ---- | :----:                 |
| clk               | I    |时钟信号                 |
| reset             | I    |异步复位信号             |
| pc[31:0]          | O    |程序计数器               |
| next_pc[31:0]     | I    |下一条指令地址            |
| instr[31:0]       | O    |读出的指令               |

```verilog
module im(
    input clk,
    input reset,
    input [31:0] next_pc,
    output reg [31:0] instr,
    output reg [31:0] pc
);

reg [31:0] instruction [4095:0];
reg [31:0] _pc;
reg [31:0] _pc_to_mem;

initial begin
    $readmemh("code.txt", instruction);
end

always @(posedge clk) begin
    if (reset) begin
        _pc <= 32'h00003000;
        _pc_to_mem<= 0;
    end
    else begin
        _pc <= next_pc;
        _pc_to_mem <= next_pc - 12288;
    end
end


always @(*) begin
    pc = _pc;
    instr = instruction[_pc_to_mem[13:2]];
end

endmodule
```

#### 6. NEXTPC

##### 端口定义如下

| 端口名             | 方向 | 描述                    |  
| :-------:         | ---- | :----:                 |
| clk               | I    |时钟信号                 |
| reset             | I    |异步复位信号             |
| jump              | I    |是否发生无条件跳转        |
| jr                | I    |是否发生寄存器跳转        |
| zero              | I    |beq条件判断结果           |
| branch            | I    |是否可能发生条件跳转       |
| imm32[31:0]       | I    |比较结果                 |
| imm16[15:0]       | I    |跳转相对地址             |
| imm26[25:0]       | I    |跳转地址                 |
| pc[31:0]          | O    |程序计数器               |
| next_pc[31:0]     | O    |下一条指令地址            |


##### 功能定义如下

1.每次时钟上升沿，pc<- pc + 4，取出下一条指令
2.当branch有效，并且zero为1时，pc<- pc + 4 + sign_ext(imm16<<2)
3.当jump有效，pc<- {pc[31:28] , instrIndex,2'b0} 
4.当jr有效，pc<- imm32

```verilog
module nextpc(
    input [31:0] pc,
    input [15:0] imm16,
    input [25:0] imm26,
    input [31:0] imm32,
    input branch,
    input jump,
    input jr,
    input zero,
    output [31:0] next_pc
);
wire [31:0] _pc_plus_4;

wire [31:0] _extended_imm16;
wire [31:0] _branch_target;

wire [31:0] _extended_imm26;
wire [31:0] _jump_target;

wire [31:0] _jr_target;

wire [31:0] _mux1;
wire [31:0] _mux2;
wire [31:0] _mux3;

assign _pc_plus_4 = pc + 4;
assign _extended_imm16 = {{14{imm16[15]}}, imm16, 2'b00};
assign _branch_target = _extended_imm16 + _pc_plus_4; 

assign _extended_imm26 = {pc[31:28], imm26, 2'b00};
assign _jump_target = _extended_imm26;

assign _jr_target = imm32;
assign _mux1 = (branch && zero) ? _branch_target : _pc_plus_4;
assign _mux2 = (jump) ? _jump_target : _mux1;
assign _mux3 = (jr) ? _jr_target : _mux2;

assign next_pc = _mux3;


endmodule
```

#### 7. Controller

##### 端口定义如下

| 端口名             | 方向 | 描述                    |  
| :-------:         | ---- | :----:                 |
|instr[31:0]        | I    |指令                    |
|regDst[2:0]        | O    |寄存器选择               |
|aluSrc             | O    |ALU数据来源             |
|memToReg           | O    |存储器数据来源           |
|memWrite           | O    |存储器写使能             |
|branch             | O    |R型分支控制               |
|jump               | O    |J型分支控制               |
|jr                 | O    |Jr型分支控制             |
|regWrite           | O    |寄存器写使能             |
|aluOp[2:0]         | O    |ALU操作码                |
|extOp[2:0]         | O    |扩展操作码               |

##### 功能定义如下

1.  RegDst: 选择写入的寄存器， 0->rt, 1->rd, 2->ra
2.  ALUSrc: 选择ALU数据来源， 0->rt, 1->ext
3.  MemToReg: 选择GRF数据来源， 0->ALU, 1->DM
4.  MemWrite: 选择是否写入存储器
5.  Branch: 是否存在条件分支
6.  Jump: 是否存在无条件跳转
7.  RegWrite: 选择是否写入寄存器
8.  ALUOp: 选择ALU操作码 
9.  extOp: 选择扩展操作码
9.  jr: 是否发生寄存器跳转

##### 当前指令真值表如下

| instruction | RegDst | ALUSrc | MemToReg | MemWrite | Branch  | Jump    | RegWrite | ALUOp | extOp  |jr  |
| :----------:| :-----:| :-----:| :-------:| :-------:| :------:| :------:|:-------: |:-----:|:-----: | :-:|
| add         | 001    | 0      | 0        | 0        | 0       | 0       | 1        | 010   | 000    | 0  |
| sub         | 001    | 0      | 0        | 0        | 0       | 0       | 1        | 011   | 000    | 0  |
| ori         | 000    | 1      | 0        | 0        | 0       | 0       | 1        | 001   | 000    | 0  |
| beq         | 000    | 0      | 0        | 0        | 1       | 0       | 0        | 100   | 000    | 0  |
| lui         | 000    | 1      | 0        | 0        | 0       | 0       | 1        | 010   | 010    | 0  |
| lw          | 000    | 1      | 1        | 0        | 0       | 0       | 1        | 010   | 001    | 0  |
| sw          | 000    | 1      | 0        | 1        | 0       | 0       | 0        | 010   | 001    | 0  |
| jal         | 010    | 0      | 0        | 0        | 0       | 1       | 1        | 000   | 001    | 0  |
| jr          | 000    | 0      | 0        | 0        | 0       | 0       | 0        | 010   | 001    | 1  |
| jalr        | 001    | 0      | 0        | 0        | 0       | 0       | 1        | 010   | 001    | 1  |
| j           | 000    | 0      | 0        | 0        | 0       | 1       | 0        | 000   | 001    | 0  |

```verilog
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
```

#### 8. insExtract

##### 端口定义如下

| 端口名             | 方向 | 描述                   |  
| :-------:         | ---- | :----:                |
|instr[31:0]        | I    |指令                   |
|imm16[15:0]        | O    |指令中的立即数          |
|rs[4:0]            | O    |指令中rs地址            |
|rt[4:0]            | O    |指令中rt地址            |
|rd[4:0]            | O    |指令中rd地址            |
|imm26[25:0]        | O    |J型指令中的地址          |

```verilog
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
```

#### 9. alusrcmux

##### 端口定义如下

| 端口名             | 方向 | 描述                   |  
| :-------:         | ---- | :----:                |
|regnum[31:0]        | I    |来自GRF的数据                    |
|imm32[15:0]        | O    |指令中的立即数          |
|aluSrc            | O    |ALU数据来源            |
|out[31:0]        | O    |ALU数据                |

```verilog
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
```

#### 10. regmux

##### 端口定义如下

| 端口名             | 方向 | 描述                   |  
| :-------:         | ---- | :----:                |
|rt[4:0]        | I    |rt地址                 |
|rd[4:0]        | O    |rd地址          |
|regDst[2:0]            | O    |选择GRF写入的寄存器            |
|out[4:0]        | O    |GRF写入地址                |

```verilog
module regmux(
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

```

#### 11. regwritemux

##### 端口定义如下

| 端口名             | 方向 | 描述                   |  
| :-------:         | ---- | :----:                |
|aluout[31:0]        | I    |来自ALU的数据                 |
|memout[31:0]        | O    |来自存储器的数据          |
|pc[31:0]            | O    |程序计数器            |
|memToReg            | O    |是否将存储器数据写GRF         |
|jump                | O    |是否发生无条件跳转                |
|out[31:0]           | O    |寄存器写入数据                |

```verilog


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
```


### （二） CPU主体设计

#### 设计草案

实例化各个模块并连接，具体实现如下

```verilog
module mips(
    input clk,
    input reset
);

wire [31:0] s_instr;
wire [2:0] s_regDst;
wire s_aluSrc;
wire s_memToReg;
wire s_regWrite;
wire s_memWrite;
wire s_branch;
wire s_jump;
wire s_jr;
wire s_zero;
wire [2:0] s_extOp;
wire [2:0] s_aluOp;

wire [4:0] r_rs;
wire [4:0] r_rt;
wire [4:0] r_rd;
wire [15:0] r_imm16;
wire [25:0] r_imm26;

wire [4:0] t_regAddr;

wire [31:0] t_regData;
wire [31:0] t_rdata1;
wire [31:0] t_rdata2;
wire [31:0] _pc;
wire [31:0] _next_pc;
wire [31:0] _extended_imm16;
wire [31:0] _alu_B;
wire [31:0] _alu_res;
wire [31:0] _mem_res;

regmux m_regmux(
    .rt(r_rt),
    .rd(r_rd),
    .regDst(s_regDst),
    .out(t_regAddr)
);

grf m_grf(
    .clk(clk),
    .reset(reset),
    .raddr1(r_rs),
    .raddr2(r_rt),
    .waddr(t_regAddr),
    .wdata(t_regData),
    .wenable(s_regWrite),
    .PC(_pc),
    .rdata1(t_rdata1),
    .rdata2(t_rdata2)
);

insextractor m_insextractor(
    .instr(s_instr),
    .rs(r_rs),
    .rt(r_rt),
    .rd(r_rd),
    .imm16(r_imm16),
    .imm26(r_imm26)
);

controller m_controller(
    .instr(s_instr),
    .regDst(s_regDst),
    .aluSrc(s_aluSrc),
    .memToReg(s_memToReg),
    .regWrite(s_regWrite),
    .memWrite(s_memWrite),
    .branch(s_branch),
    .jump(s_jump),
    .jr(s_jr),
    .extOp(s_extOp),
    .aluOp(s_aluOp)
);

im m_im(
    .clk(clk),
    .reset(reset),
    .next_pc(_next_pc),
    .instr(s_instr),
    .pc(_pc)
);

ext m_ext(
    .imm16(r_imm16),
    .extOp(s_extOp),
    .out32(_extended_imm16)
);


nextpc m_nextpc(
    .pc(_pc),
    .imm16(r_imm16),
    .imm26(r_imm26),
    .imm32(t_regData),
    .branch(s_branch),
    .jump(s_jump),
    .jr(s_jr),
    .zero(s_zero),
    .next_pc(_next_pc)
);


alusrcmux m_alusrcmux(
    .regnum(t_rdata2),
    .imm32(_extended_imm16),
    .aluSrc(s_aluSrc),
    .out(_alu_B)
);

alu m_alu(
    .A(t_rdata1),
    .B(_alu_B),
    .ALUOp(s_aluOp),
    .result(_alu_res),
    .zero(s_zero)
);

dm m_dm(
    .clk(clk),
    .reset(reset),
    .memWrite(s_memWrite),
    .pc(_pc),
    .addr(_alu_res),
    .writeData(t_rdata2),
    .readData(_mem_res)
);

regwritemux m_regwritemux(
    .aluout(_alu_res),
    .memout(_mem_res),
    .pc(_pc),
    .memToReg(s_memToReg),
    .jump(s_jump),
    .out(t_regData)
);

endmodule
```


## 二、测试方案

利用py编写一个类似mars可以运行mips机器码的程序，并按照题目要求输出信息，与之与ise中输出的信息进行对比。
代码如下

```python
import subprocess
import re
import random

mem = [0] * 3072
reg = [0] * 32
pc = 12288
codes = []
info = []

def unsigend_add(a, b):
    if (a < 0):
        a = 4294967296 + a
    if (b < 0):
        b = 4294967296 + b
    return (a + b) & 0xffffffff

def unsigend_sub(a, b):
    res = a - b
    if (res < 0):
        res = 4294967296 + res
    return res & 0xffffffff

def sign_extend(binary_str):
    length = len(binary_str)
    sign_bit = binary_str[0]
    
    if sign_bit == '1':
        extended_str = '1' * (32 - length) + binary_str
    else:
        extended_str = '0' * (32 - length) + binary_str
    
    if sign_bit == '1':
        return int(extended_str, 2) - 4294967296
    else:
        return int(extended_str, 2)

def exportHex(src):
    subprocess.run("java -jar ./mars.jar a dump .text HexText code.txt " + src ,shell=True)
    file = open('./code.txt')
    return file.read()

def runR(code):
    global pc
    rs = int(code[6:11],2)
    rt = int(code[11:16],2)
    rd = int(code[16:21],2)
    func = code[26:32]
    tryassign = 0
    if func == '100000':
        tryassign = unsigend_add(reg[rs], reg[rt])
        if rd != 0:
            reg[rd] = tryassign
        info.append("@{0:08x}: ${1:2} <= {2:08x}".format(pc, rd, tryassign & 0xffffffff))
        pc = pc + 4
    elif func == '100010':
        tryassign = unsigend_sub(reg[rs], reg[rt])
        if rd != 0:
            reg[rd] = tryassign
        info.append("@{0:08x}: ${1:2} <= {2:08x}".format(pc, rd, tryassign & 0xffffffff))
        pc = pc + 4
    elif func == '001001':
        pc = reg[rs]
        tryassign = pc + 4
        if rd != 0:
            reg[rd] = tryassign
        info.append("@{0:08x}: ${1:2} <= {2:08x}".format(pc, rd, tryassign & 0xffffffff))
    elif func == '001000':
        pc = reg[rs]
        pc = pc + 4
    elif func == '000000':
        pc = pc + 4

def runI(code):
    global pc
    opcode = code[0:6]
    rs = int(code[6:11],2)
    rt = int(code[11:16],2)
    imm = int(code[16:32],2)
    imm_sign = sign_extend(code[16:32])
    tryassign = 0
    if (opcode == '000100'):
        if reg[rs] == reg[rt]:
            pc = pc + imm_sign * 4 + 4
        else:
            pc = pc + 4
    elif (opcode == '100011'):
        addr = reg[rs] + imm_sign
        addr = addr & 0x00003fff
        addr = addr // 4
        tryassign = mem[addr]
        if rt != 0:
            
            reg[rt] =  tryassign
        info.append("@{0:08x}: ${1:2} <= {2:08x}".format(pc, rt, tryassign & 0xffffffff))
        pc = pc + 4
    elif (opcode == '001101'):
        tryassign = reg[rs] | imm
        if rt != 0:
            reg[rt] = tryassign
        info.append("@{0:08x}: ${1:2} <= {2:08x}".format(pc, rt, tryassign & 0xffffffff))
        pc = pc + 4
    elif (opcode == '101011'):
        addr = reg[rs]+ imm_sign  
        addr = addr & 0x00003fff
        addr = addr // 4
        mem[addr] = reg[rt]
        info.append("@{0:08x}: *{1:08x} <= {2:08x}".format(pc, reg[rs]+imm_sign, reg[rt] & 0xffffffff))
        pc = pc + 4
    elif (opcode == '001111'):
        tryassign = imm << 16
        if rt != 0:
            reg[rt] =  tryassign
        info.append("@{0:08x}: ${1:2} <= {2:08x}".format(pc, rt, tryassign & 0xffffffff))
        pc = pc + 4
    else:
        return

    
def runJ(code):
    global pc
    opcode = code[0:6]
    imm = int(code[6:32],2)
    if (opcode == '000010'):
        pc = imm * 4
    elif (opcode == '000011'):
        reg[31] = pc + 4
        info.append("@{0:08x}: ${1:2} <= {2:08x}".format(pc, 31, reg[31] & 0xffffffff))
        pc = imm * 4
    else:
        return

def run(code : str): 
    code = bin(int(code, 16))[2:].zfill(32)
    if len(code) == 0:
        return
    if code[0:6] == '000000':
        runR(code)
    elif (code[0:6] == '000010' or code[0:6] == '000011'):
        runJ(code)
    else:
        runI(code)

def openfromfile():
    with open('code.txt', 'r') as f:
        for line in f:
            codes.append(line.strip())

openfromfile()
lastpc = 0
while (pc - 12288) // 4 < len(codes):
    lastpc = pc
    run(codes[(pc - 12288) // 4])
    if lastpc == pc:
        break

subprocess.run('iverilog -y ./src/ -o ./src/mips.vvp ./src/mips.v ./src/mipst.v')
res = subprocess.run('vvp ./src/mips.vvp',stdout=subprocess.PIPE,shell=True)
res = str(res.stdout).replace('\\n','\n').replace('\\t','\t').replace('\\r','\r')

reslist = re.findall(r'@[0-9a-z]{8}: [\$\*][0-9 a-zXZ]+ <= [0-9a-zXZ]{8}', res)

i=0
flag = 0
if (len(reslist) != len(info)):
    print('line count does not match , we expect {0} lines but got {1} lines'.format(len(info), len(reslist)))

while i < len(reslist) and i < len(info):
    if (reslist[i] != info[i]):
        print('miss match at line {0} : we expect {1} but got {2},at mips code {3}'.format(i, info[i], reslist[i], codes[(int(info[i][1:9],16) - 12288)//4]))
        flag = 1
    i = i + 1

if flag == 0:
    print('Accepted!')


```



## 三、思考题


1.addr从ALU的输出来的，示例DM共4096byte，addr 需要12位，但是由于是按字寻址，低2位没有用到，故为[11:2]

2.记录下指令对应的控制信号如何取值的代码示例如下,优势是可以更加清晰的知道每个指令对应的控制信号
```verilog

wire add = (opcode == 6'b000000 && funct == 6'b100000);
...

always @(*) begin
    if (add) begin
        aluOp = 3'b010;
        memWrite = 1;
        ...
    end
end
```

控制信号每种取值所对应的指令示例如下,优势是对控制信号修改更为简单

```verilog

wire add = (opcode == 6'b000000 && funct == 6'b100000);
...
memWrite = add | sub | ...;
...
```

3.同步复位在clk上升沿触发时才会取检测reset，clk优先级大于reset，异步复位仅检测reset的状态，reset优先级大于clk

4.addi操作为会在溢出的情况下产生SignalException，不考虑溢出的情况下都是将GPR[rs] + imm 结果直接赋给寄存器,两者相同