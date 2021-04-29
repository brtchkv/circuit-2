`timescale 1ns / 1ps

module sqrt(
    input clk,
    input rst,
    input start,
    input [15:0] x_b,
    output wire ready,
    output wire busy,
    output reg [7:0] y_b
);

localparam IDLE = 1'b0;
localparam WORK = 1'b1;
 
localparam start_m = 1 << (16 - 2);

reg state;
reg [16:0] x, b, y;
reg [14:0] m;
reg ready_in;

assign finished = (m == 0);
assign busy = state;
assign ready = ready_in;

always @(posedge clk)
    if (rst) begin
        m <= start_m;
        y <= 0;
        y_b <= 0;
        state <= IDLE;
        ready_in <= 1;
    end else begin
        case (state)
            IDLE:
                if (ready && start) begin
                    state <= WORK;
                    m <= start_m;
                    x <= x_b;
                    ready_in <= 0;
                end
            WORK:
                begin
                    if (finished) begin
                        state <= IDLE;
                        y_b <= y;
                    end 
                    b = y | m;
                    y = y >> 1;
                    if (x >= b) begin
                        x <= x - b;
                        y <= y | m;
                    end
                    m = m >> 2;
                end
        endcase
    end
endmodule
