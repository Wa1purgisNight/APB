`timescale 1ns / 1ps
// rsp_valid pulses for one clock; sample rsp_rdata/rsp_error when high.
module apb_top (
    input wire pclk, presetn,
    input wire req_valid,
    output wire req_ready,
    input wire req_write,
    input wire [31:0] req_addr, req_wdata,
    output wire rsp_valid,
    output wire [31:0] rsp_rdata,
    output wire rsp_error
);
    wire [31:0] paddr, pwdata, prdata;
    wire psel, penable, pwrite, pready, pslverr;
    apb_master u_apb_master (
        .pclk(pclk), .presetn(presetn),
        .req_valid(req_valid), .req_ready(req_ready),
        .req_write(req_write), .req_addr(req_addr), .req_wdata(req_wdata),
        .rsp_valid(rsp_valid), .rsp_rdata(rsp_rdata), .rsp_error(rsp_error),
        .paddr(paddr), .psel(psel), .penable(penable), .pwrite(pwrite),
        .pwdata(pwdata), .prdata(prdata), .pready(pready), .pslverr(pslverr)
    );
    apb_slave u_apb_slave (
        .pclk(pclk), .presetn(presetn),
        .paddr(paddr), .psel(psel), .penable(penable), .pwrite(pwrite),
        .pwdata(pwdata), .prdata(prdata), .pready(pready), .pslverr(pslverr)
    );
endmodule
