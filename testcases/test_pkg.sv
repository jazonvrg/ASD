//=============================================================================
// Project       : UART VIP
//=============================================================================
// Filename      : test_pkg.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 20-Dec-2021
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef GUARD_UART_TEST_PKG__SV
`define GUARD_UART_TEST_PKG__SV

package test_pkg;
	import uvm_pkg::*;
  	import ahb_pkg::*;
  	import env_pkg::*;
  	import seq_pkg::*;
	import uart_regmodel_pkg::*;
  	import uart_pkg::*;

  	// Include your file
	`include "uart_base_test.sv"
	
	// Register
	`include "register_default_value_test.sv"
	`include "register_read_write_test.sv"
	`include "register_reset_test.sv"
	`include "register_reserved_test.sv"

	// TX - 16x
		// data_width
	`include "TX_16x_5bits_data_test.sv"
	`include "TX_16x_6bits_data_test.sv"
	`include "TX_16x_7bits_data_test.sv"
	`include "TX_16x_8bits_data_test.sv"
		// parity_mode
	`include "TX_16x_odd_parity_test.sv"
	`include "TX_16x_even_parity_test.sv"
	`include "TX_16x_no_parity_test.sv"
		// stop_bit
	`include "TX_16x_1_stop_bit_test.sv"
	`include "TX_16x_2_stop_bit_test.sv"
		// baud_rate
	`include "TX_16x_2400_baud_test.sv"
	`include "TX_16x_4800_baud_test.sv"
	`include "TX_16x_9600_baud_test.sv"
	`include "TX_16x_19200_baud_test.sv"
	`include "TX_16x_38400_baud_test.sv"
	`include "TX_16x_76800_baud_test.sv"
	`include "TX_16x_115200_baud_test.sv"
	`include "TX_16x_custom_baud_test.sv"

	// TX - 13x
		// data_width
	`include "TX_13x_5bits_data_test.sv"
	`include "TX_13x_6bits_data_test.sv"
	`include "TX_13x_7bits_data_test.sv"
	`include "TX_13x_8bits_data_test.sv"
		// parity_mode
	`include "TX_13x_odd_parity_test.sv"
	`include "TX_13x_even_parity_test.sv"
	`include "TX_13x_no_parity_test.sv"
		// stop_bit
	`include "TX_13x_1_stop_bit_test.sv"
	`include "TX_13x_2_stop_bit_test.sv"
		// baud_rate
	`include "TX_13x_2400_baud_test.sv"
	`include "TX_13x_4800_baud_test.sv"
	`include "TX_13x_9600_baud_test.sv"
	`include "TX_13x_19200_baud_test.sv"
	`include "TX_13x_38400_baud_test.sv"
	`include "TX_13x_76800_baud_test.sv"
	`include "TX_13x_115200_baud_test.sv"
	`include "TX_13x_custom_baud_test.sv"

	// RX - 16x
		// data_width
	`include "RX_16x_5bits_data_test.sv"
	`include "RX_16x_6bits_data_test.sv"
	`include "RX_16x_7bits_data_test.sv"
	`include "RX_16x_8bits_data_test.sv"
		// parity_mode
	`include "RX_16x_odd_parity_test.sv"
	`include "RX_16x_even_parity_test.sv"
	`include "RX_16x_no_parity_test.sv"
		// stop_bit
	`include "RX_16x_1_stop_bit_test.sv"
	`include "RX_16x_2_stop_bit_test.sv"
		// baud_rate
	`include "RX_16x_2400_baud_test.sv"
	`include "RX_16x_4800_baud_test.sv"
	`include "RX_16x_9600_baud_test.sv"
	`include "RX_16x_19200_baud_test.sv"
	`include "RX_16x_38400_baud_test.sv"
	`include "RX_16x_76800_baud_test.sv"
	`include "RX_16x_115200_baud_test.sv"
	`include "RX_16x_custom_baud_test.sv"

	// RX - 13x
		// data_width
	`include "RX_13x_5bits_data_test.sv"
	`include "RX_13x_6bits_data_test.sv"
	`include "RX_13x_7bits_data_test.sv"
	`include "RX_13x_8bits_data_test.sv"
		// parity_mode
	`include "RX_13x_odd_parity_test.sv"
	`include "RX_13x_even_parity_test.sv"
	`include "RX_13x_no_parity_test.sv"
		// stop_bit
	`include "RX_13x_1_stop_bit_test.sv"
	`include "RX_13x_2_stop_bit_test.sv"
		// baud_rate
	`include "RX_13x_2400_baud_test.sv"
	`include "RX_13x_4800_baud_test.sv"
	`include "RX_13x_9600_baud_test.sv"
	`include "RX_13x_19200_baud_test.sv"
	`include "RX_13x_38400_baud_test.sv"
	`include "RX_13x_76800_baud_test.sv"
	`include "RX_13x_115200_baud_test.sv"
	`include "RX_13x_custom_baud_test.sv"

	// Reset on the fly
		// TX
	`include "TX_reset_on_the_fly_test.sv"
		// RX

	// Interrupt
		// error_parity
	`include "error_parity_test.sv"
//	`include "normal_parity_test.sv"
		// RX_fifo
	`include "enable_empty_rx_fifo_test.sv"
	`include "disenable_empty_rx_fifo_test.sv"
	`include "enable_full_rx_fifo_test.sv"
	`include "disenable_full_rx_fifo_test.sv"
		// TX_fifo
	`include "enable_empty_tx_fifo_test.sv"
	`include "disenable_empty_tx_fifo_test.sv"
	`include "enable_full_tx_fifo_test.sv"
	`include "disenable_full_tx_fifo_test.sv"

	// Error handling
	`include "error_reserved_test.sv"

endpackage: test_pkg

`endif


