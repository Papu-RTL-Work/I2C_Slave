
// i2c_slave_controller testbench

`timescale 1ns/1ps
module i2c_slave_controller_tb;

	// signal declaration
	reg  rst     ; // active high reset
	reg  i2c_scl ; // serial clock line
	reg  data_bit; // regester to store data_bit for sda_line
	wire i2c_sda ; // serial data line
	
	
	// i2c_slave_controller instatiation
	i2c_slave_controller i2c_slave_controller_inst
	(.i2c_rst (rst)    , // global reset signal
	 .i2c_scl (i2c_scl), // serial clock line
	 .i2c_sda (i2c_sda)  // serial data line
			          );
							
	// Initialize all the inputs
	task initialize;
		begin
			data_bit = 1'b0;
		end
	endtask
	
	// clock generation logic
	initial
		begin
			i2c_scl = 1'b1;
			forever
				#5 i2c_scl = ~i2c_scl;
		end
		
	// task reset
	task reset;
		begin
			rst = 1'b1;
			#15;
			rst = 1'b0;
		end
	endtask
	
	assign i2c_sda = !i2c_slave_controller_inst.i2c_slave_fsm_inst.enable ? data_bit : 1'bz;
	
	// logic to verify i2c_slave_controller
	initial
		begin
			initialize     ;
			reset          ;
			data_bit = 1'b0; #10;
			
			// address transfer to i2c_sda port
			data_bit = 1'b1; #10;
			data_bit = 1'b0; #10;
			data_bit = 1'b1; #10;
			data_bit = 1'b0; #10;
			data_bit = 1'b1; #10;
			data_bit = 1'b0; #10;
			data_bit = 1'b1; #10;
			data_bit = 1'b0; #30; // write logic
			
			// data transfer to i2c_sda port for write operation
			data_bit = 1'b1; #10;
			data_bit = 1'b1; #10;
			data_bit = 1'b0; #10;
			data_bit = 1'b0; #10;
			data_bit = 1'b1; #10;
			data_bit = 1'b0; #10;
			data_bit = 1'b1; #15;
			
			// start detection logic
			data_bit = 1'b0; #10;
			
			// address transfer to i2c_sda port
			data_bit = 1'b1; #10;
			data_bit = 1'b0; #10;
			data_bit = 1'b1; #10;
			data_bit = 1'b0; #10;
			data_bit = 1'b1; #10;
			data_bit = 1'b0; #10;
			data_bit = 1'b1; #10;
			data_bit = 1'b1; #10; // read logic
			
			// data read from slave ram
			#95;
			data_bit = 1'b0; 
			#30;
			$finish;
		end
		
endmodule
