// prescaler
module psc (input clk_in, output clk_out);
localparam psc_width = 21;
reg [psc_width-1:0] psck;
assign clk_out = psck[psc_width-1];
always @(posedge clk_in)
begin
  psck <= psck + 1;
end
endmodule

// 4-bit counter with carry out.
module ice_cntr(input clk, output reg [3:0] s, output c);
localparam cntr_width = 4;
reg [cntr_width-1:0] cntr = 0;

assign c = cntr[0] & cntr[1] & cntr[2] & cntr[3];
assign s[0] = cntr[0];
assign s[1] = cntr[1];
assign s[2] = cntr[2];
assign s[3] = cntr[3];

always @(posedge clk)
begin
  cntr <= cntr + 1;
end // always @(posedge clk)

endmodule

module main(input CLK_IN, output RLED1, output RLED2, output RLED3, output RLED4, output GLED5);
wire PSC2CNTR;
wire carry;
wire [width-1:0] out;
localparam width = 4;

assign RLED1 = out[0];
assign RLED2 = out[1];
assign RLED3 = out[2];
assign RLED4 = out[3];
assign GLED5 = carry;

psc      prescaler(.clk_in(CLK_IN), .clk_out(PSC2CNTR));
ice_cntr counter(.clk(PSC2CNTR), .s(out), .c(carry));
endmodule


