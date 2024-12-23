module hazardcontrol(
    input [4:0] rsD,
    input [4:0] rtD,
    input [4:0] rsE,
    input [4:0] rtE,
    input [4:0] raE,
    input [4:0] raM,
    input [4:0] raW,
    input branchD,
    input jrD,
    input zero,
    input jumpD,
    input jumpM,
    input regWriteE,
    input regWriteM,
    input regWriteW,
    input memToRegE,
    input memToRegM,

    input clearDelaySlot, //

    output reg [2:0] FowardA,
    output reg [2:0] FowardB,
    output reg [2:0] FowardAD,
    output reg [2:0] FowardBD,
    output reg stallPC,
    output reg stallF2D,

    output reg stallD2E,
    output reg ClrE2M,
    output reg ClrD2E,
    output reg ClrF2D
);

always @(*) begin

    stallPC = 0;
    stallF2D = 0;
    stallD2E = 0;
    ClrE2M = 0;
    ClrD2E = 0;
    ClrF2D = 0;

    if (regWriteM & jumpM & (rsE == raM)) begin
        if (rsE == 5'b0) FowardA = 3'b011;
        else FowardA = 3'b100;
    end
    else if (regWriteM & (rsE == raM)) begin
        if (rsE == 5'b0) FowardA = 3'b011;
        else FowardA = 3'b010;
    end
    else if(regWriteW & (rsE == raW))begin
        if (rsE == 5'b0) FowardA = 3'b011;
        else FowardA = 3'b001;
    end
    else FowardA = 3'b000;

    if (regWriteM & jumpM & (rtE == raM))begin
        if (rtE == 5'b0) FowardB = 3'b011;
        else FowardB = 3'b100;
    end
    else if (regWriteM & (rtE == raM))begin
        if (rtE == 5'b0) FowardB = 3'b011;
        else FowardB = 3'b010;
    end
    else if(regWriteW & (rtE == raW))begin
        if (rtE == 5'b0) FowardB =3'b011;
        else FowardB = 3'b001;
    end
    else FowardB = 3'b000;

    if ((branchD || jrD) & jumpM & regWriteM & (rsD == raM))  //beq 或者 jr 用到M 级jal
        if (rsD == 5'b0) FowardAD = 3'b011;
        else FowardAD = 3'b100;
    else if ((branchD || jrD) & regWriteM & (rsD == raM))  //beq或者jr 用到M级数据
        if (rsD == 5'b0) FowardAD = 3'b011;
        else FowardAD = 3'b010;
    else if((branchD || jrD) & regWriteW & (rsD == raW)) //beq或者jr 用到W级数据
        if (rsD == 5'b0) FowardAD = 3'b011;
        else FowardAD = 3'b001;
    else FowardAD = 3'b000;

    if ((branchD || jrD) & jumpM & regWriteM & (rtD == raM))
        if (rtD == 5'b0) FowardBD = 3'b011;
        else FowardBD = 3'b100;
    else if ((branchD || jrD) & regWriteM & (rtD == raM))
        if (rtD == 5'b0) FowardBD = 3'b011;
        else FowardBD = 3'b010;
    else if((branchD || jrD) & regWriteW & (rtD == raW))
        if (rtD == 5'b0) FowardBD = 3'b011;
        else FowardBD = 3'b001;
    else FowardBD = 3'b000;

    if (((rtE == rsD || rtE == rtD) && memToRegE)|| //lw - use
    ((rsD == raE || rtD == raE) && branchD && regWriteE) || //beq 需要用到E级数据
    ((rsD == raM || rtD == raM) && memToRegM && branchD) ||  //beq 需要用到M级load数据
    ((rsD == raE) && jrD && regWriteE) || //jr 需要用到E级数据
    ((rsD == raM) && jrD && memToRegM)) //jr 需要用到M级load数据
    begin 
        stallPC = 1;
        stallF2D = 1;
        ClrD2E = 1;
    end

    // 清空延迟槽
    // if (jumpD || branchD) begin
    //     ClrF2D = 1;
    // end


end

endmodule