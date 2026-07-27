class register_reserved_test extends uart_base_test;
	`uvm_component_utils(register_reserved_test)

	ahb_sequence seq;

	function new(string name = "uart_FULL_115200_baud_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		seq = ahb_sequence::type_id::create("seq");
		repeat (10) begin
			seq.address = $urandom_range(10'h020, 10'h3FF);
			seq.start(env.ahb_agt.seq);
		end
		#500ns;	
		phase.drop_objection(this);
	endtask: run_phase

endclass: register_reserved_test
