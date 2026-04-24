// Synchronous FIFO — depth 8, width 8
// Full condition: one slot sacrificed to distinguish full from empty
module sync_fifo (
    input            clk,
    input            rst,
    input            wr_en,
    input            rd_en,
    input      [7:0] din,
    output reg [7:0] dout,
    output           full,
    output           empty
);

    // Memory array
    reg [7:0] mem [0:7];

    // Pointers
    reg [2:0] wr_ptr, rd_ptr;

    // Flags
    assign empty = (wr_ptr == rd_ptr);
    assign full  = (wr_ptr + 1 == rd_ptr);

    // Write logic
    always @(posedge clk) begin
        if (rst)
            wr_ptr <= 0;
        else if (wr_en && !full) begin
            mem[wr_ptr] <= din;
            wr_ptr      <= wr_ptr + 1;
        end
    end

    // Read logic
    always @(posedge clk) begin
        if (rst)
            rd_ptr <= 0;
        else if (rd_en && !empty) begin
            dout   <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end
    end

endmodule
