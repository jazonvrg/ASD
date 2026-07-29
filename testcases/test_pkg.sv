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
	`include "TX_16x_5bits_data_test.sv"

	// TX - 13x

	// RX - 16x
	`include "RX_16x_5bits_data_test.sv"

	// RX - 13x

	// Interrupt
	`include "error_parity_test.sv"
	`include "error_parity_test_cp.sv"

endpackage: test_pkg

`endif


