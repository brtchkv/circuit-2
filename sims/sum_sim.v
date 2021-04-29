`timescale 1ns / 1ps

module sum_sim;

reg [3:0] in = 0;
reg [15:0] as [0:9][0:2]; 
initial begin
    as[0][0] = 3;
    as[0][1] = 4;
    as[0][2] = 7;
    
    as[1][0] = 5;
    as[1][1] = 12;
    as[1][2] = 17;
    
    as[2][0] = 8;
    as[2][1] = 7;
    as[2][2] = 15;
    
    as[3][0] = 1;
    as[3][1] = 1;
    as[3][2] = 2;
    
    as[4][0] = 2;
    as[4][1] = 2;
    as[4][2] = 4;
end;

reg clk_reg = 1;
reg rst_reg;
reg [15:0] a;
reg [15:0] b;
reg start_i = 0;
wire busy_o;
wire ready;
wire [15:0] y;

sum sm(
    .clk(clk_reg), .rst(rst_reg), .start(start_i), 
    .a(a), .b(b), .ready(ready), .busy(busy_o), .y(y)
);

always
    #10 clk_reg = !clk_reg;

initial begin
   rst_reg = 1;
   a = as[in][0];
   b = as[in][1];
end;

always @(posedge clk_reg)
    if (ready) begin
        rst_reg = 0;
        start_i = 1;
    end else if (start_i && busy_o) begin
        start_i = 0;
    end else if(!busy_o) begin
        if (y == as[in][2]) begin
                $display("%d Correct a=%d b=%d res=%d", in, a, b, y);
            end else begin
                $display("%d Incorrect a=%d b=%d res=%d", in, a, b, y);
            end;
            rst_reg = 1;
            in = in+1;
            if (in > 4) begin
                $finish;
            end;
            
            a = as[in][0];
            b = as[in][1];
    end;

endmodule
