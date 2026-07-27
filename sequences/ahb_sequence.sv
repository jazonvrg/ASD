class ahb_sequence extends uvm_sequence #(ahb_transaction);
	`uvm_object_utils(ahb_sequence)

	bit[`AHB_ADDR_WIDTH-1:0]  address;

	function new(string name = "ahb_sequence");
		super.new(name);
	endfunction: new

	virtual task body();
		`uvm_info("body", "Entered...", UVM_LOW)
		// WRITE
		req = ahb_transaction::type_id::create("req");
		start_item(req);
		if (req.randomize() with {addr == local::address;
					  xact_type == WRITE;
					  xfer_size == SIZE_32BIT;
					  burst_type == SINGLE;}) begin
			`uvm_info("body", $sformatf("Transaction randomize is: \n%0s", req.sprint()), UVM_LOW);
		end else begin
			`uvm_fatal("body", $sformatf("Randomize failure!"));
		end
		finish_item(req);
		get_response(rsp);
		// READ
		req = ahb_transaction::type_id::create("req");
		start_item(req);
		if (req.randomize() with {addr == local::address;
					  xact_type == READ;
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

endclass: ahb_sequence
