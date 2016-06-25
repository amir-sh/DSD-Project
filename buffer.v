module buffer(
  //from writer
  input [31:0] in,
  input write,
  
  //from reader
  input next,
  
  output reg ack,
  
  //for writer
  output [2:0] capacity,
  
  //for reader
  output [31:0] out,D:/ce/term6/DSD/project/proj/buffer.v
  output ready_for_reader
  );
  
  
  parameter buffer_size = 5; // maximum can be 7!
  reg [2:0] size;
  reg [2:0] package_num;
  reg [31:0] mem [buffer_size - 1:0];
  reg [2:0] first_index, last_index;
  integer iter;
  
  reg package_size;
  reg expected_flit;
  
  initial
  begin
    package_num = 0;
    expected_flit = 0;
    size = 0;
    first_index = 1;D:/ce/term6/DSD/project/proj/buffer.v
    last_index = 0;
  end
  
  assign out = mem[first_index];
  assign ready_for_reader = (package_num > 0);
  
  assign capacity = buffer_size - size;    
    
  always @(posedge write)
  begin
    if(expected_flit == in[0:0])
      begin
        last_index = last_index + 1;
        if(last_index >= buffer_size)
          begin
            last_index = 0;
          end
        ack = 0;
        mem[last_index] = in;
        size = size +1;
        if(expected_flit == 0)
          package_size = in[0:0];
        expected_flit = expected_flit + 1;
        if(expected_flit >= package_size)
          begin
            ack = 1;
            expected_flit = 0;
          end
      end
    else
      begin
        last_index = last_index - expected_flit;
        if(last_index < 0)
          begin
            last_index = last_index + buffer_size;
          end
        size = size - expected_flit;
      end
  end
        
  always @(posedge next)
  begin
    first_index = first_index + 1;
    if(first_index >= buffer_size)
      begin
        first_index = 0;
      end
    size = size -1;
    if(size == 0)
      begin
        package_num = 0;
      end
    else if()
  end
endmodule

module testbuffer;

reg write;
reg next;
reg [31:0] in;


wire [31:0] out;
wire [2:0] capacity;
wire ready_for_reader;

buffer b1(in,write,next,   ,capacity,out, ready_for_reader);

initial 
begin 

	in=31'ha2c3;
	#1 write=1;
	#1 write=0;

	in=31'hc2a3;
	#1 write=1;
	#1 write=0;

	in=31'he2c5;
	#1 write=1;
	#1 write=0;

	in=31'hb1f4;
	#1 write=1;
	#1 write=0;
	
	in=31'habcd;
	#1 write=1;
	#1 write=0;
	
	#1 next=1;
	#1 next=0;
	
		
	in=31'h1234;
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
  
  
  
  
