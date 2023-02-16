/**
 * @file  ice_spi.v
 * @brief Verilog implementation of a spi master interface. 
 * @note  tab = 2 spaces!
 * @note  "module __name__(...)" refers to a submodule to be instantiated, "module name(...)" refers to the top design.
 *
 */

module __pullup_io__ (input in, output out);

wire din, dout, trien;

assign out = din;

SB_IO #(.PIN_TYPE(6'b1010_01), .PULLUP(1'b1)) io_ctl(.PACKAGE_PIN(in), .OUTPUT_ENABLE(trien), .D_OUT_0(dout), .D_IN_0(din));

endmodule

module __psc__ #(parameter cntr_width = 2)(input clk_in, output clk_out);
  reg [cntr_width-1:0] cntr;
  assign clk_out = cntr[cntr_width-1];
  always @(posedge clk_in)
  begin
    cntr <= cntr + 1;
  end
endmodule  

module __mux__ (input sel, input din_0, input din_1, output dout);
  assign dout = (~sel & din_0) | (sel & din_1);
endmodule

/* 
 *  SPI mode truth table.
 *  +------+------+------+------+
 *  | m[1] | m[0] | CPOL | CPHA | 
 *  |   0  |   0  |   0  |   0  |
 *  |   0  |   1  |   1  |   0  |
 *  |   1  |   0  |   0  |   1  |
 *  |   1  |   1  |   1  |   1  |
 *  +------+------+------+------+
 */
module ice_spi_masterif
  (
    input         iclk,   // internal clock (FPGA clock @ 12 MHz)
    input         rst,    // reset
    input         txen,   // Transmission enable
    input   [1:0] mode,   // SPI mode
    input         miso,   // Master input - slave output
    output        mosi,   // Master output - slave input
    output        sclk,   // Slave Clock
    output        ss      // Slave select
  );

// internal logic 

/* SPI interface signals */
reg [7:0] imosi = 0;
reg [7:0] imiso = 0;

/* Clock phase and control signals */
reg [3:0] bit_cntr = 0;


// wires and buses
wire pullup_rst_out, pullup_txen_out;
wire psc_clk_out;
wire psc_clk_out;
wire CPOL = mode[0];
wire CPHA = mode[1];

// module instances
__psc__#(.cntr_width(11)) psc(.clk_in(iclk), .clk_out(psc_clk_out));    // Clock prescaler
__mux__ cpol_mux()
__pullup_io__ pullup_txen(.in(txen), .out(pullup_txen));                // Pull-up stage for txen pin.
__pullup_io__ pullup_rst(.in(rst), .out(pullup_rst_out));               // Pull-up stage for rst pin. 

assign imiso = miso;
assign mosi  = imosi;
assign sclk  = (~ss) & (psc_clk_out); // Clock is only supplied when slave select is pulled down.

// Synchronous reset logic
always @(posedge psc_clk_out) begin
  if(~pullup_rst_out) begin
      ss      <= 1;
      imode   <= 8'h00;
      imosi   <= 8'h00;
      imiso   <= 8'h00;
      sclk    <= 0;
  end // if(~pullup_rst_out)
end

always @(posedge iclk) begin
  if(~pullup_txen_out) begin
    


    
  end // if(~pullup_txen_out)
end


end// if(~pullup_txen_out)
endmodule
