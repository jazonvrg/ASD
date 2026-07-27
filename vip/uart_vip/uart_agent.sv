class uart_agent extends uvm_agent;
	`uvm_component_utils(uart_agent)

	uart_sequencer seq;
	uart_driver drv;
	uart_monitor mnt;
	virtual uart_if uart_vif;
	virtual ahb_if ahb_vif;
	uart_configuration cfg;

	function new(string name = "uart_agent", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("build_phase", "Entered...", UVM_HIGH)
		if (!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif", uart_vif)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_vif from uvm_config_db"));
		end
		if (!uvm_config_db#(virtual ahb_if)::get(this, "", "ahb_vif", ahb_vif)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get ahb_if from uvm_config_db"));	
		end
		if (!uvm_config_db#(uart_configuration)::get(this, "", "cfg", cfg)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get cfg_lhs from uvm_config_db"))
		end
		if (is_active == UVM_ACTIVE) begin
			`uvm_info(get_type_name(), $sformatf("Active agent is configured"), UVM_LOW);
			seq = uart_sequencer::type_id::create("seq", this);
			drv = uart_driver::type_id::create("drv", this);
			mnt = uart_monitor::type_id::create("mnt", this);	
			uvm_config_db#(virtual uart_if)::set(this, "drv", "uart_vif", uart_vif);
			uvm_config_db#(virtual uart_if)::set(this, "mnt", "uart_vif", uart_vif);
			uvm_config_db#(virtual ahb_if)::set(this, "drv", "ahb_vif", ahb_vif);
			uvm_config_db#(virtual ahb_if)::set(this, "mnt", "ahb_vif", ahb_vif);
			uvm_config_db#(uart_configuration)::set(this, "drv", "cfg", cfg);
			uvm_config_db#(uart_configuration)::set(this, "mnt", "cfg", cfg);
		end else begin
			mnt = uart_monitor::type_id::create("mnt", this);	
			uvm_config_db#(virtual uart_if)::set(this, "mnt", "uart_vif", uart_vif);
			uvm_config_db#(uart_configuration)::set(this, "mnt", "cfg", cfg);
		end
		`uvm_info("build_phase", "Exiting...", UVM_HIGH)
	endfunction: build_phase

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		if (get_is_active() == UVM_ACTIVE) begin
			drv.seq_item_port.connect(seq.seq_item_export);
		end
	endfunction: connect_phase

endclass: uart_agent
