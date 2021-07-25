
// I2C RAM Memory
module i2c_ram(
	input            clock_in, // i2c_serial clock signal 
	input            reset_in, // global reset signal
	input            wr_en_in, // if asserted then master writes 8bit data to ram
	input            rd_en_in, // if asserted then master reads 8bit data from ram
	input      [6:0] addr_in , // address coming from i2c slave module
	input      [7:0] data_in , // input data coming from i2c slave module
	output reg [7:0] data_out  // output data going to i2c slave module
									);
					
	// reg_file declaration
	reg [7:0] reg_file[0:127];
	integer i;

	// write data to reg_file at negedge of clk_in with no reset
	always @(posedge reset_in or negedge clock_in)
		begin
			if(reset_in) // if reset initialise all the locations of ram to 0
				begin
					for(i=0; i<128; i=i+1)
						reg_file[i] <= 8'd0;
				end
			else 
				begin
				   // write operation
					if(wr_en_in)
						reg_file[addr_in] <= data_in          ; // data written into ram based on addr_in
					else
						reg_file[addr_in] <= reg_file[addr_in]; // data will not written into ram
				end
		end
	
	// read data from reg_file at posedge clk_in with no reset
	always @(posedge reset_in or posedge clock_in)
		begin
			if(reset_in)
				data_out <= 8'd0; // at high reset assign data_out to 0
			else
				// read opeartion
				if(rd_en_in)
					data_out <= reg_file[addr_in]; // read data from ram based on addr_in
				else
					data_out <= data_out         ; // data_out will be same
		end
	
endmodule
