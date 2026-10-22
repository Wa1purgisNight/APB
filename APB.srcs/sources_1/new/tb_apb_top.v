`timescale 1ns / 1ps
// Add to Vivado Simulation Sources only.
module tb_apb_top;
    reg pclk = 0;
    always #5 pclk = ~pclk;
    reg presetn = 0, req_valid = 0, req_write = 0;
    reg [31:0] req_addr = 0, req_wdata = 0;
    wire req_ready, rsp_valid, rsp_error;
    wire [31:0] rsp_rdata;
    integer i;
    apb_top dut (
        .pclk(pclk), .presetn(presetn),
        .req_valid(req_valid), .req_ready(req_ready),
        .req_write(req_write), .req_addr(req_addr), .req_wdata(req_wdata),
        .rsp_valid(rsp_valid), .rsp_rdata(rsp_rdata), .rsp_error(rsp_error)
    );
    task transfer;
        input wr;
        input [31:0] addr, data, expected;
        input expected_error;
        begin
            @(negedge pclk);
            while (!req_ready) @(negedge pclk);
            req_valid = 1;
            req_write = wr;
            req_addr = addr;
            req_wdata = data;
            @(negedge pclk);
            req_valid = 0;
            while (!rsp_valid) @(negedge pclk);
            if (rsp_error !== expected_error || (!wr && rsp_rdata !== expected)) begin
                $display("FAIL addr=%h write=%b data=%h error=%b", addr, wr, rsp_rdata, rsp_error);
                $fatal(1, "Unexpected response");
            end
        end
    endtask
    initial begin
        repeat (3) @(negedge pclk);
        presetn = 1;
        for (i = 0; i < 16; i = i + 1) transfer(0, i*4, 0, 0, 0);
        for (i = 0; i < 16; i = i + 1) transfer(1, i*4, 32'h12340000+i, 0, 0);
        for (i = 0; i < 16; i = i + 1) transfer(0, i*4, 0, 32'h12340000+i, 0);
        transfer(1, 32'h40, 32'hFFFFFFFF, 0, 1);
        transfer(0, 32'h40, 0, 0, 1);
        transfer(1, 32'h01, 32'hFFFFFFFF, 0, 1);
        transfer(0, 32'h02, 0, 0, 1);
        transfer(0, 0, 0, 32'h12340000, 0);
        @(negedge pclk);
        presetn = 0;
        repeat (2) @(negedge pclk);
        presetn = 1;
        for (i = 0; i < 16; i = i + 1) transfer(0, i*4, 0, 0, 0);
        $display("PASS: register read/write, address errors and reset");
        $finish;
    end
    initial begin
        #10000;
        $fatal(1, "Simulation timeout");
    end
endmodule
