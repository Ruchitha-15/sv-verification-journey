✅INVERTER
module top_module( input in, output out );
assign out=!in;
endmodule

✅AND GATE
module top_module( 
    input a, 
    input b, 
    output out );
assign out=a&b;
endmodule

✅NOR GATE
module top_module( 
    input a, 
    input b, 
    output out );
    assign out=!(a|b);
endmodule

✅XNOR GATE
module top_module( 
    input a, 
    input b, 
    output out );
    assign out=!(a^b);
endmodule

✅7458 CHIP
module top_module ( 
    input p1a, p1b, p1c, p1d, p1e, p1f,
    output p1y,
    input p2a, p2b, p2c, p2d,
    output p2y );
wire a,b,c,d;
    assign a=p2a&p2b;
    assign b=p2c&p2d;
    assign p2y=a|b;
    assign c=p1a&p1b&p1c;
    assign d=p1d&p1e&p1f;
    assign p1y=c|d;
endmodule

