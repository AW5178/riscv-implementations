module tb_ajw_addsub_unit;
    
    int unsigned seed;
    
    localparam L_PERIOD = 20000;
    
    logic [31:0] tb_opX;
    logic [31:0] tb_opY;
    logic        tb_cin;
    logic [31:0] tb_sum;
    logic        tb_cout;
    ajw_addsub_unit
        u_dut_addsub_unit (
            .opX_i(tb_opX),
            .opY_i(tb_opY),
            .cin_i(tb_cin),
            .sum_o(tb_sum),
            .cout_o(tb_cout)
    );
	int i;
    initial begin : tests
        for (i=0; i<24; i=i+1) begin
			seed   = $urandom_range(1000, 1);
            tb_opX = $urandom(seed+1'b1);
            tb_opY = $urandom(seed-1'b1);
            tb_cin = $urandom(seed+2'b10);
            #(L_PERIOD);
        end
    end 
endmodule


