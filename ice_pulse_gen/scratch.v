module __pullup__(input in, input out);
wire din, dout, outen;

assign out = din;

SB_IO #(.PIN_TYPE(6'b1010_01), .PULLUP(1'b1)) io_pin(.PACKAGE_PIN(in), .OUTPUT_ENABLE(outen), .D_OUT_0(dout), .D_IN_0(din));

endmodule

module __psc__ #(parameter psc_width = 2)(input clk_in, output clk_out);
reg [psc_width-1:0] cntr;
assign clk_out = cntr[psc_width-1];
always @(posedge clk_in)
begin
  cntr <= cntr + 1;
end
endmodule

module _design_(input clk, input enable, output tx);
    reg [31:0] data_reg = 32'hA0A0A0A0;
    reg [5:0]  bit_cntr = 0;    
    wire pup_out, psc_clk_out;

    __psc__ #(.psc_width(11)) psc(.clk_in(clk), .clk_out(psc_clk_out));
    __pullup__ pup(.in(enable), .out(pup_out));

    always @(posedge psc_clk_out)
    begin
        if(~pup_out)
        begin
            bit_cntr <= 32;
        end
        if(bit_cntr > 0)
        begin
            tx <= data_reg[bit_cntr];
            bit_cntr <= bit_cntr - 1;
        end
    end
endmodule

module top(input CLK_IN, input J2_1, output J2_2);
    _design_ design(.clk(CLK_IN), .enable(J2_1), .tx(J2_2));
endmodule