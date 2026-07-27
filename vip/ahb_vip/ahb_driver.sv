class ahb_driver extends uvm_driver #(ahb_transaction);
	`uvm_component_utils(ahb_driver)

  	virtual ahb_if ahb_vif;

  	function new(string name="ahb_driver", uvm_component parent);
    		super.new(name, parent);
  	endfunction: new

  	virtual function void build_phase(uvm_phase phase);
    		super.build_phase(phase);
		`uvm_info("build_phase", "Entered...", UVM_LOW)
    		/** Applying the virtual interface received through the config db - learn detail in next session*/
    		if (!uvm_config_db#(virtual ahb_if)::get(this, "", "ahb_vif", ahb_vif)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get ahb_vif from uvm_config_db"));
		end 
		`uvm_info("build_phase", "Exiting...", UVM_LOW)
  	endfunction: build_phase

  	/** User can use ahb_vif to control real interface like systemverilog part*/
  	virtual task run_phase(uvm_phase phase);
		`uvm_info("run_phase", "Entered...", UVM_LOW)
		wait (ahb_vif.HRESETn);
		ahb_vif.HADDR <= 'h0;
		ahb_vif.HTRANS <= 2'h0;
		ahb_vif.HWRITE <= 1'b0;
		forever begin
			seq_item_port.get(req);
			drive();
			seq_item_port.put(rsp);
		end
		`uvm_info("run_phase", "Exiting...", UVM_LOW)
  	endtask: run_phase

	virtual task drive();
		/** Address phase **/
		@(posedge ahb_vif.HCLK);
		ahb_vif.HADDR <= req.addr;
		ahb_vif.HBURST <= req.burst_type;
		ahb_vif.HMASTLOCK <= req.lock;
		ahb_vif.HPROT <= req.prot;
		ahb_vif.HSIZE <= req.xfer_size;
		ahb_vif.HTRANS <= 2'h2;
		ahb_vif.HWRITE <= req.xact_type;
		ahb_vif.HSEL <= 1'b1;
		do begin
			@(posedge ahb_vif.HCLK);
		end while (!ahb_vif.HREADYOUT);
		/** Data phase **/
		ahb_vif.HTRANS <= 'h0;
		if (req.xact_type == ahb_transaction::WRITE) begin
			ahb_vif.HWDATA <= req.data;	
		end
		/** Wait hreadyout **/
		do begin
			@(posedge ahb_vif.HCLK);
		end while (!ahb_vif.HREADYOUT);
		/** Handshake **/
		$cast(rsp, req.clone());
		rsp.set_id_info(req);
		if (req.xact_type == ahb_transaction::READ) begin
			rsp.data = ahb_vif.HRDATA;
			`uvm_info(get_type_name(), $sformatf("READ! addr = %0h, data = %0h", req.addr, req.data), UVM_LOW);
		end else begin
			`uvm_info(get_type_name(), $sformatf("WRITE! addr = %0h, data = %0h", req.addr, req.data), UVM_LOW);
		end
	endtask

endclass: ahb_driver

