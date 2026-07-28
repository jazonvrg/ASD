class uart_configuration extends uvm_object;

	typedef enum logic [1:0] {
		NONE = 2'b00,
		ODD = 2'b01,
		EVEN = 2'b10
	} parity_mode_config;

	typedef enum logic {
		NORMAL = 1'b0,
		ERROR  = 1'b1
	} parity_error_config;
	
	typedef enum logic {
		TX = 1'b0,
		RX = 1'b1
	} mode_config;

	typedef enum logic {
		X16 = 1'b0,
		X13 = 1'b1
	} ovs_config;
	 
	rand parity_mode_config parity_mode;
	rand int data_width;
	rand int num_of_stop_bit;
	rand int baud_rate;
	rand ovs_config ovsmpl;
	rand logic [15:0] divisor;
	rand parity_error_config parity_error;
	rand mode_config uart_mode;

	constraint num_of_stop_bit_range {
		num_of_stop_bit inside {1, 2};
	}

	constraint data_width_range {
		data_width inside {5, 6, 7, 8};
	}

	constraint baud_rate_range {
		baud_rate inside {[118:6250000]};
	}

	`uvm_object_utils_begin (uart_configuration)
		`uvm_field_enum (parity_mode_config, parity_mode, UVM_ALL_ON | UVM_STRING)
		`uvm_field_int (data_width, UVM_ALL_ON | UVM_DEC)
		`uvm_field_int (num_of_stop_bit, UVM_ALL_ON | UVM_DEC)
		`uvm_field_int (baud_rate, UVM_ALL_ON | UVM_DEC)
		`uvm_field_enum (ovs_config, ovsmpl, UVM_ALL_ON | UVM_STRING)
		`uvm_field_enum (parity_error_config, parity_error, UVM_ALL_ON | UVM_STRING)
		`uvm_field_enum (mode_config, uart_mode, UVM_ALL_ON | UVM_STRING)
	`uvm_object_utils_end
	
	function new(string name = "uart_configuration");
		super.new(name);
	endfunction: new

endclass: uart_configuration
