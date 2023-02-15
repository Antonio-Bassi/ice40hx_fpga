/**
 * @file  ice_spi.v
 * @brief Verilog implementation of a spi master interface. 
 * @note  tab = 2 spaces!
 * @note  "module __name__(...)" refers to a submodule to be instantiated, "module name(...)" refers to the top design.
 *
 */
module __psc__ #(parameter cntr_width = 2)(input clk_in, output clk_out)
  reg [cntr_width-1:0] cntr;
  assign clk_out = cntr[cntr_width-1];
  always @(posedge clk_in)
  begin
    cntr <= cntr + 1;
  end
endmodule  

/* 
 *
 *  SPI mode truth table.
 *  +------+------+------+------+
 *  | m[1] | m[0] | CPOL | CPHA | 
 *  |   0  |   0  |   0  |   0  |
 *  |   0  |   1  |   1  |   0  |
 *  |   1  |   0  |   0  |   1  |
 *  |   1  |   1  |   1  |   1  |
 *  +------+------+------+------+
 *
 *
 *
 */
module ice_spi_masterif
  (
    input  iclk,              // internal clock (FPGA clock @ 12 MHz)
    input  rst,               // reset
    input  txen               // Transmission enable
    input  reg [1:0]  mode,   // SPI mode
    input  reg [7:0]  miso,   // Master input - slave output
    output reg [7:0]  mosi,   // Master output - slave input
    output sclk,              // Slave Clock
    output ss                 // Slave select
  );

// internal logic 
reg [7:0] imosi = 0;
reg [7:0] imiso = 0;
reg [1:0] imode = 0;

// module instances
__psc__ psc #(.cntr_width(11))(.clk_in(iclk), .clk_out(psc_clk_out)); // Clock prescaler

// wires and buses
wire psc_clk_out;
wire CPOL = mode[0];
wire CPHA = mode[1];

assign imode = mode; 
assign imiso = miso;
assign mosi  = imosi;
assign sclk  = (~ss) & (psc_clk_out); // Clock is only supplied when slave select is pulled down.

// Synchronous reset logic
always @(posedge iclk & negedge rst)
begin
  ss      <= 1;
  imode   <= 8'h00;
  imosi   <= 8'h00;
  imiso   <= 8'h00;
  sclk    <= 0;
end // always @(posedge iclk & negedge rst)

// Transmission enable to slave select logic.
always @(posedge iclk)
begin
  ss <= txen;
end

// Clock polarity
always @(posedge iclk)
begin
  if( ~CPOL )
  begin
    sclk <= psc_clk_out;
  end
  else
  begin
    sclk <= ~psc_clk_out;    
  end
end

endmodule
