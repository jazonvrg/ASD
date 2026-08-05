class error_parity_test extends uart_base_test;
	`uvm_component_utils(error_parity_test)
	
	uart_sequence seq;
	uvm_status_e status;
	/*
	int prt_mode[] = '{2'b01, 2'b10};
	int dt_width[] = '{5, 6, 7, 8};
	int stp_bit[] = '{1, 2};
	int prt_error[] = '{1'b0, 1'b1};
	int bd_rate[] = '{2400, 4800, 9600, 19200, 38400, 76800, 115200};
	int ovs[] = '{1'b0, 1'b1};
	*/
	int prt_mode[] = '{2'b01};
	int dt_width[] = '{5};
	int stp_bit[] = '{1};
	int prt_error[] = '{1'b0};
	int bd_rate[] = '{2400};
	int ovs[] = '{1'b0};
	int custom_baud_rate;
	logic [`AHB_DATA_WIDTH-1:0] rdata;

	function new(string name = "error_parity_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		reset();
		seq = uart_sequence::type_id::create("seq");
		foreach(prt_mode[i_prt]) begin
			foreach(dt_width[i_dt]) begin
				foreach(stp_bit[i_stp]) begin
					foreach(ovs[i_ovs]) begin
						$display("============================================================================================================================");
						$display("=================================================  ### ERROR PARITY  ###  ==================================================");
						$display("============================================================================================================================");
						foreach(bd_rate[i_bd]) begin
							if (cfg.randomize() with {parity_mode == prt_mode[i_prt]; 
										  data_width == dt_width[i_dt];
                					                          num_of_stop_bit == stp_bit[i_stp];
										  ovsmpl == ovs[i_ovs];
                                					          parity_error == ERROR;
             	                        					  uart_mode == RX;
										  baud_rate == bd_rate[i_bd];}) begin
								`uvm_info("run_phase", $sformatf("Configuration randomize is: \n%0s", cfg.sprint()), UVM_LOW);
							end else begin
								`uvm_fatal("run_phase", $sformatf("Randomize failure!"));
							end
							run_process();
						end
						/*repeat (5) begin
							do begin
								custom_baud_rate = $urandom_range(118, 6250000);
							end while (custom_baud_rate inside {bd_rate});
							if (cfg.randomize() with {parity_mode == prt_mode[i_prt]; 
										  data_width == dt_width[i_dt];
                					                          num_of_stop_bit == stp_bit[i_stp];
										  ovsmpl == ovs[i_ovs];
                                					          parity_error == ERROR;
             	                        					  uart_mode == RX;
										  baud_rate == custom_baud_rate;}) begin
								`uvm_info("run_phase", $sformatf("Configuration randomize is: \n%0s", cfg.sprint()), UVM_LOW);
							end else begin
								`uvm_fatal("run_phase", $sformatf("Randomize failure!"));
							end
							run_process();
						end*/
					end
				end
			end
		end
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
			if (cfg.parity_mode == uart_configuration::ODD) regmodel.LCR.write(status, {26'h0, 1'b1, 1'b0, 1'b1, 1'(cfg.num_of_stop_bit - 1), 2'(cfg.data_width - 5)});
			else regmodel.LCR.write(status, {26'h0, 1'b1, 1'b1, 1'b1, 1'(cfg.num_of_stop_bit - 1), 2'(cfg.data_width - 5)});
		end else regmodel.LCR.write(status, {26'h0, 1'b1, 1'b0, 1'b0, 1'(cfg.num_of_stop_bit - 1), 2'(cfg.data_width - 5)});
		// ERROR
		env.scb.selection = 5.1;	
		wait_time(cfg);
		seq.start(env.uart_agt.seq);
		wait_monitor(cfg);
		regmodel.FSR.read(status, rdata);
		regmodel.RBR.read(status, rdata);
		// W1C
		env.scb.selection = 5.2;
		regmodel.FSR.write(status, {27'h0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0});
		wait_monitor(cfg);
		regmodel.RBR.read(status, rdata);
	endtask: run_process

endclass
