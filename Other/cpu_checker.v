module cpu_checker(
    input clk,
    input reset,
    input [7:0] char,
    input [15:0] freq,
    output [1:0] format_type,
    output [3:0] error_code
);

reg [4:0] status = 0;
integer HexCount=0;
integer DecCount=0;
reg isRegister=1;

integer isTimeError=0;
integer isPcError=0;
integer isAddrError=0;
integer isGrfError=0;

reg [31:0] timeTemp;
reg [31:0] pcTemp;
reg [31:0] addrTemp;
reg [31:0] grfTemp;

reg [31:0] AX;
reg [31:0] BX;
reg [31:0] CX;


reg [3:0] timeErrorCode=4'b0001;
reg [3:0] pcErrorCode=4'b0010;
reg [3:0] addrErrorCode=4'b0100;
reg [3:0] grfErrorCode=4'b1000;



assign format_type = (status==14)?
    (isRegister?2'b01:2'b10):2'b00;

assign error_code = (status==14)?
    (isTimeError?timeErrorCode:0)
    |(isPcError?pcErrorCode:0)
    |(isAddrError?addrErrorCode:0)
    |(isGrfError?grfErrorCode:0):0;

wire isHex = ((char>="a"&&char<="f")||(char>="0"&&char<="9"))?1:0;
wire isDec = (char>8'b00101111&&char<8'b00111010)?1:0;
always @(posedge clk) begin

    if(reset==1)begin
        status<=0;
        HexCount=0;
        DecCount=0;
        isRegister=1;
        isTimeError=0;
        isPcError=0;
        isAddrError=0;
        isGrfError=0;
        timeTemp = 0;
        pcTemp = 0;
        addrTemp = 0;
        grfTemp = 0;
    end
    else begin
        case (status)
            5'd0:
            begin   
                isRegister<=1;
                if(char=="^")
                    status<=1;
                else status<=0;
            end

            5'd1:
            begin
                if(isDec==1)begin
                    status<=2;
                    DecCount<=1;

                    timeTemp <= char - "0";
                end
                else if(char=="^") status<=1;
                else status<=0;
            end

            5'd2:
            begin
                if(isDec==1)begin
                    DecCount<=DecCount+1;
                    
                    timeTemp <= (timeTemp <<< 3) + (timeTemp <<< 1) + (char - "0");

                    if(DecCount==4) status<=0;
                    else status<=2;
                end
                else if(char=="@")  status<=3;
                else if(char=="^")  status<=1;
                else status<=0;
            end

            5'd3:
            begin
                if(isHex==1) begin
                    HexCount<=1;

                    pcTemp <= (char>="a"&&char<="f")?(char - "a" + 10):(char - "0");

                    status<=4;
                end
                else if(char=="^")  status<=1;
                else status<=0;
            end
            5'd4:
            begin
                if(isHex==1) begin
                    HexCount<=HexCount+1;

                    pcTemp <= (pcTemp <<< 4)+ ((char>="a"&&char<="f")?(char - "a" + 10):(char - "0"));

                    if(HexCount==8) status<=0;
                    else status<=4;
                end
                else if(char==":" && HexCount==8)  status<=5;
                else if(char=="^")  status<=1;
                else status<=0;
            end
            5'd5:
            begin
                if(char==" ")  status<=6;
                else if(char=="$")  status<=7;
                else if(char==8'd42)begin
                    status<=15;
                    isRegister<=0;
                end 
                else if(char=="^")  status<=1;
                else status<=0;
            end
            5'd6:
            begin
                if(char=="$")  status<=7;
                else if(char==" ") status<=6;
                else if(char==8'd42) begin
                    status<=15;
                    isRegister<=0;
                end    
                else if(char=="^") status<=1;   
                else status<=0;
            end

            5'd7:
            begin
                if(isDec==1)begin
                    status<=8;

                    grfTemp <= char - "0";

                    DecCount<=1;
                end
                else if(char=="^") status<=1;   
                else status<=0;
            end

            5'd8:
            begin
                if(isDec==1)begin
                    DecCount<=DecCount+1;

                    grfTemp <= (grfTemp <<< 3) + (grfTemp <<< 1) + (char - "0");

                    if(DecCount==4) status<=0;
                    else status<=8;
                end
                else if(char=="<")  status<=10;
                else if(char==" ")  status<=9;
                else if(char=="^")  status<=1;
                else status<=0;
            end

            5'd9:
            begin
                if(char==" ")  status<=9;
                else if(char=="<") status<=10;
                else if(char=="^")  status<=1;
                else status<=0;
            end

            5'd10:
            begin
                if(char=="=")  status<=11;
                else if(char=="^")  status<=1;
                else status<=0;
            end

            5'd11:
            begin
                if(char==" ")  status<=12;
                else if(isHex) begin
                    HexCount<=1;


                    status<=13;
                end
                else if(char=="^")  status<=1;
                else status<=0;
            end

            5'd12:
            begin
                if(char==" ")  status<=12;
                else if(isHex) begin
                    HexCount<=1;


                    status<=13;
                end
                else if(char=="^")  status<=1;
                else status<=0;
            end

            5'd13:
            begin
                if(isHex==1) begin
                    HexCount<=HexCount+1;
                    if(HexCount==8) status<=0;
                    else status<=13;
                end
                else if(char=="#" && HexCount==8) begin
                    status<=14;

                    isTimeError <= (((timeTemp & ((freq >> 1) - 1))== 0)&& (timeTemp > 0))  ? 0 : 1;
                    isPcError <= ((pcTemp>= 32'h0000_3000 && pcTemp <= 32'h0000_4fff) && ( (3 & pcTemp) == 0) )? 0 : 1;
                    if(isRegister) begin
                        isGrfError <= (grfTemp >= 0 && grfTemp <= 31) ? 0 : 1;
                        isAddrError <= 0;
                    end
                    else begin
                        isAddrError <= ((addrTemp>= 32'h0000_0000 && addrTemp <= 32'h0000_2fff) && ( (3 & addrTemp) == 0)) ? 0 : 1;
                        isGrfError<= 0;
                    end
                end 
                else if(char=="^")  status<=1;
                else status<=0;
            end

            5'd14:
            begin
                if(char=="^")  status<=1;
                else status<=0;
            end

            5'd15:
            begin
                if(isHex) begin
                    HexCount<=1;
                    addrTemp <= (char>="a"&&char<="f")?(char - "a" + 10):(char - "0");

                    status<=16;
                end
                else if(char=="^")  status<=1;
                else status<=0;
            end
            5'd16:
            begin
                if(isHex) begin
                    HexCount<=HexCount+1;
                    addrTemp <= (addrTemp <<< 4) + ((char>="a"&&char<="f")?(char - "a" + 10):(char - "0"));
                    if(HexCount==8) status<=0;
                    else status<=16;
                end
                else if(char=="<" && HexCount==8)  status<=10;
                else if(char==" " && HexCount==8)  status<=9;
                else if(char=="^")  status<=1;
                else status<=0;
            end

        endcase
    end
end    



endmodule