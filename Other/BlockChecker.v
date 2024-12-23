module BlockChecker(
    input clk,
    input reset,
    input [7:0] in,
    output result
);

reg [7:0] alpha;
reg alreadyInvalid=0;
reg [5:0] status;
reg [31:0] beginnum=0;
always @(reset) begin
    status <= 0;
    beginnum <= 0;
    alreadyInvalid <= 0;
    alpha <= 0;
end

always @(posedge clk) begin
    alpha = (in >= "A" && in <= "Z")?in + 32:in;

    if(alreadyInvalid == 0) 
        alreadyInvalid = ($signed(beginnum) < $signed(0))?1:0;
    else alreadyInvalid = 1;

    if(reset) begin
        status <= 0;
        beginnum <= 0;
        alreadyInvalid <= 0;
        alpha <= 0;
    end
    else begin
    case (status)
        0: begin
            if(alpha == " ")begin
                status <= 0;
            end
            else if(alpha == "b") begin
                status <= 5;
            end
            else if(alpha == "e") begin
                status <= 2;
            end
            else status <= 1;
        end
        1: begin
            if(alpha == " ") status <= 0;
            else status <= 1;
        end
        2: begin
            if (alpha == "n") begin
                status <= 3;
            end 
            else if(alpha == " ")begin
                status <= 0;
            end
            else begin
                status <= 1;
            end
        end
        3: begin
            if (alpha == "d") begin
                status <= 4;
                    beginnum <= beginnum - 1;
            end
            else if(alpha == " ")begin
                status <= 0;
            end
            else begin
                status <= 1;
            end
        end
        4: begin
            if(alpha == " ") begin
                status <= 0;
            end
            else begin
                if(alreadyInvalid == 0 || $signed(beginnum) == $signed(-1) )begin
                    beginnum <= beginnum + 1;
                    alreadyInvalid <= 0;
                end
                else beginnum <= beginnum;
                status <= 1;
            end
        end
        5: begin
            if(alpha == "e") begin
                status <= 6;
            end
            else if(alpha == " ")begin
                status <= 0;
            end
            else begin
                status <= 1;
            end
        end
        6: begin
            if(alpha == "g") begin
                status <= 7;
            end
            else if(alpha == " ")begin
                status <= 0;
            end
            else begin
                status <= 1;
            end
        end
        7:begin
            if(alpha == "i") begin
                status <= 8;
            end
            else if(alpha == " ")begin
                status <= 0;
            end
            else begin
                status <= 1;
            end
        end
        8:begin
            if(alpha == "n") begin
                status <= 9;
                if(alreadyInvalid == 0)
                    beginnum <= beginnum + 1;
                else beginnum <= beginnum;
            end
            else if(alpha == " ")begin
                status <= 0;
            end
            else begin
                status <= 1;
            end
        end
        9:begin
            if(alpha == " ")begin
                status <= 0;
            end
            else begin
                status <= 1;
                if(alreadyInvalid == 0 )
                    beginnum <= beginnum - 1;
                else beginnum <= beginnum;
            end
        end
    endcase
    end
end

assign result = (beginnum == 0&& alreadyInvalid ==0 || reset == 1)?1:0;

endmodule