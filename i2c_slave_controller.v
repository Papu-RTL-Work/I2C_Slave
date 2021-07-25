
// slave controller design

module i2c_slave_controller(
	input i2c_rst, // global reset signal
	input i2c_scl, // serial clock line
	inout i2c_sda  // serial data line
		    );

	wire 	    wr_en_out_in   ; // i2c_slave wr_en_out to ram wr_en 
	wire        rd_en_out_in   ; // i2c_slave rd_en_out to ram rd_en 
	wire [7:0]  addr_i2c_to_ram; // i2c_slave addr_out to ram addr_in 
	wire [7:0]  data_i2c_to_ram; // i2c_slave data_out to ram data_in
	wire [7:0]  data_ram_to_i2c; // ram data_out to i2c_slave data_in
	
	// Instatiation of i2c_slave_fsm
	i2c_slave_fsm i2c_slave_fsm_inst
	(.rst_in	   (i2c_rst)        , // rst port
         .i2c_scl	   (i2c_scl)        , // scl port
         .i2c_sda          (i2c_sda)        , // sda port
	 .data_in_from_ram (data_ram_to_i2c), // data_in port from ram
	 .wr_en_to_ram     (wr_en_out_in)   , // write enable port
	 .rd_en_to_ram     (rd_en_out_in)   , // read enable port
	 .data_out_to_ram  (data_i2c_to_ram), // data_out port to ram
	 .addr_out_to_ram  (addr_i2c_to_ram)  // addr_out port to ram
	                                   );
							
	// Instatiation of i2c_ram
	i2c_ram i2c_ram_inst
	(.clock_in (i2c_scl)             , // ram clock port
	 .reset_in (i2c_rst)             , // ram reset port
	 .wr_en_in (wr_en_out_in)        , // write enable port
	 .rd_en_in (rd_en_out_in)        , // read enable port
	 .addr_in  (addr_i2c_to_ram[7:1]), // addr_in port from i2c_slave 
	 .data_in  (data_i2c_to_ram)     , // data_in port from i2c_slave
	 .data_out (data_ram_to_i2c)       // data_out port to i2c_slave
	                                );
	
endmodule
