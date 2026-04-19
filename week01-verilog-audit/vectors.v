//Build a combinational circuit that splits an input half-word (16 bits, [15:0] ) into lower [7:0] and upper [15:8] bytes.//
`default_nettype none     // Disable implicit nets. Reduces some types of bugs.
module top_module( 
    input wire [15:0] in,
    output wire [7:0] out_hi,
    output wire [7:0] out_lo );
    assign out_hi=in[15:8];
    assign out_lo=in[7:0];
endmodule

VECTOR PART-SELECT
module top_module( 
    input [31:0] in,
    output [31:0] out );//

     assign out[31:24] = in[7:0];    // D -> MSB
    assign out[23:16] = in[15:8];   // C
    assign out[15:8]  = in[23:16];  // B
    assign out[7:0]   = in[31:24];  // A -> LSB

endmodule

BITWISE OPERATORS
module top_module( 
    input [2:0] a,
    input [2:0] b,
    output [2:0] out_or_bitwise,
    output out_or_logical,
    output [5:0] out_not
);
     assign out_or_bitwise = a | b;        // 3-bit result [web:1][web:5]

    // Logical OR of the two 3-bit vectors
    assign out_or_logical = a || b;       // 1-bit result [web:1][web:5]

    // Inverse of b in upper half, inverse of a in lower half
    assign out_not[5:3] = ~b;             // bits [5:3] = ~b[2:0] [web:1][web:5]
    assign out_not[2:0] = ~a;             // bits [2:0] = ~a[2:0] [web:1][web:5]



endmodule
4 INPUT GATES
module top_module( 
    input [3:0] in,
    output out_and,
    output out_or,
    output out_xor
);
    assign out_and=in[3]&in[2]&in[1]&in[0];
    assign out_or=in[3]|in[2]|in[1]|in[0];
    assign out_xor=in[3]^in[2]^in[1]^in[0];
endmodule

CONCATINATION
module top_module (
    input [4:0] a, b, c, d, e, f,
    output [7:0] w, x, y, z );//

    assign {w,x,y,z} = {a,b,c,d,e,f,1'b0001,1'b0001};

endmodule

REVERSAL
module top_module( 
    input [7:0] in,
    output [7:0] out
);
assign out = {in[0], in[1], in[2], in[3],
                  in[4], in[5], in[6], in[7]};
endmodule

REPLICATION-1-Build a circuit that sign-extends an 8-bit number to 32 bits. This requires a concatenation of 24 copies of the sign bit (i.e., replicate bit[7] 24 times) followed by the 8-bit number itself.
module top_module (
    input [7:0] in,
    output [31:0] out );//

    assign out = { {24{in[7]}}, in };
endmodule
REPLICATION-2
Given five 1-bit signals (a, b, c, d, and e), compute all 25 pairwise one-bit comparisons in the 25-bit output vector. The output should be 1 if the two bits being compared are equal.

out[24] = ~a ^ a;   // a == a, so out[24] is always 1.
out[23] = ~a ^ b;
out[22] = ~a ^ c;
...
out[ 1] = ~e ^ d;
out[ 0] = ~e ^ e;
module top_module (
    input a, b, c, d, e,
    output [24:0] out );//

    // The output is XNOR of two vectors created by 
    // concatenating and replicating the five inputs.
    assign out = ~{{5{a}},{5{b}},{5{c}},{5{d}},{5{e}}} ^ {5{a,b,c,d,e}};

endmodule

