class uart_DLL_reg extends uvm_reg;
	`uvm_object_utils(uart_DLL_reg)

	uvm_reg_field rsvd;
	rand uvm_reg_field DLL;

	function new(string name = "uart_DLL_reg");
		super.new(name, 32, UVM_NO_COVERAGE);
	endfunction: new

	virtual function void build();
		rsvd = uvm_reg_field::type_id::create("rsvd");
		DLL = uvm_reg_field::type_id::create("DLL");

		rsvd.configure(this, 24, 8, "RO", 1'b0, 24'h0, 1, 1, 1);
		DLL.configure(this, 8, 0, "RW", 1'b0, 8'h0, 1, 1, 1);
	endfunction: build

endclass: uart_DLL_reg
