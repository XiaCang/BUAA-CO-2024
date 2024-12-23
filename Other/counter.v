module code(
    input Clk,
    input Reset,
    input Slt,
    input En,
    output [63:0] Output0,
    output [63:0] Output1
    );
	 
	 reg [63:0] reg0;
	 reg [63:0] reg1;
	 reg [63:0] tmp;
	 integer t=0;
	always @(posedge Clk)begin
		if(Reset)begin
			reg0<=0;
			reg1<=0;
			t=0;
		end
		else begin
			if(En)begin
				if(!Slt)
                begin
					tmp=reg0;
					reg0=tmp+1;
				end
				else
                begin
					t=t+1;
					if(t%4==0)
                    begin
						tmp=reg1;
						reg1=tmp+1;
					end
				end	
			end
		end
	end
	assign Output0=reg0;
	assign Output1=reg1;
endmodule