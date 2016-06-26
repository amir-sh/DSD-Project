`include "utils.v" ;


module algorithm ;
    function [2:0] find_next(
	input [`router_address_size:0] src, dest, dim_x, dim_y);
      begin
        integer f = src % dim_x;
	integer l = dest % dim_x;
	if(f > l)
		find_next = 4;
	else if(f < l)
		find_next = 2;
	else 
		begin
			if(src < dest)
				find_next = 1;
			else if (src > dest)
				find_next = 3;
			else
				find_next = 0;
		end
      end
    endfunction
endmodule
