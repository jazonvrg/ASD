class write_register_reserved_sequence extends uvm_sequence #(ahb_transaction);
	`uvm_object_utils(write_register_reserved_sequence)

	function new(string name = "write_register_reserved_sequence");
		super.new(name);
	endfunction: new

	virtual task body();
		`uvm_info("body", "Entered...", UVM_LOW)
		req = ahb_transaction::type_id::create("req");
		start_item(req);
		if (req.randomize() with {addr inside {[10'h020:10'h3FF]};
					  addr % 4 == 0;
					  xact_type == WRITE;
					  xfer_size == SIZE_32BIT;
					  burst_type == SINGLE;}) begin
			`uvm_info("body", $sformatf("Transaction randomize is: \n%0s", req.sprint()), UVM_LOW);
		end else begin
			`uvm_fatal("body", $sformatf("Randomize failure!"));
		end
		finish_item(req);
		get_response(rsp);
		`uvm_info("body", "Exiting...", UVM_LOW)
	endtask: body

endclass: write_register_reserved_sequence
