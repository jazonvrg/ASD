class register_read_write_test extends uart_base_test;
	`uvm_component_utils(register_read_write_test)

	uvm_reg_bit_bash_seq reg_bit_bash_seq;

  	function new(string name="register_read_write_test", uvm_component parent);
    		super.new(name,parent);
  	endfunction: new
	
  	virtual task run_phase(uvm_phase phase); 
    		phase.raise_objection(this);

		reg_bit_bash_seq = uvm_reg_bit_bash_seq::type_id::create("reg_bit_bash_seq", this);
		reg_bit_bash_seq.model = env.regmodel;
		reg_bit_bash_seq.start(env.ahb_agt.seq);	
		
    		phase.drop_objection(this);
  	endtask: run_phase

endclass
