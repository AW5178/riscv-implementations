//////////////////////////////////////////////////////////////
// File name: ajw_addsub_unit.sv
// Author : Andrew Wolters (AJW)
// Date: 03/05/2024
// File Purpose: Functional Description of 32-bit Carry-LookAhead Adder
//////////////////////////////////////////////////////////////

module ajw_addsub_unit (
    //-----------------INPUTS-------------------//
    input  logic [31:0]           opX_i, // Operand X of operation
    input  logic [31:0]           opY_i, // Operand Y of operation
    input  logic                  cin_i, // carry-in: determines an addition or subtraction
    //-----------------OUTPUTS-------------------//
    output logic [31:0]           sum_o, // output sum
    output logic                  cout_o // output carry out for SR
);
    //////////////////////////////////////////////////////////////
    //                        VARIABLES
    //////////////////////////////////////////////////////////////
    logic [31:0] opY_int; // Vector of opY XORed w/ cin to genrate 2'sC equivalent in case of subtract.
    logic [31:0] gen_s0; // 1st layer of computed generate functions
    logic [31:0] prop_s0; // 1st layer of computed propagate functions
    logic [3:0]  gen_s1; // 2nd layer of computed generate functions
    logic [3:0]  prop_s1; // 2nd layer of computed propagate functions
    logic [32:0] carry_int; // Vector of intermediate carry bits used to compute sums

    //////////////////////////////////////////////////////////////
    //                        PROCEDURES
    //////////////////////////////////////////////////////////////
    always_comb begin : c_addsub
	     carry_int[0] = cin_i;
        // Cin = 0 -> Standard ADD
        // Cin = 1 -> Invert: 2'sC Subtraction
        opY_int = opY_i ^ {32{carry_int[0]}};
        
        for (int i=0; i<32; i=i+1) begin : f_generate_calcs
            gen_s0[i]  = opX_i[i] & opY_int[i]; // Generates: x & y
            prop_s0[i] = opX_i[i] | opY_int[i]; // Propagates: x | y
        end
		
        // BELOW: CARRY CALCULATIONS
        // CARRYS ARE CALCULATED 8 AT A TIME BEFORE PROPAGATING TOA NOTHER CLA.
        carry_int[1] = (gen_s0[0]) | 
                       (prop_s0[0] & carry_int[0]);
        
        carry_int[2] = (gen_s0[1]) | 
                       (prop_s0[1] & gen_s0[0]) |
                       (prop_s0[1] & prop_s0[0] & carry_int[0]);
        
        carry_int[3] = (gen_s0[2]) | 
                       (prop_s0[2] & gen_s0[1]) |
                       (prop_s0[2] & prop_s0[1] & gen_s0[0]) |
                       (prop_s0[2] & prop_s0[1] & prop_s0[0] & carry_int[0]);
        
        carry_int[4] = (gen_s0[3]) | 
                       (prop_s0[3] & gen_s0[2]) |
                       (prop_s0[3] & prop_s0[2] & gen_s0[1]) |
                       (prop_s0[3] & prop_s0[2] & prop_s0[1] & gen_s0[0]) |
                       (prop_s0[3] & prop_s0[2] & prop_s0[1] & prop_s0[0] & carry_int[0]);
       
        carry_int[5] = (gen_s0[4]) |
                       (prop_s0[4] & gen_s0[3]) | 
                       (prop_s0[4] & prop_s0[3] & gen_s0[2]) |
                       (prop_s0[4] & prop_s0[3] & prop_s0[2] & gen_s0[1]) |
                       (prop_s0[4] & prop_s0[3] & prop_s0[2] & prop_s0[1] & gen_s0[0]) |
                       (prop_s0[4] & prop_s0[3] & prop_s0[2] & prop_s0[1] & prop_s0[0] & carry_int[0]);
    
        carry_int[6] = (gen_s0[5]) |
                       (prop_s0[5] & gen_s0[4]) |
                       (prop_s0[5] & prop_s0[4] & gen_s0[3]) |
                       (prop_s0[5] & prop_s0[4] & prop_s0[3] & gen_s0[2]) |
                       (prop_s0[5] & prop_s0[4] & prop_s0[3] & prop_s0[2] & gen_s0[1]) |
                       (prop_s0[5] & prop_s0[4] & prop_s0[3] & prop_s0[2] & prop_s0[1] & gen_s0[0]) |
                       (prop_s0[5] & prop_s0[4] & prop_s0[3] & prop_s0[2] & prop_s0[1] & prop_s0[0] & carry_int[0]);
        
        carry_int[7] = (gen_s0[6]) | 
                       (prop_s0[6] & gen_s0[5]) |
                       (prop_s0[6] & prop_s0[5] & gen_s0[4]) |
                       (prop_s0[6] & prop_s0[5] & prop_s0[4] & gen_s0[3]) |
                       (prop_s0[6] & prop_s0[5] & prop_s0[4] & prop_s0[3] & gen_s0[2]) |
                       (prop_s0[6] & prop_s0[5] & prop_s0[4] & prop_s0[3] & prop_s0[2] & gen_s0[1]) |
                       (prop_s0[6] & prop_s0[5] & prop_s0[4] & prop_s0[3] & prop_s0[2] & prop_s0[1] & gen_s0[0]) |
                       (prop_s0[6] & prop_s0[5] & prop_s0[4] & prop_s0[3] & prop_s0[2] & prop_s0[1] & prop_s0[0] & carry_int[0]);
        
        carry_int[8] = (gen_s0[7]) | 
                       (prop_s0[7] & gen_s0[6]) |
                       (prop_s0[7] & prop_s0[6] & gen_s0[5]) |
                       (prop_s0[7] & prop_s0[6] & prop_s0[5] & gen_s0[4]) |
                       (prop_s0[7] & prop_s0[6] & prop_s0[5] & prop_s0[4] & gen_s0[3]) |
                       (prop_s0[7] & prop_s0[6] & prop_s0[5] & prop_s0[4] & prop_s0[3] & gen_s0[2]) |
                       (prop_s0[7] & prop_s0[6] & prop_s0[5] & prop_s0[4] & prop_s0[3] & prop_s0[2] & gen_s0[1]) |
                       (prop_s0[7] & prop_s0[6] & prop_s0[5] & prop_s0[4] & prop_s0[3] & prop_s0[2] & prop_s0[1] & gen_s0[0]) |
                       (prop_s0[7] & prop_s0[6] & prop_s0[5] & prop_s0[4] & prop_s0[3] & prop_s0[2] & prop_s0[1] & prop_s0[0] & carry_int[0]);
        
        carry_int[9] = (gen_s0[8]) | 
                       (prop_s0[8] & carry_int[8]);
        
        carry_int[10] = (gen_s0[ 9]) | 
                        (prop_s0[ 9] & gen_s0[8]) |
                        (prop_s0[ 9] & prop_s0[8] & carry_int[8]);
        
        carry_int[11] = (gen_s0[10]) | 
                        (prop_s0[10] & gen_s0[ 9]) |
                        (prop_s0[10] & prop_s0[ 9] & gen_s0[8]) |
                        (prop_s0[10] & prop_s0[ 9] & prop_s0[8] & carry_int[8]);
        
        carry_int[12] = (gen_s0[11]) | 
                        (prop_s0[11] & gen_s0[10]) |
                        (prop_s0[11] & prop_s0[10] & gen_s0[ 9]) |
                        (prop_s0[11] & prop_s0[10] & prop_s0[ 9] & gen_s0[8]) |
                        (prop_s0[11] & prop_s0[10] & prop_s0[ 9] & prop_s0[8] & carry_int[8]);
        
        carry_int[13] = (gen_s0[12]) |
                        (prop_s0[12] & gen_s0[11]) | 
                        (prop_s0[12] & prop_s0[11] & gen_s0[10]) |
                        (prop_s0[12] & prop_s0[11] & prop_s0[10] & gen_s0[ 9]) |
                        (prop_s0[12] & prop_s0[11] & prop_s0[10] & prop_s0[ 9] & gen_s0[8]) |
                        (prop_s0[12] & prop_s0[11] & prop_s0[10] & prop_s0[ 9] & prop_s0[8] & carry_int[8]);
    
        carry_int[14] = (gen_s0[13]) |
                        (prop_s0[13] & gen_s0[12]) |
                        (prop_s0[13] & prop_s0[12] & gen_s0[11]) |
                        (prop_s0[13] & prop_s0[12] & prop_s0[11] & gen_s0[10]) |
                        (prop_s0[13] & prop_s0[12] & prop_s0[11] & prop_s0[10] & gen_s0[ 9]) |
                        (prop_s0[13] & prop_s0[12] & prop_s0[11] & prop_s0[10] & prop_s0[ 9] & gen_s0[8]) |
                        (prop_s0[13] & prop_s0[12] & prop_s0[11] & prop_s0[10] & prop_s0[ 9] & prop_s0[8] & carry_int[8]);
        
        carry_int[15] = (gen_s0[14]) | 
                        (prop_s0[14] & gen_s0[13]) |
                        (prop_s0[14] & prop_s0[13] & gen_s0[12]) |
                        (prop_s0[14] & prop_s0[13] & prop_s0[12] & gen_s0[11]) |
                        (prop_s0[14] & prop_s0[13] & prop_s0[12] & prop_s0[11] & gen_s0[10]) |
                        (prop_s0[14] & prop_s0[13] & prop_s0[12] & prop_s0[11] & prop_s0[10] & gen_s0[ 9]) |
                        (prop_s0[14] & prop_s0[13] & prop_s0[12] & prop_s0[11] & prop_s0[10] & prop_s0[ 9] & gen_s0[8]) |
                        (prop_s0[14] & prop_s0[13] & prop_s0[12] & prop_s0[11] & prop_s0[10] & prop_s0[ 9] & prop_s0[8] & carry_int[8]);
        
        carry_int[16] = (gen_s0[15]) | 
                        (prop_s0[15] & gen_s0[14]) |
                        (prop_s0[15] & prop_s0[14] & gen_s0[13]) |
                        (prop_s0[15] & prop_s0[14] & prop_s0[13] & gen_s0[12]) |
                        (prop_s0[15] & prop_s0[14] & prop_s0[13] & prop_s0[12] & gen_s0[11]) |
                        (prop_s0[15] & prop_s0[14] & prop_s0[13] & prop_s0[12] & prop_s0[11] & gen_s0[10]) |
                        (prop_s0[15] & prop_s0[14] & prop_s0[13] & prop_s0[12] & prop_s0[11] & prop_s0[10] & gen_s0[ 9]) |
                        (prop_s0[15] & prop_s0[14] & prop_s0[13] & prop_s0[12] & prop_s0[11] & prop_s0[10] & prop_s0[ 9] & gen_s0[8]) |
                        (prop_s0[15] & prop_s0[14] & prop_s0[13] & prop_s0[12] & prop_s0[11] & prop_s0[10] & prop_s0[9 ] & prop_s0[8] & carry_int[8]);
        
        carry_int[17] = (gen_s0[16]) | 
                        (prop_s0[16] & carry_int[16]);
        
        carry_int[18] = (gen_s0[17]) | 
                        (prop_s0[17] & gen_s0[16]) |
                        (prop_s0[17] & prop_s0[16] & carry_int[16]);
        
        carry_int[19] = (gen_s0[18]) | 
                        (prop_s0[18] & gen_s0[17]) |
                        (prop_s0[18] & prop_s0[17] & gen_s0[16]) |
                        (prop_s0[18] & prop_s0[17] & prop_s0[16] & carry_int[16]);
        
        carry_int[20] = (gen_s0[19]) | 
                        (prop_s0[19] & gen_s0[18]) |
                        (prop_s0[19] & prop_s0[18] & gen_s0[17]) |
                        (prop_s0[19] & prop_s0[18] & prop_s0[17] & gen_s0[16]) |
                        (prop_s0[19] & prop_s0[18] & prop_s0[17] & prop_s0[16] & carry_int[16]);
        
        carry_int[21] = (gen_s0[20]) |
                        (prop_s0[20] & gen_s0[19]) | 
                        (prop_s0[20] & prop_s0[19] & gen_s0[18]) |
                        (prop_s0[20] & prop_s0[19] & prop_s0[18] & gen_s0[17]) |
                        (prop_s0[20] & prop_s0[19] & prop_s0[18] & prop_s0[17] & gen_s0[16]) |
                        (prop_s0[20] & prop_s0[19] & prop_s0[18] & prop_s0[17] & prop_s0[16] & carry_int[16]);
    
        carry_int[22] = (gen_s0[21]) |
                        (prop_s0[21] & gen_s0[20]) |
                        (prop_s0[21] & prop_s0[20] & gen_s0[19]) |
                        (prop_s0[21] & prop_s0[20] & prop_s0[19] & gen_s0[18]) |
                        (prop_s0[21] & prop_s0[20] & prop_s0[19] & prop_s0[18] & gen_s0[17]) |
                        (prop_s0[21] & prop_s0[20] & prop_s0[19] & prop_s0[18] & prop_s0[17] & gen_s0[16]) |
                        (prop_s0[21] & prop_s0[20] & prop_s0[19] & prop_s0[18] & prop_s0[17] & prop_s0[16] & carry_int[16]);
        
        carry_int[23] = (gen_s0[22]) | 
                        (prop_s0[22] & gen_s0[21]) |
                        (prop_s0[22] & prop_s0[21] & gen_s0[20]) |
                        (prop_s0[22] & prop_s0[21] & prop_s0[20] & gen_s0[19]) |
                        (prop_s0[22] & prop_s0[21] & prop_s0[20] & prop_s0[19] & gen_s0[18]) |
                        (prop_s0[22] & prop_s0[21] & prop_s0[20] & prop_s0[19] & prop_s0[18] & gen_s0[17]) |
                        (prop_s0[22] & prop_s0[21] & prop_s0[20] & prop_s0[19] & prop_s0[18] & prop_s0[17] & gen_s0[16]) |
                        (prop_s0[22] & prop_s0[21] & prop_s0[20] & prop_s0[19] & prop_s0[18] & prop_s0[17] & prop_s0[16] & carry_int[16]);
        
        carry_int[24] = (gen_s0[23]) | 
                        (prop_s0[23] & gen_s0[22]) |
                        (prop_s0[23] & prop_s0[22] & gen_s0[21]) |
                        (prop_s0[23] & prop_s0[22] & prop_s0[21] & gen_s0[20]) |
                        (prop_s0[23] & prop_s0[22] & prop_s0[21] & prop_s0[20] & gen_s0[19]) |
                        (prop_s0[23] & prop_s0[22] & prop_s0[21] & prop_s0[20] & prop_s0[19] & gen_s0[18]) |
                        (prop_s0[23] & prop_s0[22] & prop_s0[21] & prop_s0[20] & prop_s0[19] & prop_s0[18] & gen_s0[17]) |
                        (prop_s0[23] & prop_s0[22] & prop_s0[21] & prop_s0[20] & prop_s0[19] & prop_s0[18] & prop_s0[17] & gen_s0[16]) |
                        (prop_s0[23] & prop_s0[22] & prop_s0[21] & prop_s0[20] & prop_s0[19] & prop_s0[18] & prop_s0[17] & prop_s0[16] & carry_int[16]);
    
        carry_int[25] = (gen_s0[24]) | 
                        (prop_s0[24] & carry_int[24]);
        
        carry_int[26] = (gen_s0[25]) | 
                        (prop_s0[25] & gen_s0[24]) |
                        (prop_s0[25] & prop_s0[24] & carry_int[24]);
        
        carry_int[27] = (gen_s0[26]) | 
                        (prop_s0[26] & gen_s0[25]) |
                        (prop_s0[26] & prop_s0[25] & gen_s0[24]) |
                        (prop_s0[26] & prop_s0[25] & prop_s0[24] & carry_int[24]);
        
        carry_int[28] = (gen_s0[27]) | 
                        (prop_s0[27] & gen_s0[26]) |
                        (prop_s0[27] & prop_s0[26] & gen_s0[25]) |
                        (prop_s0[27] & prop_s0[26] & prop_s0[25] & gen_s0[24]) |
                        (prop_s0[27] & prop_s0[26] & prop_s0[25] & prop_s0[24] & carry_int[24]);
        
        carry_int[29] = (gen_s0[28]) |
                        (prop_s0[28] & gen_s0[27]) | 
                        (prop_s0[28] & prop_s0[27] & gen_s0[26]) |
                        (prop_s0[28] & prop_s0[27] & prop_s0[26] & gen_s0[25]) |
                        (prop_s0[28] & prop_s0[27] & prop_s0[26] & prop_s0[25] & gen_s0[24]) |
                        (prop_s0[28] & prop_s0[27] & prop_s0[26] & prop_s0[25] & prop_s0[24] & carry_int[24]);
    
        carry_int[30] = (gen_s0[29]) |
                        (prop_s0[29] & gen_s0[28]) |
                        (prop_s0[29] & prop_s0[28] & gen_s0[27]) |
                        (prop_s0[29] & prop_s0[28] & prop_s0[27] & gen_s0[26]) |
                        (prop_s0[29] & prop_s0[28] & prop_s0[27] & prop_s0[26] & gen_s0[25]) |
                        (prop_s0[29] & prop_s0[28] & prop_s0[27] & prop_s0[26] & prop_s0[25] & gen_s0[24]) |
                        (prop_s0[29] & prop_s0[28] & prop_s0[27] & prop_s0[26] & prop_s0[25] & prop_s0[24] & carry_int[24]);
        
        carry_int[31] = (gen_s0[30]) | 
                        (prop_s0[30] & gen_s0[29]) |
                        (prop_s0[30] & prop_s0[29] & gen_s0[28]) |
                        (prop_s0[30] & prop_s0[29] & prop_s0[28] & gen_s0[27]) |
                        (prop_s0[30] & prop_s0[29] & prop_s0[28] & prop_s0[27] & gen_s0[26]) |
                        (prop_s0[30] & prop_s0[29] & prop_s0[28] & prop_s0[27] & prop_s0[26] & gen_s0[25]) |
                        (prop_s0[30] & prop_s0[29] & prop_s0[28] & prop_s0[27] & prop_s0[26] & prop_s0[25] & gen_s0[24]) |
                        (prop_s0[30] & prop_s0[29] & prop_s0[28] & prop_s0[27] & prop_s0[26] & prop_s0[25] & prop_s0[24] & carry_int[24]);
        
        carry_int[32] = (gen_s0[31]) | 
                        (prop_s0[31] & gen_s0[30]) |
                        (prop_s0[31] & prop_s0[30] & gen_s0[29]) |
                        (prop_s0[31] & prop_s0[30] & prop_s0[29] & gen_s0[28]) |
                        (prop_s0[31] & prop_s0[30] & prop_s0[29] & prop_s0[28] & gen_s0[27]) |
                        (prop_s0[31] & prop_s0[30] & prop_s0[29] & prop_s0[28] & prop_s0[27] & gen_s0[26]) |
                        (prop_s0[31] & prop_s0[30] & prop_s0[29] & prop_s0[28] & prop_s0[27] & prop_s0[26] & gen_s0[25]) |
                        (prop_s0[31] & prop_s0[30] & prop_s0[29] & prop_s0[28] & prop_s0[27] & prop_s0[26] & prop_s0[25] & gen_s0[24]) |
                        (prop_s0[31] & prop_s0[30] & prop_s0[29] & prop_s0[28] & prop_s0[27] & prop_s0[26] & prop_s0[25] & prop_s0[24] & carry_int[24]);
                            
        
        // Now, compute sums
        // we use the intermediate carrys for each group of 8.
        for (int i=0; i<32; i=i+1) begin
		      sum_o[i] = opX_i[i] ^ opY_int[i] ^ carry_int[i];
		  end
		  cout_o = carry_int[32];
    end
endmodule