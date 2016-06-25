module demux(input [31:0] din ,
  input [2:0] out_port,
  output reg [4:0][31:0] dout);
  
  
  integer iter;
  always @(out_port or din)
  begin
    for(iter = 0; iter < 5 ; iter = iter +1)
    begin
      dout[iter] = (iter == out_port)  ? din : 0;
    end
  end
endmodule

module testdemux;
  
  wire [4:0][31:0] out;
  
  reg [2:0] out_port;
  reg [31:0] data;
  
  demux c(data,out_port,out );
  
  initial 
  begin
    
    data = 3546;
    
    out_port = 0;
    #1 out_port = 1;
    #1 out_port = 2;
    #1 out_port = 3;
    #1 out_port = 4;

  end

 endmodule