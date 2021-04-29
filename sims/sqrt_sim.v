`timescale 1ns / 1ps

module sqrt_sim;

reg [3:0] in = 0;
reg [15:0] as [0:9][0:1]; 
initial begin
    as[0][0] = 1;
    as[0][1] = 1;
    
    as[1][0] = 2;
    as[1][1] = 1;
    
    as[2][0] = 25;
    as[2][1] = 5;
    
    as[3][0] = 9;
    as[3][1] = 3;
    
    as[4][0] = 16;
    as[4][1] = 4;
end;

reg clk_reg = 1;
reg rst_reg;
reg [15:0] a;
reg start_i = 0;
wire busy_o;
wire ready;
wire [7:0] y;

sqrt sq(
    .clk(clk_reg), .rst(rst_reg), .start(start_i), 
    .x_b(a), .ready(ready), .busy(busy_o), .y_b(y)
);

always
    #10 clk_reg = !clk_reg;

initial begin
   rst_reg = 1;
   a = as[in][0];
end;

always @(posedge clk_reg)
    if (ready) begin
        rst_reg = 0;
        start_i = 1;
    end else if (start_i && busy_o) begin
        start_i = 0;
    end else if(~busy_o) begin
        if (y == as[in][1]) begin
                $display("%d Correct a=%d res=%d", in, a, y);
            end else begin
                $display("%d Incorrect a=%d res=%d", in, a, y);
            end;
            rst_reg = 1;
            in = in+1;
            if (in > 4) begin
                $finish;
            end;
            
            a = as[in][0];
    end;

endmodule
