//rewritten in system verilog
module seq_detector_1011 (
    input  logic clk,
    input  logic rst,
    input  logic in,
    output logic detected
);

// State encoding
typedef enum logic [2:0] {
    IDLE, S1, S10, S101, S1011
} state_t;

state_t state, next_state;
// Block 1: state register
always @(posedge clk) begin
    if (rst)
        state <= IDLE;
    else
        state <= next_state;
end

// Block 2: next-state logic
always @(*) begin
    case (state)
        IDLE:  next_state = (in == 1) ? S1    : IDLE;
        S1:    next_state = (in == 1) ? IDLE  : S10;
        S10:   next_state = (in == 1) ? S101  : IDLE;
        S101:  next_state = (in == 1) ? S1011 : S10;
        S1011: next_state = (in == 1) ? S1    : IDLE;
        default: next_state = IDLE;
    endcase
end

// Block 3: output logic
always @(*) begin
    detected = (state == S1011);
end

endmodule
