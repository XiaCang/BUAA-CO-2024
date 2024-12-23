module CheckMemExcption(
    input [2:0] op,
    input [31:0] addr,
    input memWrite,
    input memtoreg,
    input aluOverflow,
    output reg adEL,
    output reg adES
);

reg notAligned;
reg Timer;
reg outOfRange;
reg editCountReg;
always @(*) begin
    // 地址溢出
    outOfRange = ~(addr <= 32'h2fff || 
                    (addr >= 32'h7f00 && addr <= 32'h7f0b) ||  
                    (addr >= 32'h7f10 && addr <= 32'h7f1b) ||  
                    (addr >= 32'h7f20 && addr <= 32'h7f23));  
    // 地址不对齐
    notAligned = (op == 3'b000 && (|(addr[1:0])) || 
                    (op == 3'b100 || op == 3'b011) && addr[0] );
    // lh lb sh sb 取寄存器
    Timer = (op != 3'b000) && 
            (addr >= 32'h7f00 && addr <= 32'h7f0b || addr >= 32'h7f10 && addr <= 32'h7f1b);
    // 编辑定时器Count寄存器
    editCountReg = (addr == 32'h7f08 || addr == 32'h7f18);

    adES = (aluOverflow ||outOfRange || notAligned || Timer || editCountReg) & memWrite;
    adEL = (aluOverflow || outOfRange || notAligned || Timer ) & memtoreg;
    
end


endmodule