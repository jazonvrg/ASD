class error_reserved_test extends uart_base_test;
	`uvm_component_utils(error_reserved_test)
	
	write_register_reserved_sequence write_reserved_seq;
	read_register_reserved_sequence read_reserved_seq;
	write_register_sequence write_seq;
	read_register_sequence read_seq;
	uvm_status_e status;
	logic [`AHB_DATA_WIDTH-1:0] rdata;

	function new(string name = "error_reserved_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		reset();
		write_reserved_seq = write_register_reserved_sequence::type_id::create("write_reserved_seq");
		read_reserved_seq = read_register_reserved_sequence::type_id::create("read_reserved_seq");
		write_seq = write_register_sequence::type_id::create("write_seq");
		read_seq = read_register_sequence::type_id::create("read_seq");
		$display("============================================================================================================================");
		$display("==========================================  ### ERROR HANDLING | RESERVED  ###  ============================================");
		$display("============================================================================================================================");
		// WRITE ON RESERVED | RESP = 1
		repeat (10) begin
			write_reserved_seq.start(env.ahb_agt.seq);
		end
		// READ ON RESERVED  | RESP = 1 | RDATA = 32'hFFFF_FFFF
		repeat (10) begin
			read_reserved_seq.start(env.ahb_agt.seq);
		end
		// WRITE ON AVAILBLE RESERVED | RESP = 0
		env.scb.selection = 9.3;
		repeat (10) begin
			write_seq.start(env.ahb_agt.seq);
		end
		// READ ON AVAILBLE RESERVED | RESP = 0
		env.scb.selection = 9.4;
		repeat (10) begin
			read_seq.start(env.ahb_agt.seq);
		end
		#500ns;	
		phase.drop_objection(this);
	endtask: run_phase

endclass
