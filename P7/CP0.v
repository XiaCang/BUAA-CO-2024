module CP0(
    input clk,
    input reset,
    input we,
    input [4:0] addr1, //read
    input [4:0] addr2, //write
    input [31:0] in,
    output [31:0] out,
    input [31:0] EPC,
    input BD,
    input [4:0] ExcCodeIn,
    input [5:0] HWInt, 
    input EXLClr,
    output [31:0] EPCOut,
    output Req

);


reg [31:0] _EPC;

// 31 BD 当前epc前一条指令是否为跳转
// 15:10  IP 每周期修改一次HWInt
// 6:2 ExcCode 异常码
reg [31:0] _Cause;

// 15:10 IM 控制六种外部中断
// 1 EXL 异常发生时置位
// 0 IE 中断使能
reg [31:0] _SR;

wire intrrupt;
wire exception;

assign intrrupt = (|(HWInt & _SR[15:10])) & _SR[0] & ~_SR[1];
assign exception = (ExcCodeIn != 0) & ~_SR[1];

assign Req = intrrupt | exception;
assign out = (addr1 == 5'd12) ? _SR :
            (addr1 == 5'd13) ? _Cause :
            (addr1 == 5'd14) ? _EPC : 32'b0;


always @(posedge clk) begin
    
    if (reset) begin
        _EPC <= 0;
        _SR <= 0;
        _Cause <= 0;
    end
    else begin
        _Cause[15:10] <= HWInt;
    

        if(EXLClr) begin
            _SR[1] <= 1'b0;
        end

        if (Req) begin
            _SR[1] <= 1'b1;
            _Cause[31] <= BD;
            _Cause[6:2] <= intrrupt ?  0 : ExcCodeIn;
            _EPC <= (BD) ? (EPC - 4) : EPC;
        end
        else begin 
            if (we) begin
                case (addr2)
                    5'd12 : _SR <= in;
                    5'd14 : _EPC <= in;
                    default : begin
                        _SR <= _SR;
                        _Cause <= _Cause;
                        _EPC <= _EPC;
                    end
                endcase
            end    
        end
    end
end

assign EPCOut = _EPC;

endmodule