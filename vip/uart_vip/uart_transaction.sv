class uart_transaction extends uvm_sequence_item;

	rand logic [7:0] data;
	rand logic parity;
		
	`uvm_object_utils_begin (uart_transaction)
		`uvm_field_int (data, UVM_ALL_ON | UVM_BIN)
		`uvm_field_int (parity, UVM_ALL_ON | UVM_BIN)
	`uvm_object_utils_end

	function new(string name = "uart_transaction");
		super.new(name);
	endfunction: new

endclass: uart_transaction
