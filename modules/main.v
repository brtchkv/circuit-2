`timescale 1ns / 1ps

module main(
    input clk,
    input rst,
    input start,
    input [7:0] a,
    input [7:0] b,
    output wire ready,
    output wire busy,
    output reg [7:0] y
);

localparam IDLE = 2'b00;
localparam WAIT_MULT = 2'b01;
localparam WAIT_SQRT = 2'b10;

reg [1:0] state;

reg rst_mult;
reg rst_sqrt;
wire [15:0] a_square_wire, b_square_wire;
reg [15:0] a_square, b_square;
wire a_wait, b_wait, sqrt_wait;
wire a_ready, b_ready, sqrt_ready;
 
reg [16:0] square_sum;
wire [7:0] result_wire;
reg start_multiplying;
reg start_sqrt;

reg ready_in;
assign ready = ready_in;

mult a_square_calc( 
    .clk(clk), .rst(rst_mult), .start(start_multiplying), 
    .a(a), .b(a), .ready(a_ready), .busy(a_wait), .y(a_square_wire)
);

mult b_square_calc( 
    .clk(clk), .rst(rst_mult), .start(start_multiplying), 
    .a(b), .b(b), .ready(b_ready), .busy(b_wait), .y(b_square_wire)
);

sqrt sqrt_calc( 
    .clk(clk), .rst(rst_sqrt), .start(start_sqrt), 
    .x_b(square_sum), .ready(sqrt_ready), .busy(sqrt_wait), .y_b(result_wire)
);

assign busy = (state > 0);

always @(posedge clk)
    if (rst) begin
        state <= IDLE;
        y <= 0;
        start_multiplying <= 0;
        start_sqrt <= 0;
        rst_mult <= 1;
        rst_sqrt <= 1;
        square_sum <= 0;
        ready_in <= 1;
    end else begin
        case (state)
            IDLE:
                if (start && sqrt_ready && b_ready && a_ready) begin
                    rst_mult <= 0;
                    rst_sqrt <= 0;
                    start_multiplying <= 1;
                    state <= WAIT_MULT;
                    ready_in <= 0;
                end
            WAIT_MULT:
                begin
                   if (start_multiplying) begin
                        start_multiplying = 0;
                   end else if (!a_wait && !b_wait) begin
                        a_square <= a_square_wire;
                        b_square <= b_square_wire;
                        square_sum <= a_square_wire + b_square_wire;
                        start_sqrt <= 1;
                        state <= WAIT_SQRT;
                    end
                end
            WAIT_SQRT:
                begin
                    if (start_sqrt) begin
                        start_sqrt <= 0;
                    end else if (!sqrt_wait) begin
                        y <= result_wire;
                        state <= IDLE;
                    end
                end
        endcase
    end
endmodule
