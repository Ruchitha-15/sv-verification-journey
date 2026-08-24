
module fifo_assertions(
    input logic clk,
    input logic rst,
    input logic wr_en,
    input logic rd_en,
    input logic full,
    input logic empty,
    input logic [2:0] wr_ptr,
    input logic [2:0] rd_ptr
);
    property full_check;
        @(posedge clk) disable iff(rst)
        full |-> (wr_ptr + 1 == rd_ptr);
    endproperty
    assert property(full_check)
        else $error("FULL flag incorrect");

    property empty_check;
        @(posedge clk) disable iff(rst)
        empty |-> (wr_ptr == rd_ptr);
    endproperty
    assert property(empty_check)
        else $error("EMPTY flag incorrect");

    property write_ptr_check;
        @(posedge clk) disable iff(rst)
        (wr_en && !full) |=> (wr_ptr == $past(wr_ptr) + 1);
    endproperty
    assert property(write_ptr_check)
        else $error("Write pointer not incrementing");

    property read_ptr_check;
        @(posedge clk) disable iff(rst)
        (rd_en && !empty) |=> (rd_ptr == $past(rd_ptr) + 1);
    endproperty
    assert property(read_ptr_check)
        else $error("Read pointer not incrementing");
endmodule
