//////////////////////////////////////////////////////////////
// File name: ajw_addsub_unit.sv
// Author : Andrew Wolters (AJW)
// Date: 03/05/2024
// File Purpose: Functional Description of 32-bit Carry-LookAhead Adder
//////////////////////////////////////////////////////////////

module ajw_32bit_addsub_unit #() (
    //-----------------INPUTS-------------------//
    input  logic [31:0]           opX_i, // Operand X of operation
    input  logic [31:0]           opY_i, // Operand Y of operation
    input  logic                  cin_i, // carry-in: determines an addition or subtraction
    //-----------------OUTPUTS-------------------//
    output logic [31:0]           sum_o, // output sum
    output logic                  cout_o // output carry out for SR
);
    // recall: g[i] = x[i]&y[i] and p[i] = x[i]|y[i]
    // c[i+1]=g[i] | p[i] & c[i]

    //////////////////////////////////////////////////////////////
    //                        VARIABLES
    //////////////////////////////////////////////////////////////
    logic [31:0] opY_int; // Vector of opY XORed w/ cin to genrate 2'sC equivalent in case of subtract.
    logic [31:0] gen_s0; // 1st layer of computed generate functions
    logic [31:0] prop_s0; // 1st layer of computed propagate functions
    logic [3:0]  gen_s1; // 2nd layer of computed generate functions
    logic [3:0]  prop_s1; // 2nd layer of computed propagate functions
    logic [ 2:0] carry_int; // Vector of intermediate carry bits used to compute sums

    //////////////////////////////////////////////////////////////
    //                        PROCEDURES
    //////////////////////////////////////////////////////////////
    always_comb begin : c_addsub
        // Cin = 0 -> Standard ADD
        // Cin = 1 -> Invert: 2'sC Subtraction
        opY_int = opY ^ {32{cin_i}};
        
        for (int i=0; i<32; i=i+1) begin : f_generate_calcs
            gen_s0[i]  = opX[i] & opY_int[i]; // Generates: x & y
            prop_s0[i] = opX[i] | opY_int[i]; // Propagates: x | y
        end

        // block level generate and propagate functions: there are 4 each
        for (int i=0; i<4; i=i+1) begin
            gen_s1[i] = (gen_s0[(8*i)+7]) |
                (gen_s0[(8*i)+6] & prop_s0[(8*i)+7]) |
                (gen_s0[(8*i)+5] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7]) |
                (gen_s0[(8*i)+4] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7]) |
                (gen_s0[(8*i)+3] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7]) |
                (gen_s0[(8*i)+2] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7]) |
                (gen_s0[(8*i)+1] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7]) |
                (gen_s0[(8*i)  ] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7] & prop_s0[(8*i)+7]);
            
            prop_s1[i] = ( prop_s0[(8*i)+7] &
                           prop_s0[(8*i)+6] &
                           prop_s0[(8*i)+5] &
                           prop_s0[(8*i)+4] &
                           prop_s0[(8*i)+3] &
                           prop_s0[(8*i)+2] &
                           prop_s0[(8*i)+1] &
                           prop_s0[(8*i)  ]
                         );
        end

        // c[8]
        carry_int[0] = (gen_s1[0]) |
                       (prop_s1[0] & cin_i);
        
        // c[16]
        carry_int[1] = (gen_s1[1])              |
                       (prop_s1[1] & gen_s1[0]) |
                       (prop_s1[1] & prop_s1[0] & cin_i);
        
        // c[24]
        carry_int[2] = (gen_s1[2])                           |
                       (prop_s1[2] & gen_s1[1])              | 
                       (prop_s1[2] & prop_s1[1] & gen_s1[0]) | 
                       (prop_s1[2] & prop_s1[1] & prop_s1[0] & cin_i);

        // c[32] == cout_o
        cout_o       = (gen_s1[3])                                        | 
                       (prop_s1[3] & gen_s1[2])                           | 
                       (prop_s1[3] & prop_s1[2] & gen_s1[1])              |
                       (prop_s1[3] & prop_s1[2] & prop_s1[1] & gen_s1[0]) |
                       (prop_s1[3] & prop_s1[2] & prop_s1[1] & prop_s1[0] & cin_i);
        
        // Now, compute sums
        // we use the intermediate carrys for each group of 8.
        sum_o[ 7: 0] = opX[ 7: 0] ^ opY_int[ 7: 0] ^ {8{cin_i}};
        sum_o[15: 8] = opX[15: 8] ^ opY_int[15: 8] ^ {8{carry_int[0]}};
        sum_o[23:16] = opX[23:16] ^ opY_int[23:16] ^ {8{carry_int[1]}};
        sum_o[31:24] = opX[31:24] ^ opY_int[31:24] ^ {8{carry_int[2]}};
    end
endmodule