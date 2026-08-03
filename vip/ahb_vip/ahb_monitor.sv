class ahb_monitor extends uvm_monitor;
	`uvm_component_utils(ahb_monitor)

  	virtual ahb_if ahb_vif;
	
	uvm_analysis_port #(ahb_transaction) ahb_observed_port;

	ahb_transaction trans;

  	function new(string name="ahb_monitor", uvm_component parent);
    		super.new(name, parent);
		ahb_observed_port = new("ahb_observed_port", this);
  	endfunction: new

  	virtual function void build_phase(uvm_phase phase);
		`uvm_info("build_phase", "Entered...", UVM_LOW)
    		super.build_phase(phase);
		if (!uvm_config_db#(virtual ahb_if)::get(this, "", "ahb_vif", ahb_vif)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get ahb_vif from uvm_config_db"));
		end 
		`uvm_info("build_phase", "Exiting...", UVM_LOW)
  	endfunction: build_phase

  	virtual task run_phase(uvm_phase phase);
		`uvm_info("run_phase", "Entered...", UVM_LOW)
		forever begin
			trans = ahb_transaction::type_id::create("trans");
			do begin
				@(posedge ahb_vif.HCLK);
			end while (ahb_vif.HTRANS !== 2'h2 || ahb_vif.HREADYOUT !== 1'b1);
			trans.addr = ahb_vif.HADDR;
			$cast(trans.xact_type, ahb_vif.HWRITE);
			$cast(trans.xfer_size, ahb_vif.HSIZE);
			$cast(trans.burst_type, ahb_vif.HBURST);
			trans.prot = ahb_vif.HPROT;
			trans.lock = ahb_vif.HMASTLOCK;
			do begin
				@(posedge ahb_vif.HCLK);
			end while (ahb_vif.HREADYOUT !== 1'b1);
			if (trans.xact_type == ahb_transaction::WRITE) begin
				trans.data = ahb_vif.HWDATA;
			end else begin
				trans.data = ahb_vif.HRDATA;
			end
			trans.resp = ahb_vif.HRESP;
			`uvm_info(get_type_name(), $sformatf("Observed transaction: \n%s", trans.sprint()), UVM_LOW)
			ahb_observed_port.write(trans);
		end
		`uvm_info("run_phase", "Exiting...", UVM_LOW)
  	endtask: run_phase

endclass: ahb_monitor
