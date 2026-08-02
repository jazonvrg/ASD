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
	//logic parity_error_flag, rx_empty_flag, rx_full_flag, tx_empty_flag, tx_full_flag;
	logic exp_FSR, act_FSR;
	logic [`AHB_DATA_WIDTH-1:0] exp_ahb, act_ahb;
	//logic bge_status;
	logic en_fc = 1'b1;

	// selection = 0 - default
	//             1 - full_tx      1.1 LOW   -   1.2 HIGH
	//             2 - empty_txi    2.1 HIGH  -   2.2 LOW
	//             3 - full_rx      3.1 LOW   -   3.2 HIGH
	//             4 - empty_rx	4.1 HIGH  -   4.2 LOW
	//             5 - error_parity 
	//             6 - normal_parity
	//             7 - TX transfer
	//             8 - RX transfer
	real selection = 0;

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
			if (selection == 7) begin
				`uvm_info("write_ahb", $sformatf("TX UART SIGNAL COMPARATIVE"), UVM_LOW)
				$display("============================================================================================================================");
				if ((act.data & mask) == (exp & mask)) begin
					`uvm_info(get_type_name(), $sformatf("PASSED! Signal is matching. Exp: %8b, Act: %8b", exp & mask, act.data & mask), UVM_LOW);
				end else begin
					`uvm_error(get_type_name(), $sformatf("FAILED! Signal is not matching. Exp: %8b, Act: %8b", exp & mask, act.data & mask));
				end
				$display("============================================================================================================================");
			end
		end
	endfunction: write_tx
	
	function void write_rx(uart_transaction trans);
		`uvm_info("write_rx", $sformatf("Add RX's drive trans into queue"), UVM_LOW)
		if (q_rx.size() < 16) q_rx.push_back(trans.data);
	endfunction: write_rx
	
	function void write_ahb(ahb_transaction trans);
		if (trans.addr == 10'h018 && trans.xact_type == ahb_transaction::WRITE) begin // TBR
			`uvm_info("write_rx", $sformatf("Add AHB's drive trans into queue"), UVM_LOW)
			if (q_tx.size() < 16) q_tx.push_back(trans.data[7:0]);
		end else if (trans.addr == 10'h01C && trans.xact_type == ahb_transaction::READ) begin // RBR
			mask = (1 << cfg.data_width) - 1;
			if (q_rx.size() > 0) begin
				exp = q_rx.pop_front();
				if (selection == 8) begin
					`uvm_info("write_ahb", $sformatf("RX UART SIGNAL COMPARATIVE"), UVM_LOW)
					act_data = trans.data[7:0];
					$display("============================================================================================================================");
					if ((act_data & mask) == (exp & mask)) begin
						`uvm_info(get_type_name(), $sformatf("PASSED! Signal is matching. Exp: %8b, Act: %8b", exp & mask, act_data & mask), UVM_LOW);
					end else begin
						`uvm_error(get_type_name(), $sformatf("FAILED! Signal is not matching. Exp: %8b, Act: %8b", exp & mask, act_data & mask));
					end
					$display("============================================================================================================================");
				end
			end
		end else if (trans.addr == 10'h014) begin // FSR
			if (trans.xact_type == ahb_transaction::READ) begin
				if (selection != 0 && selection != 7 && selection != 8) begin
					case (selection)
						6: begin // NORMAL PARITY 
							`uvm_info("normal_parity_compare", $sformatf("ERROR-FREE PARITY COMPARATIVE"), UVM_LOW)
							exp_FSR = 1'b0;
							act_FSR = trans.data[4];
						end
						5: begin // ERROR PARITY
							`uvm_info("error_parity_compare", $sformatf("ERROR PARITY COMPARATIVE"), UVM_LOW)
							exp_FSR = 1'b1;
							act_FSR = trans.data[4];
						end
						4.2: begin // EMPTY RX - LOW
							`uvm_info("empty_rx_fifo_compare", $sformatf("EMPTY RX FIFO COMPARATIVE"), UVM_LOW)
							exp_FSR = 1'b0;
							act_FSR = trans.data[3];
						end
						4.1: begin // EMPTY RX - HIGH
							`uvm_info("empty_rx_fifo_compare", $sformatf("EMPTY RX FIFO COMPARATIVE"), UVM_LOW)
							exp_FSR = 1'b1;
							act_FSR = trans.data[3];
						end
						3.2: begin // FULL RX - HIGH
							`uvm_info("full_rx_fifo_compare", $sformatf("FULL RX FIFO COMPARATIVE"), UVM_LOW)
							exp_FSR = 1'b1;
							act_FSR = trans.data[2];
						end
						3.1: begin // FULL RX - LOW
							`uvm_info("full_rx_fifo_compare", $sformatf("FULL RX FIFO COMPARATIVE"), UVM_LOW)
							exp_FSR = 1'b0;
							act_FSR = trans.data[2];
						end
						2.2: begin // EMPTY TX - LOW
							`uvm_info("empty_tx_fifo_compare", $sformatf("EMPTY TX FIFO COMPARATIVE"), UVM_LOW)
							exp_FSR = 1'b0;
							act_FSR = trans.data[1];
						end
						2.1: begin // EMPTY TX - HIGH
							`uvm_info("empty_tx_fifo_compare", $sformatf("EMPTY TX FIFO COMPARATIVE"), UVM_LOW)
							exp_FSR = 1'b1;
							act_FSR = trans.data[1];
						end
						1.2: begin // FULL TX - HIGH
							`uvm_info("full_tx_fifo_compare", $sformatf("FULL TX FIFO COMPARATIVE"), UVM_LOW)
							exp_FSR = 1'b1;
							act_FSR = trans.data[0];
						end
						1.1: begin // FULL TX - LOW
							`uvm_info("full_tx_fifo_compare", $sformatf("FULL TX FIFO COMPARATIVE"), UVM_LOW)
							exp_FSR = 1'b0;
							act_FSR = trans.data[0];
						end
					endcase
					$display("size = %0d", q_tx.size());
					$display("============================================================================================================================");
					if (exp_FSR == act_FSR) begin
						`uvm_info(get_type_name(), $sformatf("PASSED! Parity error status is correct. Exp: %0b, Act: %0b", exp_FSR, act_FSR), UVM_LOW);
					end else begin
						`uvm_error(get_type_name(), $sformatf("FAILED! Parity error status is not correct. Exp: %0b, Act: %0b", exp_FSR, act_FSR));
					end
					$display("============================================================================================================================");
					/*`uvm_info("write_ahb", $sformatf("AHB DATA COMPARATIVE"), UVM_LOW)
					$display("============================================================================================================================");
					if (exp_FSR != act_FSR) begin
						`uvm_info(get_type_name(), $sformatf("PASSED! Signal is not matching. Exp: %1b, Act: %1b", exp_FSR, act_FSR), UVM_LOW);
					end else begin
						`uvm_error(get_type_name(), $sformatf("FAILED! Signal is matching. Exp: %1b, Act: %1b", exp_FSR, act_FSR));
					end
					$display("============================================================================================================================");
					*/
				end
			end
		end /*else if (trans.addr >= 10'h020 && trans.addr <= 10'h3FF) begin
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
			end	
		end*/
	endfunction: write_ahb

endclass: uart_scoreboard
