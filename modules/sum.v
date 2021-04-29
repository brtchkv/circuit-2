`timescale 1ns / 1ps

module sum(
    input clk,
    input rst,
    input start,
    input [15:0] a,
    input [15:0] b,
    output wire ready,
    output wire busy,
    output reg [15:0] y
);

localparam IDLE = 1'b0;
localparam WORK = 1'b1;

reg state;
reg ready_in;
reg [16:0] y_inh;

assign busy = state;
assign ready = ready_in;

always @(posedge clk)
    if (rst) begin
        y_inh <= 0;
        y <= 0;
        state <= IDLE;
        ready_in <= 1;
    end else begin
        case (state)
            IDLE: 
                if (ready && start) begin
                    state <= WORK;
                    ready_in <= 0;
                end
            WORK:
                begin
                    y <= a + b;
                    state <= IDLE;
                end
        endcase
    end
endmodule
