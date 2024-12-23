module cpu_checker(
    input clk,
    input reset,
    input [7:0] char,
    output [1:0] format_type
);

reg [4:0] status = 0;
integer HexCount=0;
integer DecCount=0;
reg isRegister=1;


assign format_type = (status==14)?
    (isRegister?2'b01:2'b10):2'b00;

wire isHex = ((char>="a"&&char<="f")||(char>="0"&&char<="9"))?1:0;
wire isDec = (char>8'b00101111&&char<8'b00111010)?1:0;
always @(posedge clk) begin

    if(reset==1)begin
        status<=0;
        HexCount=0;
        DecCount=0;
        isRegister=1;
    end
    else begin
        case (status)
            5'd0:
            begin   
                if(char=="^")
                    status<=1;
                else status<=0;
            end
            5'd1:
            begin
                if(isDec==1)begin
                    status<=2;
                    DecCount<=1;
                end
                else if(char=="^") status<=1;
                else status<=0;
            end

            5'd2:
            begin
                if(isDec==1)begin
                    DecCount<=DecCount+1;
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
                    status<=4;
                end
                else if(char=="^")  status<=1;
                else status<=0;
            end
            5'd4:
            begin
                if(isHex==1) begin
                    HexCount<=HexCount+1;


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
                    DecCount<=1;
                end
                else if(char=="^") status<=1;   
                else status<=0;
            end

            5'd8:
            begin
                if(isDec==1)begin
                    DecCount<=DecCount+1;
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
                    status<=16;
                end
                else if(char=="^")  status<=1;
                else status<=0;
            end
            5'd16:
            begin
                if(isHex) begin
                    HexCount<=HexCount+1;
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