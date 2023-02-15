// D-FlipFlop
module dffn(input clk, input D, output Q, output Qc);
assign Qc = ~Q; 
always @(posedge clk) Q <= D;
endmodule

// Prescaler - from 12 MHz to 1 Hz -> logb2(12000000) = 24 approx.
module psc(input clk, output reg psc_out);
localparam psc_width = 22;
reg [psc_width - 1:0] counter = 0;
always @(posedge clk) counter <= counter + 1;

assign psc_out = counter[psc_width - 1];

endmodule

// Modulo-8 synchronous counter
module main(input clk, output RLED1, output RLED2, output RLED3);

localparam N = 3;

wire [N-1:0] S;
wire [N-1:0] L;
wire [N-1:0] Sc;

wire PSCtoDFF;

assign L[0] = Sc[0];
assign L[1] = S[0] ^ S[1];
assign L[2] = ( S[2] & ( Sc[0] | Sc[1] ) ) | ( Sc[2] & S[0] & S[1] );

psc psc0(.clk(CLK_IN), .psc_out(PSCtoDFF));

dffn dff0( .clk(PSCtoDFF), .D(L[0]), .Q(S[0]), .Qc(Sc[0]));
dffn dff1( .clk(PSCtoDFF), .D(L[1]), .Q(S[1]), .Qc(Sc[1]));
dffn dff2( .clk(PSCtoDFF), .D(L[2]), .Q(S[2]), .Qc(Sc[2]));

assign RLED1 = S[0];
assign RLED2 = S[1];
assign RLED3 = S[2];

endmodule
