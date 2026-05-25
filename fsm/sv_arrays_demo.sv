module array_demo;

    // Packed — one contiguous block
    logic [7:0] packed_byte;

    // Unpacked — separate elements  
    logic unpacked_bits [7:0];

    // Mixed — your FIFO memory style
    logic [7:0] mem [0:3];

    initial begin
        // Packed — assign whole value and slice
        packed_byte = 8'hAB;
        $display("packed_byte     = %0h", packed_byte);
        $display("packed_byte[3:0]= %0h", packed_byte[3:0]);

        // Mixed memory — assign element by element
        mem[0] = 8'hAA;
        mem[1] = 8'hBB;
        mem[2] = 8'hCC;
        mem[3] = 8'hDD;
        $display("mem[0]=%0h mem[1]=%0h mem[2]=%0h mem[3]=%0h",
                  mem[0], mem[1], mem[2], mem[3]);

        // Unpacked — must assign element by element
        unpacked_bits[0] = 1;
        unpacked_bits[1] = 0;
        $display("unpacked[0]=%0b unpacked[1]=%0b",
                  unpacked_bits[0], unpacked_bits[1]);
    end

endmodule
