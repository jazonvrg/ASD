class ahb_agent extends uvm_agent;
	`uvm_component_utils(ahb_agent)

  	ahb_monitor   mnt;
  	ahb_driver    drv;
  	ahb_sequencer seq;

	virtual ahb_if ahb_vif;

  	function new(string name="ahb_agent", uvm_component parent);
    		super.new(name, parent);
  	endfunction: new

  	virtual function void build_phase(uvm_phase phase);
    		super.build_phase(phase);
		`uvm_info("build_phase", "Entered...", UVM_HIGH)
    		if (!uvm_config_db#(virtual ahb_if)::get(this, "", "ahb_vif", ahb_vif)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get ahb_vif from uvm_config_db"));
		end 
    		if(is_active == UVM_ACTIVE) begin
      			`uvm_info(get_type_name(),$sformatf("Active agent is configued"), UVM_LOW)
      			drv = ahb_driver::type_id::create("drv", this);
      			seq = ahb_sequencer::type_id::create("seq", this);
      			mnt = ahb_monitor::type_id::create("mnt", this);
    			uvm_config_db#(virtual ahb_if)::set(this, "drv", "ahb_vif", ahb_vif); 
    			uvm_config_db#(virtual ahb_if)::set(this, "mnt", "ahb_vif", ahb_vif); 
    		end else begin
      			`uvm_info(get_type_name(),$sformatf("Passive agent is configued"),UVM_LOW)
      			mnt = ahb_monitor::type_id::create("mnt", this);
    		end
		`uvm_info("build_phase", "Exiting...", UVM_HIGH)
  	endfunction: build_phase

  	virtual function void connect_phase(uvm_phase phase);
    		super.connect_phase(phase);
    		if(get_is_active() == UVM_ACTIVE) begin 
      			drv.seq_item_port.connect(seq.seq_item_export);
    		end
  	endfunction: connect_phase

endclass: ahb_agent
