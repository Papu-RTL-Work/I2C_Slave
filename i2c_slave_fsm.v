
// slave interface design

module i2c_slave_fsm(
	input            rst_in          , // global reset signal
   	input            i2c_scl         , // serial clock line
   	inout            i2c_sda         , // serial data line 
	input      [7:0] data_in_from_ram, // data input from RAM 
	output reg       wr_en_to_ram    , // write enable signal to enable writing data to ram
	output reg       rd_en_to_ram    , // read enable signal to enable reading data from ram
	output reg [7:0] data_out_to_ram , // output data to ram
	output reg [7:0] addr_out_to_ram   // address to ram
	                                );

	localparam  STATE_IDLE    = 3'h0 ; // idle
  	localparam  STATE_ADDR    = 3'h1 ; // the slave addr match
	localparam  SEND_ACK      = 3'h2 ; // send ack to master
  	localparam  STATE_READ    = 3'h3 ; // the op=read 
   	localparam  STATE_WRITE   = 3'h4 ; // write the data in the reg 

	reg [3:0] counter ; // counter counts no of clock pulses
	reg [2:0] state   ; // used to define no of states in fsm
	reg       enable  ; // enable or disable the i2c_sda line 
	reg       sda_out ; // internal register for i2c_sda line 
	reg       start   ; // detection of start signal
	reg       stop    ; // detection of stop signal	
	wire      rw_bit  ; // used to detect read or write operation 

	// detect the start signal
	// start detects when sda goes high to low when scl is high
	always @(posedge rst_in or negedge i2c_sda)
		begin
			if(rst_in)
				start <= 1'b0;
			else if((start == 1'b0) && (i2c_scl == 1'b1))
				start <= 1'b1;
			else
				start <= 1'b0;
		end
		
	// detection of stop signal
	// stop detects when sda goes low to high when scl is high
	always @(posedge rst_in or posedge i2c_sda)
		begin
			if(rst_in)
				stop <= 1'b0;
			else if((stop == 1'b0) && (i2c_scl == 1'b1))
				stop <= 1'b1;
			else
				stop <= 1'b0;
		end
	
	//	state machine
	assign i2c_sda = (enable == 1'b1) ? sda_out : 1'bz; // tristate logic enabled for master read and ack state
	assign rw_bit  = (addr_out_to_ram[0]);              // rw_bit =1 for read and =0 for write
	
	//============STATE-MACHINE=============	
	always @(posedge rst_in or negedge i2c_scl)
		begin
			if(rst_in) // if asserted state goes to idle state
				begin
					state        <= STATE_IDLE;
					counter      <= 4'd0      ;
					wr_en_to_ram <= 1'b0      ;
					rd_en_to_ram <= 1'b0      ;
				end
			else 
				begin
					case(state)
						STATE_IDLE  : begin  // idle state
								wr_en_to_ram <= 1'b0;
								rd_en_to_ram <= 1'b0;
								if(start) // if start detects goes to ADDR_STATE else IDLE_STATE
									begin
										state   <= STATE_ADDR;
										counter <= 4'd7      ;
									end
								else if(stop) 
									state <= STATE_IDLE;
								else 
									state <= STATE_IDLE;
							      end   // end idle state
										  
						STATE_ADDR  : begin // addr state
								if(counter == 4'd0)
									state <= SEND_ACK;											
								else
									begin
										counter <= counter - 4'd1;
										state   <= STATE_ADDR    ;
									end
							      end   // end addr state
										  
						SEND_ACK    : begin // send ack to master 
								if(rw_bit == 1'b1) 
									begin
										counter      <= 4'd7      ;
										state        <= STATE_READ;
										rd_en_to_ram <= 1'b1      ;
									end
								else if(rw_bit == 1'b0)
									begin
										counter <= 4'd7       ;
										state   <= STATE_WRITE;
									end
								else
									state <= STATE_IDLE;
							      end   // end send ack state
										  
						STATE_READ  : begin // master read data from slave
								rd_en_to_ram <= 1'b0;
								if(counter == 4'd0)
									state <= STATE_IDLE;
								else
									begin
										state   <= STATE_READ    ;
										counter <= counter - 4'd1;  
									end
							      end   // end read state
										  
						STATE_WRITE : begin // master write data into slave 
								if(counter == 4'd0)
									begin
										state        <= STATE_IDLE;
										wr_en_to_ram <= 1'b1      ;
									end
								else
									begin
										state   <= STATE_WRITE   ;
										counter <= counter - 4'd1;
									end
							      end   // end write state
					endcase
				end
		end
		
	// state machine to write data & addr from ram at posedge of i2c_scl with no reset
	// read data from ram assigned to i2c_sda at posedge of i2c_scl with no reset
	always @(posedge rst_in or posedge i2c_scl)
		begin
			if(rst_in)
				begin
					enable          <= 1'b1;
					sda_out         <= 1'b1;
					data_out_to_ram <= 8'd0;
					addr_out_to_ram <= 8'd0;
				end
			else
				begin
					case(state)
						STATE_IDLE  : begin // idle state
								enable  <= 1'b0;
							      end   // end idle
										  
						STATE_ADDR  : begin // addr state
								enable                   <= 1'b0   ;
								addr_out_to_ram[counter] <= i2c_sda; // read addr by slave
							      end   // end addr state
										  
						SEND_ACK    : begin // ack state slave send ack bit to master
								enable  <= 1'b1 ;
								sda_out <= 1'b0 ;
							      end   // end ack state
										  
						STATE_READ  : begin // read state
								enable  <= 1'b1                     ;
								sda_out <= data_in_from_ram[counter]; // master read data from ram 
							      end   // end read state
										  
						STATE_WRITE : begin // write state
								enable                   <= 1'b0    ;
								data_out_to_ram[counter] <= i2c_sda ; // master write data to ram 
							      end   // end write state
					endcase
				end
		end
	
endmodule
