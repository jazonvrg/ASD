module testbench;  
	import uvm_pkg::*;
  	import uart_pkg::*;
	import ahb_pkg::*;
  	import test_pkg::*;

  	ahb_if ahb_vif();
	uart_if uart_vif();

	uart_top dut(// AHB Interface
		     .HCLK(ahb_vif.HCLK),
		     .HRESETN(ahb_vif.HRESETn),
		     .HADDR(ahb_vif.HADDR),
		     .HTRANS(ahb_vif.HTRANS),
		     .HBURST(ahb_vif.HBURST),
		     .HSIZE(ahb_vif.HSIZE),
		     .HPROT(ahb_vif.HPROT),
		     .HWRITE(ahb_vif.HWRITE),
		     .HSEL(ahb_vif.HSEL),
		     .HWDATA(ahb_vif.HWDATA),
		     .HREADYOUT(ahb_vif.HREADYOUT),
		     .HRDATA(ahb_vif.HRDATA),
		     .HRESP(ahb_vif.HRESP),
		     // UART Interface
		     .uart_rxd(uart_vif.tx),
		     .uart_txd(uart_vif.rx),
		     // Interrupt
		     .interrupt(ahb_vif.interrupt)
		     );
	
	initial begin
		ahb_vif.HCLK = 0;
		forever begin
			#5ns;
			ahb_vif.HCLK = ~ahb_vif.HCLK;	
		end
	end
	
	initial begin
		ahb_vif.HRESETn = 1'b0;
		#10ns ahb_vif.HRESETn = 1'b1;
	end

 	initial begin
    		uvm_config_db#(virtual ahb_if)::set(uvm_root::get(), "uvm_test_top", "ahb_vif", ahb_vif);
		uvm_config_db#(virtual uart_if)::set(uvm_root::get(), "uvm_test_top", "uart_vif", uart_vif);

    		run_test();
  	end

endmodule


