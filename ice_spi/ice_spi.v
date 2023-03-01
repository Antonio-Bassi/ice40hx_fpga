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

module __psc__ 
  (
    input       ref_clk,
    input       rstb,
    input       bypass,
    input       ext_fb,
    input [7:0] d_delay,
    input       latch_in_val,
    
    output      lock,
    output      pll_out_global,
    output      pll_out_core
  );
  
  SB_PLL40_CORE #(
    .FEEDBACK_PATH("SIMPLE"),
    .PLL_SELECT("GENCLK"),
    .DIVR(4'b0000),
    .DIVF(4'b1100),
    .DIVQ()  
    .FILTER_RANGE()
  ) pll ()

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
    // Control signals
    input       i_spi_rst,    // reset SPI interface core logic.
    input       i_spi_clk,    // SPI clock signal.
    input       i_spi_txen,   // SPI transmission enable.
    input       i_spi_load,   // Load SPI instruction into data register.
    input       i_spi_instr,  // SPI instruction.
    input [1:0] i_spi_mode,   // SPI mode signal.

    // SPI interface signals
    input         i_spi_data_in   // SPI data input.
    output        o_spi_cs,       // SPI chip select signal, a.k.a slave select.
    output        o_spi_sclk,     // SPI chip clock, a.k.a slave clock.
    output        o_spi_data_out  // SPI data outout.
  );

  /* State machine codification */
  localparam IDLE = 2'b00; // Interface is idle.
  localparam TSXN = 2'b01; // Transaction is being processed.
  localparam CSD  = 2'b10; // Chip select is inactive.

  /* parameters */
  localparam SPI_BITS_PER_BYTE = 8;
  localparam SPI_TX_CNT = 4;

  /* Internal signals and registers */
  reg _spi_tx_dv;                       // SPI transmission data is valid.
  reg [SPI_TX_CNT-1:0]  _spi_tx_cntr;   // SPI transmission bit counter.
  reg [1:0]             _spi_state;     // SPI state register.
  reg [SPI_BITS_PER_BYTE-1:0] _spi_miso // SPI Master Input Slave Output data register.
  reg [SPI_BITS_PER_BYTE-1:0] _spi_mosi // SPI Master Output Slave Input data register.

  always @(posedge i_spi_clk or negedge i_spi_rst) begin
    if(~i_spi_rst) begin
      _spi_state      <= 0'b00;
      _spi_tx_dv      <= 1'b0;
      _spi_miso       <= 8'h00;
      _spi_mosi       <= 8'h00;
      o_spi_sclk      <= i_spi_mode[0];
      o_spi_cs        <= 1'b1;
      o_spi_data_out  <= 1'b0;
    end // if(~i_spi_rst)

    else if(~i_spi_load) begin
      _spi_mosi <= i_spi_instr;
      _spi_tx_dv <= 1'b1;
    end // if(~i_spi_load)

    else if(~i_spi_txen) begin
      case (_spi_state)
        IDLE:
        begin
          if(_spi_tx_dv) begin

            o_spi_cs <= 1'b0;
            _spi_state <= TSXN;
            
          end // if(_spi_tx_dv)
        end

        TSXN:
        begin
          
        end

        CSD:
        begin
          
        end

        default:
        begin
          _spi_tx_dv  <= 1'b0;
          _spi_state  <= IDLE;
          o_spi_cs    <= 1'b1;    
        end
      endcase  
    end //if(~i_spi_txen)

  end // always @(posedge i_spi_clk or negedge i_spi_rst)

endmodule
