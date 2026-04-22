// 1011 Sequence Detector — Moore FSM
// 3-always style: state register | next-state logic | output logic

module seq_detector_1011 (
    input  wire clk,
    input  wire rst,
    input  wire in,
    output reg  detected
);

// State encoding
parameter IDLE  = 3'b000;
parameter S1    = 3'b001;
parameter S10   = 3'b010;
parameter S101  = 3'b011;
parameter S1011 = 3'b100;

reg [2:0] state, next_state;

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
