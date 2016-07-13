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
  
  wire [31:0]din;
  
  reg [1:0] state; // 0 : ready for next package , 1 : writing , 2 : wait for ack/nack

  genvar i;
  generate 
    for(i=0;i<5;++i)
    begin
      buffer buff(data_in[i], write_in_signal[i], next_signal[i], capacity_out[i], buffer_data_out[i], buffer_ready[i]);
    end
  endgenerate
  
  demux dmx(din ,next_port , data_out);
  
  always @(ack_in)
	begin
		if(state = 1 && !ack_in[next_port])
		 current_flit = 0;
	end

  // for sending packet
  always @(posedge clock)
  begin
    write_signal = 0;
    if(state == 0)
    begin
      for(iter = 0 ; iter < 5 ; iter = iter+1): finding
      begin
        if(buffer_ready[iter])
        begin
          current_package[0] = buffer_data_out[i];
          dest = currentpackage[0][29-:router_address_size];
	        package_size = currentpackage[0][24:22];
          next_port = algorithm.find_next(my_id, dest, dim_x, dim_y);
	        if(package_size <= capacity_in[next_port])
          begin
        		  last_port = iter;
        		  disable finding;
      		  end
        end
      end
	// now we get this packet from buffer
      for(current_flit = 0; current_flit < package_size; current_flit = current_flit +1)
      begin
        next_signal[last_port] = 0;
    		  current_package[current_flit] = buffer_data_out[last_port];
		    next_signal[last_port] = 1;		
      end 
	    current_flit = 0;
    end
	  else if(state == 1)
		begin
		  write_out_signal[next_port] = 0;
			din = current_package[current_flit];
			write_out_signal[next_port] = 1;
			current_flit = current_flit +1;
			if(current_flit == package_size)
			  state = 2;
		end
	  else if(state == 2)
	  begin
	    if(!ack_in[next_port])
		  begin
		    state = 1;
        current_flit = 0;
      end
      else 
      begin
        state = 0;
      end
	  end 
  end
  begin
    
  end
endmodule
  
  



  
