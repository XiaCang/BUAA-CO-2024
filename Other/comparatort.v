`timescale  1ns / 1ps

module tb_comparator;

// comparator Parameters
parameter PERIOD  = 10;
integer i;
integer j;

// comparator Inputs
reg   [3:0]  A                             = 0 ;
reg   [3:0]  B                             = 0 ;

// comparator Outputs
wire  Out                                  ;

comparator  u_comparator (
    .A                       ( A    [3:0] ),
    .B                       ( B    [3:0] ),

    .Out                     ( Out        )
);

initial
begin
    $dumpfile("comparator.vcd");
    $dumpvars();

    #10;

    A = 4'b0000;
    B = 4'b0000;
    #10;
    
    for (i = 0; i<= 15 ; i=i+1) begin
        for (j = 0; j<= 15 ; j=j+1) begin
            A = i;
            B = j;
            #10;
        end
    end


    $finish;
end

endmodule