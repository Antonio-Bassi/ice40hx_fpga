module main(input CLK_IN, output GLED5, output RLED1, output RLED2, output RLED3, output RLED4);

localparam CNTR_WIDTH = 24;

reg [CNTR_WIDTH - 1:0] counter;
  always @(posedge CLK_IN)
  counter <= counter + 1;

assign GLED5 = counter[CNTR_WIDTH - 1];
assign RLED1 = counter[CNTR_WIDTH - 2];
assign RLED2 = counter[CNTR_WIDTH - 3];
assign RLED3 = counter[CNTR_WIDTH - 4];
assign RLED4 = counter[CNTR_WIDTH - 5];

endmodule
