`include algorithm.v

module router(
	// outputs
  output reg [4:0][2:0] capacity_out,	// mige ke buffer haye man cheghad zarfiat daran
  output reg [4:0][31:0] data_out,		// bus haye khorooji!
  output reg [4:0] write_out_signal,	// signal write ke be routere badi mige ke "mikham be to data bedam"
  output reg [4:0] ack_out,				// signal ack
	//inputs
  input [4:0][2:0] capacity_in,		// hamin balaye ha, faghat barAx :)
  input [4:0][31:0] data_in,		// hamin balaye ha, faghat barAx :)
  input [4:0] write_in_signal,		// hamin balaye ha, faghat barAx :)
  input [4:0] ack_in,				// hamin balaye ha, faghat barAx :)
  
  input clock
)

  parameter my_id, dim_x,dim_y; // confige router ,ke bo'd haye shabake va IDe router ro az biroon set mishan

  reg [4:0][31:0] current_package; // packageE ke gharaar hast ersal beshe
  reg [2:0] current_package_size; // size packageE ke gharaar hast ersal beshe
  reg [2:0] current_flit; // shomare flitE ke gharaar hast ersal beshe
  reg [2:0] last_port, next_port; 	// "last_port" shomareye bufferE ast ke package raa az oon khoondim
									// "next_port" shomareye routere badi hast ke in adad baa estefade as module "algorithm" be dast miad
	// voroodi va khorooji haye buffer ha
  wire [4:0] buffer_ready;
  reg [4:0] next_signal;
  wire [4:0][31:0] buffer_data_out;
  integer iter;
  
  wire [31:0]demux_din; // dataE ke gharaar ast rooye bus rikhte shavad
  
  reg [1:0] state; 	// 0 : ready for next package
					// 1 : writing on bus
					// 2 : wait for ack

  genvar i;
  generate 
    for(i=0;i<5;++i)
    begin
      buffer buff(data_in[i], write_in_signal[i], next_signal[i], capacity_out[i], buffer_data_out[i], buffer_ready[i]);
    end
  endgenerate
  
  demux dmx(demux_din ,next_port , data_out);
  
  always @(ack_in)
	begin
		if(state == 2 && !ack_in[next_port])
		begin
		 current_flit = 0;
		 state = 0;
	end

  // for sending packet
  always @(posedge clock)
  begin
    write_signal = 0;
	//////////////////////////////////////////////////////////// STATE 0
    if(state == 0)
    begin
      for(iter = 0 ; iter < 5 ; iter = iter+1): finding // peydaa kardane bufferi ke data daarad va maghsade aan jaa baraaye aan darad
      begin
        if(buffer_ready[iter])
        begin
          current_package[0] = buffer_data_out[iter];
          dest = currentpackage[0][dest_address_beg_index:dest_address_end_index];
	      current_package_size = currentpackage[0][package_size_beg_index:package_size_end_index];
          next_port = algorithm.find_next(my_id, dest, dim_x, dim_y);
	      if(current_package_size <= capacity_in[next_port])
          begin
        	last_port = iter;
			state = 1;
			current_flit = 0;
        	disable finding;
		  end
        end
      end
	// now we get this packet from buffer
      for(iter = 0; iter < current_package_size; iter = iter + 1)
      begin
        next_signal[last_port] = 0;
    	current_package[iter] = buffer_data_out[last_port];
		next_signal[last_port] = 1;		
      end 
    end
	////////////////////////////////////////////////////////// STATE 1
	else if(state == 1)
	  begin
		write_out_signal[next_port] = 0;
		demux_din = current_package[current_flit];
		write_out_signal[next_port] = 1;
		current_flit = current_flit + 1;
		if(current_flit == current_package_size)
			state = 2;
	  end
	////////////////////////////////////////////////////////// STATE 2
	else if(state == 2) 
	begin
	  if(!ack_in[next_port])// haalati ke baste dorost ferestadeh nashode bashad
	    begin
	      state = 1;
		  current_flit = 0;
		end
	  else // haalati ke baste dorost ferestadeh shode bashad
		begin
		  state = 0;
		end
	end 
	////////////////////////////////////////////////////////////
  end
endmodule
  
  



  
