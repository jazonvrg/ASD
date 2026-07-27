class TX_16x_5bits_data_test extends uart_base_test;
	`uvm_component_utils(TX_16x_5bits_data_test)
	
	uart_sequence seq;
	uvm_status_e status;
	int prt_mode[] = '{2'b00, 2'b01, 2'b10};
	int dt_width[] = '{5, 6, 7, 8};
	int stp_bit[] = '{1, 2};
	int prt_error[] = '{1'b0, 1'b1};
	int bd_rate[] = '{2400, 4800, 9600, 19200, 38400, 76800, 115200};
	int custom_baud_rate;
	logic [`AHB_DATA_WIDTH-1:0] rdata;

	function new(string name = "TX_16x_5bits_data_test", uvm_component parent);
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
			foreach(stp_bit[i_stp]) begin
				foreach(prt_error[i_error]) begin
					$display("============================================================================================================================");
					$display("=================================================  ### TX UART | 16x  ###  =================================================");
					$display("============================================================================================================================");
					foreach(bd_rate[i_bd]) begin
						if (cfg.randomize() with {parity_mode == prt_mode[i_prt]; 
									  data_width == 5;
                				                          num_of_stop_bit == stp_bit[i_stp];
									  ovsmpl == X16;
                                				          parity_error == prt_error[i_error];
             	                        				  uart_mode == TX;
									  baud_rate == bd_rate[i_bd];}) begin
							`uvm_info("run_phase", $sformatf("Configuration randomize is: \n%0s", cfg.sprint()), UVM_LOW);
						end else begin
							`uvm_fatal("run_phase", $sformatf("Randomize failure!"));
						end
						run_process();
					end
					repeat (5) begin
						do begin
							custom_baud_rate = $urandom_range(1000, 150000);
						end while (custom_baud_rate inside {bd_rate});
						if (cfg.randomize() with {parity_mode == prt_mode[i_prt]; 
									  data_width == 5;
                				                          num_of_stop_bit == stp_bit[i_stp];
									  ovsmpl == X16;
                                				          parity_error == prt_error[i_error];
             	                        				  uart_mode == TX;
									  baud_rate == custom_baud_rate;}) begin
							`uvm_info("run_phase", $sformatf("Configuration randomize is: \n%0s", cfg.sprint()), UVM_LOW);
						end else begin
							`uvm_fatal("run_phase", $sformatf("Randomize failure!"));
						end
						run_process();
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
				default: cfg.divisor = 100000000 / (cfg.baud_rate * cfg.ovsmpl);
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
				default: cfg.divisor = 100000000 / (cfg.baud_rate * cfg.ovsmpl);
			endcase
		end		
	endfunction: calc_divisor

	virtual task run_process();
		calc_divisor(cfg);
		seq.start(env.uart_agt.seq);
		if (cfg.ovsmpl == uart_configuration::X16) begin
			regmodel.MDR.write(status, {31'h0, 1'b0});
		end else begin
			regmodel.MDR.write(status, {31'h0, 1'b1});
		end
		regmodel.DLL.write(status, {24'h0, cfg.divisor[7:0]});
		regmodel.DLH.write(status, {24'h0, cfg.divisor[15:8]});
		if (cfg.parity_mode != uart_configuration::NONE) begin
			if (cfg.parity_mode == uart_configuration::ODD) regmodel.LCR.write(status, {26'h0, 1'b1, 1'b0, 1'b1, 1'(cfg.num_of_stop_bit - 1), 2'(cfg.data_width - 5)});
			else regmodel.LCR.write(status, {26'h0, 1'b1, 1'b1, 1'b1, 1'(cfg.num_of_stop_bit - 1), 2'(cfg.data_width - 5)});
		end else regmodel.LCR.write(status, {26'h0, 1'b1, 1'b0, 1'b0, 1'(cfg.num_of_stop_bit - 1), 2'(cfg.data_width - 5)});
		regmodel.TBR.write(status, $urandom_range(0, 8'h1F));
		do begin
			regmodel.FSR.read(status, rdata);
		end while (rdata[1] == 1'b0);
	endtask: run_process

endclass
