class uart_environment extends uvm_env;
	`uvm_component_utils(uart_environment)

	virtual ahb_if ahb_vif;
	virtual uart_if uart_vif;
	uart_configuration cfg;
	uart_agent uart_agt;
	ahb_agent ahb_agt;
	uart_scoreboard scb;
	uart_reg_block regmodel;
	uart_reg2ahb_adapter ahb_adapter;
	
	uvm_reg_predictor #(ahb_transaction) ahb_predictor;

	function new(string name = "uart_environment", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("build phase", "Entered...", UVM_HIGH)
		if (!uvm_config_db#(virtual ahb_if)::get(this, "", "ahb_vif", ahb_vif)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get ahb_vif from uvm_config_db"))
		end
		if (!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif", uart_vif)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_vif from uvm_config_db"))
		end
		if (!uvm_config_db#(uart_configuration)::get(this, "", "cfg", cfg)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get cfg from uvm_config_db"))
		end
		
		uart_agt = uart_agent::type_id::create("uart_agt", this);
		ahb_agt = ahb_agent::type_id::create("ahb_agt", this);
		scb = uart_scoreboard::type_id::create("scb", this);
		ahb_predictor = uvm_reg_predictor#(ahb_transaction)::type_id::create("ahb_predictor", this);
		ahb_adapter = uart_reg2ahb_adapter::type_id::create("ahb_adapter", this);
		regmodel = uart_reg_block::type_id::create("regmodel", this);
		regmodel.build();

		uvm_config_db#(virtual ahb_if)::set(this, "ahb_agt", "ahb_vif", ahb_vif);
		uvm_config_db#(virtual uart_if)::set(this, "uart_agt", "uart_vif", uart_vif);
		uvm_config_db#(virtual ahb_if)::set(this, "uart_agt", "ahb_vif", ahb_vif);
		uvm_config_db#(uart_configuration)::set(this, "uart_agt", "cfg", cfg);
		uvm_config_db#(uart_configuration)::set(this, "scb", "cfg", cfg);
		`uvm_info("build_phase", "Exiting...", UVM_HIGH)
	endfunction: build_phase

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		// RAL
		ahb_predictor.map = regmodel.ahb_map;
		ahb_predictor.adapter = ahb_adapter;
		ahb_agt.mnt.ahb_observed_port.connect(ahb_predictor.bus_in);
		regmodel.ahb_map.set_sequencer(ahb_agt.seq, ahb_adapter);
		// Connect with scoreboard
		uart_agt.mnt.uart_observed_port_tx.connect(scb.uart_tx_export);
		uart_agt.mnt.uart_observed_port_rx.connect(scb.uart_rx_export);
		ahb_agt.mnt.ahb_observed_port.connect(scb.ahb_export);
	endfunction: connect_phase

endclass: uart_environment
