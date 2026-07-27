`uvm_analysis_imp_decl(_tx)
`uvm_analysis_imp_decl(_rx)
`uvm_analysis_imp_decl(_ahb)

class uart_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(uart_scoreboard)

	uvm_analysis_imp_tx #(uart_transaction, uart_scoreboard) uart_tx_export;
	uvm_analysis_imp_rx #(uart_transaction, uart_scoreboard) uart_rx_export;
	uvm_analysis_imp_ahb #(ahb_transaction, uart_scoreboard) ahb_export; 

	// q_tx (TBR AHB -> DUT -> UART VIP-TXD)
	// q_rx (UART VIP-RXD -> DUT -> RBR AHB)
	logic [7:0] q_tx[$], q_rx[$];
	uart_configuration cfg;
	logic [7:0] mask, exp, act_data;
	logic parity_error_flag, rx_empty_flag, rx_full_flag, tx_empty_flag, tx_full_flag;
	logic [4:0] exp_FSR, act_FSR;
	logic [`AHB_DATA_WIDTH-1:0] exp_ahb, act_ahb;
	logic en_fc = 1'b1;

	function new(string name = "uart_scoreboard", uvm_component parent);
		super.new(name, parent);
		/*parity_error_flag = 1'b0;
		rx_empty_flag = 1'b1;
		rx_full_flag = 1'b0;
		tx_empty_flag = 1'b1;
		tx_full_flag = 1'b0;*/
	//	UART_GROUP = new();
	endfunction: new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("build_phase", "Entered...", UVM_LOW);
		uart_tx_export = new("uart_tx_export", this);
		uart_rx_export = new("uart_rx_export", this);
		ahb_export = new("ahb_export", this);
		if (!uvm_config_db#(uart_configuration)::get(this, "", "cfg", cfg)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get cfg from uvm_config_db"))
		end
		`uvm_info("build_phase", "Exiting...", UVM_LOW);
	endfunction: build_phase

	function void write_tx(uart_transaction act);
		mask = (1 << cfg.data_width) - 1;
		if (q_tx.size() > 0) begin
			exp = q_tx.pop_front();
			/*update_fifo();
			update_parity_status(act);*/
			`uvm_info("write_ahb", $sformatf("UART SIGNAL COMPARATIVE"), UVM_LOW)
			$display("============================================================================================================================");
			if ((act.data & mask) == (exp & mask)) begin
				`uvm_info(get_type_name(), $sformatf("PASSED! Signal is matching. Exp: %8b, Act: %8b", exp & mask, act.data & mask), UVM_LOW);
			end else begin
				`uvm_error(get_type_name(), $sformatf("FAILED! Signal is not matching. Exp: %8b, Act: %8b", exp & mask, act.data & mask));
			end
			$display("============================================================================================================================");
		end
	endfunction: write_tx
	
	function void write_rx(uart_transaction trans);
		`uvm_info("write_rx", $sformatf("Add RX's drive trans into queue"), UVM_LOW)
		q_rx.push_back(trans.data);
		/*update_fifo();
		update_parity_status(trans);*/
	endfunction: write_rx
	
	function void write_ahb(ahb_transaction trans);
		if (trans.addr == 10'h018 && trans.xact_type == ahb_transaction::WRITE) begin // TBR
			`uvm_info("write_rx", $sformatf("Add AHB's drive trans into queue"), UVM_LOW)
			q_tx.push_back(trans.data[7:0]);
			//update_fifo();
		end else if (trans.addr == 10'h01C && trans.xact_type == ahb_transaction::READ) begin // RBR
			`uvm_info("write_ahb", $sformatf("UART SIGNAL COMPARATIVE"), UVM_LOW)
			mask = (1 << cfg.data_width) - 1;
			if (q_rx.size() > 0) begin
				exp = q_rx.pop_front();
				//update_fifo();
				act_data = trans.data[7:0];
				$display("============================================================================================================================");
				if ((act_data & mask) == (exp & mask)) begin
					`uvm_info(get_type_name(), $sformatf("PASSED! Signal is matching. Exp: %8b, Act: %8b", exp & mask, act_data & mask), UVM_LOW);
				end else begin
					`uvm_error(get_type_name(), $sformatf("FAILED! Signal is not matching. Exp: %8b, Act: %8b", exp & mask, act_data & mask));
				end
				$display("============================================================================================================================");
			end
		end else if (trans.addr == 10'h014) begin
			/*
			if (trans.xact_type == ahb_transaction::WRITE) begin
				parity_error_flag = 0;	
			end else begin
				`uvm_info("write_ahb", $sformatf("AHB DATA COMPARATIVE"), UVM_LOW)
				exp_FSR = {parity_error_flag, rx_empty_flag, rx_full_flag, tx_empty_flag, tx_full_flag};
				act_FSR = trans.data[4:0];
				$display("============================================================================================================================");
				if (act_FSR == exp_FSR) begin
					`uvm_info(get_type_name(), $sformatf("PASSED! Signal is matching. Exp: %5b, Act: %5b", exp_FSR, act_FSR), UVM_LOW);
				end else begin
					`uvm_error(get_type_name(), $sformatf("FAILED! Signal is not matching. Exp: %5b, Act: %5b", exp_FSR, act_FSR));
				end
				$display("============================================================================================================================");
			end*/
		end else if (trans.addr >= 10'h020 && trans.addr <= 10'h3FF) begin
			/*if (trans.xact_type == ahb_transaction::READ) begin
				`uvm_info("write_ahb", $sformatf("AHB DATA COMPARATIVE"), UVM_LOW)
				exp_ahb = 32'hFFFF_FFFF;
				act_ahb = trans.data;
				$display("============================================================================================================================");
				if (act_ahb == exp_ahb) begin
					`uvm_info(get_type_name(), $sformatf("PASSED! Signal is matching. Exp: %0h, Act: %0h", exp_ahb, act_ahb), UVM_LOW);
				end else begin
					`uvm_error(get_type_name(), $sformatf("FAILED! Signal is not matching. Exp: %0h, Act: %0h", exp_ahb, act_ahb));
				end
				$display("============================================================================================================================");
			end	*/
		end
	endfunction: write_ahb
	
	/*
	virtual function void update_fifo();
		if (!q_tx.size()) begin
			tx_empty_flag = 1;
			tx_full_flag = 0;
		end else if (q_tx.size() == 16) begin
			tx_empty_flag = 0;
			tx_full_flag = 1;
		end else begin
			tx_empty_flag = 0;
			tx_full_flag = 0;
		end

		if (!q_rx.size()) begin
			rx_empty_flag = 1;
			rx_full_flag = 0;
		end else if (q_rx.size() == 16) begin
			rx_empty_flag = 0;
			rx_full_flag = 1;
		end else begin
			rx_empty_flag = 0;
			rx_full_flag = 0;
		end
	endfunction: update_fifo
	
	virtual function void update_parity_status(uart_transaction trans);
		if (trans.parity) begin
			parity_error_flag = 1'b1;
		end else begin
			parity_error_flag = 1'b0;
		end
	endfunction: update_parity_status*/

endclass: uart_scoreboard
