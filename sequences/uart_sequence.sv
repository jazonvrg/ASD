class uart_sequence extends uvm_sequence #(uart_transaction);
	`uvm_object_utils(uart_sequence)

	function new(string name = "uart_sequence");
		super.new(name);
	endfunction: new

	virtual task body();
		`uvm_info("body", "Entered...", UVM_LOW)
		req = uart_transaction::type_id::create("req");
		start_item(req);
		if (req.randomize()) begin
			`uvm_info("body", $sformatf("Transaction randomize is: \n%0s", req.sprint()), UVM_LOW);
		end else begin
			`uvm_fatal("body", $sformatf("Randomize failure!"));
		end
		finish_item(req);
		`uvm_info("body", "Exiting...", UVM_LOW)
	endtask: body

endclass: uart_sequence
