class uart_monitor extends uvm_monitor;
	`uvm_component_utils(uart_monitor)

	virtual uart_if uart_vif;
	virtual ahb_if ahb_vif;
	uart_configuration cfg;
	uart_transaction tx, rx;
	uvm_analysis_port #(uart_transaction) uart_observed_port_tx;
	uvm_analysis_port #(uart_transaction) uart_observed_port_rx;
	int cnt_HIGH_tx, cnt_HIGH_rx;
	int n, len;
	logic act, exp;

	function new(string name = "uart_monitor", uvm_component parent);
		super.new(name, parent);
		uart_observed_port_tx = new("uart_observed_port_tx", this);
		uart_observed_port_rx = new("uart_observed_port_rx", this);
	endfunction: new

	function void build_phase(uvm_phase phase);
		`uvm_info("build_phase", "Entered...", UVM_LOW)
		super.build_phase(phase);
		if (!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif", uart_vif)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_if from uvm_config_db"));	
		end
		if (!uvm_config_db#(virtual ahb_if)::get(this, "", "ahb_vif", ahb_vif)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get ahb_if from uvm_config_db"));	
		end
		if (!uvm_config_db#(uart_configuration)::get(this, "", "cfg", cfg)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_configuration from uvm_config_db"));	
		end
		`uvm_info("build_phase", "Exiting...", UVM_LOW)
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		`uvm_info("run_phase", "Entered...", UVM_LOW)
		fork
			forever begin
				thread_tx();
			end
			forever begin
				thread_rx();
			end
		join
		`uvm_info("run_phase", "Exiting...", UVM_LOW)
	endtask: run_phase

	virtual task baud_period(int len);
		case (cfg.ovsmpl)
			uart_configuration::X16: n = cfg.divisor * 16;
			default: n = cfg.divisor * 13;
		endcase
		repeat (n / len) begin
			@(posedge ahb_vif.HCLK);
		end
	endtask

	virtual task thread_tx();
		// SETUP
		tx = uart_transaction::type_id::create("tx");
		cnt_HIGH_tx = 0;
		// START
		@(negedge uart_vif.tx);
		baud_period(2);
		baud_period(1);
		// DATA	
		for(int i = 0; i < cfg.data_width; i = i + 1) begin
			tx.data[i] = uart_vif.tx;
			if (uart_vif.tx) begin
				cnt_HIGH_tx = cnt_HIGH_tx + 1;
			end
//			$display("%t: [thread_tx] i = %0d, uart_vif.tx = %0b", $time, i, uart_vif.tx);
			baud_period(1);
		end
		// PARITY
//		`uvm_info(get_type_name(), $sformatf("%0d", cnt_HIGH_tx), UVM_LOW);
		case (cfg.parity_mode)
			uart_configuration::ODD: begin
				if (cnt_HIGH_tx % 2 == 0) begin
					exp = 1'b1;
				end else begin
					exp = 1'b0;
				end
			end
			uart_configuration::EVEN: begin
				if (cnt_HIGH_tx % 2 == 0) begin
					exp = 1'b0;
				end else begin
					exp = 1'b1;
				end
			end
			default: begin
			end
		endcase	
		if (cfg.parity_mode != uart_configuration::NONE) begin
			act = uart_vif.tx;
			if (cfg.parity_error == uart_configuration::ERROR) begin
				if (act != exp) begin
					tx.parity = 1'b1;
				end else begin
					tx.parity = 1'b0;
				end
//				`uvm_info("thread_tx ERROR", $sformatf("%s", cfg.parity_error.name()), UVM_LOW); 
			end else begin
				if (act == exp) begin
					tx.parity = 1'b1;
				end else begin
					tx.parity = 1'b0;
				end
//				`uvm_info("thread_tx NORMAL", $sformatf("%s", cfg.parity_error.name()), UVM_LOW); 
			end
			baud_period(1);
		end
		// STOP
		for(int i = 0; i < cfg.num_of_stop_bit; i = i + 1) begin 
			baud_period(1);
		end
		uart_observed_port_rx.write(tx);
	endtask: thread_tx
	
	virtual task thread_rx();
		// SETUP
		rx = uart_transaction::type_id::create("rx");
		cnt_HIGH_rx = 0;
		// START
		@(negedge uart_vif.rx);
		baud_period(2);
		baud_period(1);
		// DATA	
		for(int i = 0; i < cfg.data_width; i = i + 1) begin
			rx.data[i] = uart_vif.rx;
			if (uart_vif.rx) begin
				cnt_HIGH_rx = cnt_HIGH_rx + 1;
			end
//			$display("%t: [thread_rx] i = %0d, uart_vif.tx = %0b", $time, i, uart_vif.tx);
			baud_period(1);
		end
		// PARITY
//		`uvm_info(get_type_name(), $sformatf("%0d", cnt_HIGH_rx), UVM_LOW);
		case (cfg.parity_mode)
			uart_configuration::ODD: begin
				if (cnt_HIGH_rx % 2 == 0) begin
					exp = 1'b1;
				end else begin
					exp = 1'b0;
				end
			end
			uart_configuration::EVEN: begin
				if (cnt_HIGH_rx % 2 == 0) begin
					exp = 1'b0;
				end else begin
					exp = 1'b1;
				end
			end
			default: begin
			end
		endcase	
		if (cfg.parity_mode != uart_configuration::NONE) begin
			act = uart_vif.rx;
			if (cfg.parity_error == uart_configuration::ERROR) begin
				if (act != exp) begin
					rx.parity = 1'b1;
				end else begin
					rx.parity = 1'b0;
				end
//				`uvm_info("thread_rx ERROR", $sformatf("%s", cfg.parity_error.name()), UVM_LOW); 
			end else begin
				if (act == exp) begin
					rx.parity = 1'b1;
				end else begin
					rx.parity = 1'b0;
				end
//				`uvm_info("thread_rx NORMAL", $sformatf("%s", cfg.parity_error.name()), UVM_LOW); 
			end
			baud_period(1);
		end
		// STOP
		for(int i = 0; i < cfg.num_of_stop_bit; i = i + 1) begin 
			baud_period(1);
		end
		uart_observed_port_tx.write(rx);
	endtask: thread_rx

endclass: uart_monitor
