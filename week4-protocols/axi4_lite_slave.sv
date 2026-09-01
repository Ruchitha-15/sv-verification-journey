// Code your design here
interface axi4_lite_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(input logic clk, input logic rst_n);

    // Write address channel
    logic [ADDR_WIDTH-1:0] awaddr;
    logic                   awvalid;
    logic                   awready;

    // Write data channel
    logic [DATA_WIDTH-1:0]   wdata;
    logic [DATA_WIDTH/8-1:0] wstrb;
    logic                    wvalid;
    logic                    wready;

    // Write response channel
    logic [1:0] bresp;
    logic       bvalid;
    logic       bready;

    // Read address channel
    logic [ADDR_WIDTH-1:0] araddr;
    logic                   arvalid;
    logic                   arready;

    // Read data channel
    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0]            rresp;
    logic                  rvalid;
    logic                  rready;

endinterface
module axi4_lite_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input logic clk,
    input logic rst_n,
    // Write address channel
    input  logic [ADDR_WIDTH-1:0] awaddr,
    input  logic                   awvalid,
    output logic                   awready,
    // Write data channel
    input  logic [DATA_WIDTH-1:0]   wdata,
    input  logic [DATA_WIDTH/8-1:0] wstrb,
    input  logic                    wvalid,
    output logic                    wready,
    // Write response channel
    output logic [1:0] bresp,
    output logic       bvalid,
    input  logic       bready,
    // Read address channel
    input  logic [ADDR_WIDTH-1:0] araddr,
    input  logic                   arvalid,
    output logic                   arready,
    // Read data channel
    output logic [DATA_WIDTH-1:0] rdata,
    output logic [1:0]            rresp,
    output logic                  rvalid,
    input  logic                  rready
);

    // 4 registers
    logic [DATA_WIDTH-1:0] reg_file [0:3];

    // Write logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            awready <= 0;
            wready  <= 0;
            bvalid  <= 0;
            bresp   <= 2'b00;
        end else begin
            // accept write address and data when both valid
            if (awvalid && wvalid && !bvalid) begin
                awready <= 1;   // tell master address accepted
                wready  <= 1;   // tell master data accepted
                // write to register — address divided by 4 gives index
              reg_file[awaddr[3:2]] <= wdata;
                bresp  <= 2'b00;  // OKAY
                bvalid <= 1;    // response ready
            end else begin
                awready <= 0;
                wready  <= 0;
                if (bvalid && bready)
                    bvalid <= 0;  // clear response when master accepts
            end
        end
    end

    // Read logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            arready <= 0;
            rvalid  <= 0;
            rdata   <= 0;
            rresp   <= 2'b00;
        end else begin
            if (arvalid && !rvalid) begin
                arready <= 1;   // tell master address accepted
                rdata   <= reg_file[araddr[3:2]];   // return register value
                rresp   <= 2'b00; // OKAY
                rvalid  <= 1;   // data ready
            end else begin
                arready <= 0;
                if (rvalid && rready)
                    rvalid <= 0;  // clear when master accepts
            end
        end
    end

endmodule

//TESTBENCH
module axi4_lite_tb;

    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;

    logic clk, rst_n;

    // instantiate interface
    axi4_lite_if #(ADDR_WIDTH, DATA_WIDTH) axi_if(.clk(clk), .rst_n(rst_n));

    // instantiate DUT
    axi4_lite_slave #(ADDR_WIDTH, DATA_WIDTH) dut (
        .clk     (axi_if.clk),
        .rst_n   (axi_if.rst_n),
        .awaddr  (axi_if.awaddr),
        .awvalid (axi_if.awvalid),
        .awready (axi_if.awready),
        .wdata   (axi_if.wdata),
        .wstrb   (axi_if.wstrb),
        .wvalid  (axi_if.wvalid),
        .wready  (axi_if.wready),
        .bresp   (axi_if.bresp),
        .bvalid  (axi_if.bvalid),
        .bready  (axi_if.bready),
        .araddr  (axi_if.araddr),
        .arvalid (axi_if.arvalid),
        .arready (axi_if.arready),
        .rdata   (axi_if.rdata),
        .rresp   (axi_if.rresp),
        .rvalid  (axi_if.rvalid),
        .rready  (axi_if.rready)
    );

    always #5 clk = ~clk;

    // Write task
    task axi_write(
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [DATA_WIDTH-1:0] data,
        input logic [DATA_WIDTH/8-1:0] strb
    );
        @(posedge clk);
        axi_if.awaddr  = addr;
        axi_if.awvalid = 1;
        axi_if.wdata   = data;
        axi_if.wstrb   = strb;
        axi_if.wvalid  = 1;
        axi_if.bready  = 1;

        // wait for address and data accepted
        wait(axi_if.awready && axi_if.wready);
        @(posedge clk);
        axi_if.awvalid = 0;
        axi_if.wvalid  = 0;

        // wait for response
        wait(axi_if.bvalid);
        @(posedge clk);
        axi_if.bready = 0;

        $display("WRITE: addr=%0h data=%0h resp=%0b",
                  addr, data, axi_if.bresp);
    endtask

    // Read task
    task axi_read(
        input  logic [ADDR_WIDTH-1:0] addr,
        output logic [DATA_WIDTH-1:0] rdata
    );
        @(posedge clk);
        axi_if.araddr  = addr;
        axi_if.arvalid = 1;
        axi_if.rready  = 1;

        // wait for address accepted
        wait(axi_if.arready);
        @(posedge clk);
        axi_if.arvalid = 0;

        // wait for data
        wait(axi_if.rvalid);
        rdata = axi_if.rdata;
        @(posedge clk);
        axi_if.rready = 0;

        $display("READ: addr=%0h data=%0h resp=%0b",
                  addr, rdata, axi_if.rresp);
    endtask

    initial begin
        // initialize
        clk            = 0;
        rst_n          = 0;
        axi_if.awvalid = 0;
        axi_if.wvalid  = 0;
        axi_if.bready  = 0;
        axi_if.arvalid = 0;
        axi_if.rready  = 0;

        // release reset
        #20 rst_n = 1;

        // Test 1: write to register 0 and read back
        axi_write(32'h00, 32'hDEADBEEF, 4'hF);
        begin
            logic [31:0] rd;
            axi_read(32'h00, rd);
            if (rd === 32'hDEADBEEF)
                $display("PASS: reg0 correct");
            else
                $display("FAIL: reg0 got=%0h expected=DEADBEEF", rd);
        end

        // Test 2: write to register 1
        axi_write(32'h04, 32'hCAFEBABE, 4'hF);
        begin
            logic [31:0] rd;
            axi_read(32'h04, rd);
            if (rd === 32'hCAFEBABE)
                $display("PASS: reg1 correct");
            else
                $display("FAIL: reg1 got=%0h expected=CAFEBABE", rd);
        end

        // Test 3: write to register 2
        axi_write(32'h08, 32'h12345678, 4'hF);
        begin
            logic [31:0] rd;
            axi_read(32'h08, rd);
            if (rd === 32'h12345678)
                $display("PASS: reg2 correct");
            else
                $display("FAIL: reg2 got=%0h expected=12345678", rd);
        end

        #20 $finish;
    end

endmodule
