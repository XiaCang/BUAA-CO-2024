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
    input busyE,
    input hlreadD,
    input mdstartE,
    input hlwriteD,
    input mdstartD,
    input clearDelaySlot, //
    input req,
    input c0readE,
    input c0writeE,
    input c0writeM,
    input eretD,
    output reg [2:0] FowardA,
    output reg [2:0] FowardB,
    output reg [2:0] FowardAD,
    output reg [2:0] FowardBD,
    output reg stallPC,
    output reg stallF2D,

    output reg stallD2E,
    output reg stallE2M,
    output reg stallM2W,
    output reg ClrE2M,
    output reg ClrD2E,
    output reg ClrF2D,
    output reg ClrM2W
);

always @(*) begin



    stallD2E = 0;
    stallE2M = 0;
    stallM2W = 0;
    ClrE2M = 0;
    ClrF2D = 0;
    ClrM2W = 0;
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

    if (((rtE == rsD || rtE == rtD) && (memToRegE || c0readE))|| //lw - use
    ((rsD == raE || rtD == raE) && branchD && regWriteE) || //beq 需要用到E级数据
    ((rsD == raM || rtD == raM) && (memToRegM || c0readE) && branchD) ||  //beq 需要用到M级load数据
    ((rsD == raE) && jrD && regWriteE) || //jr 需要用到E级数据
    ((rsD == raM) && jrD && (memToRegM || c0readE)) || //jr 需要用到M级load数据
    (busyE || mdstartE) && (hlreadD || hlwriteD) ||
    eretD && (c0writeE || c0writeM)) // && raE == 5'd14 raM == 5'd14
    begin 
        stallPC = 1;
        stallF2D = 1;
        ClrD2E = 1;
    end
    else begin
        stallPC = 0;
        stallF2D = 0;
        ClrD2E = 0;
    end


end

endmodule