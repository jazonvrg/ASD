class register_default_value_test extends uart_base_test;
	`uvm_component_utils(register_default_value_test)

	uvm_reg_hw_reset_seq reg_hw_reset_seq;

  	function new(string name = "register_default_value_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction: new
	
  	virtual task run_phase(uvm_phase phase); 
    		phase.raise_objection(this);

		reg_hw_reset_seq = uvm_reg_hw_reset_seq::type_id::create("reg_hw_reset_seq", this);
		reg_hw_reset_seq.model = env.regmodel;
		reg_hw_reset_seq.start(env.ahb_agt.seq);	
		
    		phase.drop_objection(this);
  	endtask: run_phase

endclass
