class uart_base_test extends uvm_test;
	`uvm_component_utils(uart_base_test)

	virtual uart_if uart_vif;
	virtual ahb_if ahb_vif;
	uart_configuration cfg;
	uart_environment env;
	uart_error_catcher err_catcher;
	uart_reg_block regmodel;

  	time usr_timeout=50s;

	function new(string name = "uart_base_test", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("build_phase", "Entered...", UVM_HIGH)
		if (!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif", uart_vif)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_vif from uvm_config_db"))
		end
		if (!uvm_config_db#(virtual ahb_if)::get(this, "", "ahb_vif", ahb_vif)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get ahb_vif from uvm_config_db"))
		end
		env = uart_environment::type_id::create("env", this);
		cfg = uart_configuration::type_id::create("cfg");
		err_catcher = uart_error_catcher::type_id::create("err_catcher");
		uvm_report_cb::add(null, err_catcher);
		uvm_config_db#(virtual uart_if)::set(this, "env", "uart_vif", uart_vif);
		uvm_config_db#(virtual ahb_if)::set(this, "env", "ahb_vif", ahb_vif);
		uvm_config_db#(uart_configuration)::set(this, "env", "cfg", cfg);
    		uvm_top.set_timeout(usr_timeout);
		`uvm_info("build_phase", "Exiting...", UVM_HIGH)
	endfunction: build_phase
  
	virtual function void connect_phase(uvm_phase phase);
    		super.connect_phase(phase);
    		this.regmodel = env.regmodel;
  	endfunction: connect_phase

  	virtual function void end_of_elaboration_phase(uvm_phase phase);
    		super.end_of_elaboration_phase(phase);
    		uvm_top.print_topology();
  	endfunction: end_of_elaboration_phase
	
	task reset();
		ahb_vif.HRESETn <= 1'b0;
		ahb_vif.HADDR <= 8'h0;
		ahb_vif.HWDATA <= 8'h0;
		#10;
		ahb_vif.HRESETn <= 1'b1;
		@(posedge ahb_vif.HCLK);
		env.scb.q_tx.delete();
		env.scb.q_rx.delete();
	endtask: reset

	virtual function void final_phase(uvm_phase phase);
		uvm_report_server svr;
		super.final_phase(phase);
		`uvm_info("final_phase", "Entered...", UVM_HIGH)
		svr = uvm_report_server::get_server();
		if (svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) > 0) begin
			$display("\n=====================================================");
			$display("            #### Status: TEST FAILED ####              ");
			$display("\n=====================================================");
		end else begin
			$display("\n=====================================================");
			$display("            #### Status: TEST PASSED ####              ");
			$display("\n=====================================================");
		end
		`uvm_info("final_phase", "Exiting...", UVM_HIGH)
	endfunction: final_phase

endclass: uart_base_test
