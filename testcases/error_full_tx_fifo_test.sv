class error_full_tx_fifo_test extends uart_base_test;
	`uvm_component_utils(error_full_tx_fifo_test)
	
	uart_sequence seq;
	uvm_status_e status;
	int n;
	logic [`AHB_DATA_WIDTH-1:0] rdata;

	function new(string name = "full_tx_fifo_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		reset();
		seq = uart_sequence::type_id::create("seq");
		$display("============================================================================================================================");
		$display("===============================================  ### RESP FULL TX FIFO  ###  ===============================================");
		$display("============================================================================================================================");
		if (cfg.randomize() with {uart_mode == RX;}) begin
			`uvm_info("run_phase", $sformatf("Configuration randomize is: \n%0s", cfg.sprint()), UVM_LOW);
		end else begin
			`uvm_fatal("run_phase", $sformatf("Randomize failure!"));
		end
		run_process();
		phase.drop_objection(this);
	endtask: run_phase

	virtual function void calc_divisor(uart_configuration cfg);
		if (cfg.ovsmpl == uart_configuration::X16) begin
			case (cfg.baud_rate)
				2400: cfg.divisor = 2604;
				4800: cfg.divisor = 1302;
				9600: cfg.divisor = 651;
				19200: cfg.divisor = 325;
				38400: cfg.divisor = 163;
				76800: cfg.divisor = 81;
				115200: cfg.divisor = 54;
				default: cfg.divisor = 100000000 / (cfg.baud_rate * 16);
			endcase
		end else begin
			case (cfg.baud_rate)
				2400: cfg.divisor = 3205;
				4800: cfg.divisor = 1602;
				9600: cfg.divisor = 801;
				19200: cfg.divisor = 401;
				38400: cfg.divisor = 200;
				76800: cfg.divisor = 100;
				115200: cfg.divisor = 67;
				default: cfg.divisor = 100000000 / (cfg.baud_rate * 13);
			endcase
		end		
	endfunction: calc_divisor

	virtual task wait_time(uart_configuration cfg);
		int calc_time;
		calc_time = ((15000 / cfg.baud_rate) + 1);
		#(calc_time * 1ms);
	endtask: wait_time
	
	virtual task wait_monitor(uart_configuration cfg);
		int calc_time;
		calc_time = (2000000 / cfg.baud_rate) + 1;	
		#(calc_time * 1us);
	endtask: wait_monitor

	virtual task read_limit(uart_configuration cfg);
		int calc_time;
		if (cfg.ovsmpl == uart_configuration::X16) begin
			calc_time = (1000000 / (cfg.baud_rate * 16)) + 1;	
		end else begin
			calc_time = (1000000 / (cfg.baud_rate * 13)) + 1;	
		end
		#(calc_time * 1us);
	endtask: read_limit

	virtual task run_process();
		calc_divisor(cfg);
		if (cfg.ovsmpl == uart_configuration::X16) begin
			regmodel.MDR.write(status, {31'h0, 1'b0});
		end else begin
			regmodel.MDR.write(status, {31'h0, 1'b1});
		end
		regmodel.LCR.write(status, 32'h0);
		regmodel.DLL.write(status, {24'h0, cfg.divisor[7:0]});
		regmodel.DLH.write(status, {24'h0, cfg.divisor[15:8]});
		if (cfg.parity_mode != uart_configuration::NONE) begin
			if (cfg.parity_mode == uart_configuration::ODD) regmodel.LCR.write(status, {26'h0, 1'b0, 1'b0, 1'b1, 1'(cfg.num_of_stop_bit - 1), 2'(cfg.data_width - 5)});
			else regmodel.LCR.write(status, {26'h0, 1'b0, 1'b1, 1'b1, 1'(cfg.num_of_stop_bit - 1), 2'(cfg.data_width - 5)});
		end else regmodel.LCR.write(status, {26'h0, 1'b0, 1'b0, 1'b0, 1'(cfg.num_of_stop_bit - 1), 2'(cfg.data_width - 5)});
		n = $urandom_range(17, 27);
		for(int i = 1; i <= n; i = i + 1) begin
			env.scb.selection = (i <= 16) ? 10.2 : 10.1;
			regmodel.TBR.write(status, $urandom_range(0, (1 << cfg.data_width) - 1));
		end
	endtask: run_process

endclass
