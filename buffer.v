`include utils.v

module buffer(
  //from writer
  input [31:0] data_in,
  input write,// baa in flag writer be buffer mige ke benevis!
  
  //from reader
  input next, // ba in signal, reader be buffer mige ke data ro rooye khorooji beriz
  
  // for writer
  output reg ack,
  
  //for writer
  output reg [2:0] capacity,
  
  //for reader
  output reg [31:0] data_out,
  output reg ready_for_reader // ba in flag buffer be reader mige ke man alaan baste daram
  );
  
  
  parameter buffer_size = 5; // maximum can be 7!
  // # of filled
  reg [2:0] filled_size;
  // # of existing package
  reg [2:0] package_num;
  // all of buffered data
  reg [31:0] mem [buffer_size - 1:0];
  // this is the main parameters for circular buffer
  reg [2:0] first_index, last_index;
  // just a counter for "loop blocks"
  integer iter;
  // size of input package
  // this parameter is valid while we are in state of "reading input"
  reg[2:0] package_size;
  // id of expected flit
  // this parameter is valid while we are reading input
  reg[2:0] expected_flit_num;
  
  initial
  begin
    package_num = 0;
    expected_flit_num = 0;
    filled_size = 0;
    first_index = 1;
    last_index = 0;
  end
  
  assign data_out = mem[first_index];
  assign ready_for_reader = (package_num > 0);
  
  assign capacity = buffer_size - filled_size;    
    
  always @(posedge clock)
  begin
	if(write)
	begin
		if(expected_flit_num == data_in[flit_num_beg_index:flit_num_end_index])// vaghti ke shomareye flite voroodi hamani bashad ke morede entezar bood
		  begin
			last_index = last_index + 1;
			if(last_index >= buffer_size)
			  begin
				last_index = 0;
			  end
			ack = 0;
			mem[last_index] = data_in;
			filled_size = filled_size +1;
			if(expected_flit_num == 0)
			  package_size = data_in[package_size_beg_index:package_size_end_index];
			expected_flit_num = expected_flit_num + 1;
			if(expected_flit_num >= package_size)
			  begin
				ack = 1;
				expected_flit_num = 0;
				package_num = package_num + 1;
			  end
		  end
		else // vaghti ke yek flit kharej az tartib vared shodeh
		  begin
			last_index = last_index - expected_flit_num; // in yani in ke oonaE ke khoonde boodim ro paak mikonim
			if(last_index < 0)
			  begin
				last_index = last_index + buffer_size;
			  end
			filled_size = filled_size - expected_flit_num;
			expected_flit_num = 0; // in assignment bayad akhar az hame ejra beshe ke man nemidoonam bad az santez ham in ettefagh meiofte ya na
		  end
	  end
  end
        
  always @(posedge clock)
  begin
	if(next)
	begin
		first_index = first_index + 1;
		if(first_index >= buffer_size)
		  begin
			first_index = 0;
		  end
		filled_size = filled_size - 1;
		// in if else baraye ine ke age ye baste be tore kamel az buffer kharej shod package_num ro 1 vahed kam konim
		if(filled_size != 0)
		  begin
			if(mem[first_index][flit_num_beg_index:flit_num_end_index] == 0)
				package_num = package_num - 1
		  end
		else // haalati ke buffer kamelan khaliye ---- tavajjoh konid ke in "else" elzamist!!
		  begin
			package_num = 0;
		  end
	end
  end
endmodule

module testbuffer;

reg write;
reg next;
reg [31:0] data_in;


wire [31:0] data_out;
wire [2:0] capacity;
wire ready_for_reader;

buffer b1(data_in,write,next,   ,capacity,data_out, ready_for_reader);

initial 
begin 

	data_in=31'ha2c3;
	#1 write=1;
	#1 write=0;

	data_in=31'hc2a3;
	#1 write=1;
	#1 write=0;

	data_in=31'he2c5;
	#1 write=1;
	#1 write=0;

	data_in=31'hb1f4;
	#1 write=1;
	#1 write=0;
	
	data_in=31'habcd;
	#1 write=1;
	#1 write=0;
	
	#1 next=1;
	#1 next=0;
	
		
	data_in=31'h1234;
	#1 write=1;
	#1 write=0;

	#1 next=1;
	#1 next=0;

	#1 next=1;
	#1 next=0;

	#1 next=1;
	#1 next=0;

	#1 next=1;
	#1 next=0;

	#1 next=1;
	#1 next=0;
	
	#1 $finish;
end
endmodule 
  
  
  
  
