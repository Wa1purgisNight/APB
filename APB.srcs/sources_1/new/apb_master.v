`timescale 1ns / 1ps
// APB3 master: requests are accepted on req_valid && req_ready.
module apb_master (
    // Clock and reset
    input  wire        pclk,
    input  wire        presetn,

    // Request interface
    input  wire        req_valid,
    output wire        req_ready,
    input  wire        req_write,
    input  wire [31:0] req_addr,
    input  wire [31:0] req_wdata,

    // Response interface
    output reg         rsp_valid,
    output reg  [31:0] rsp_rdata,
    output reg         rsp_error,

    // APB interface
    output reg  [31:0] paddr,
    output wire        psel,
    output wire        penable,
    output reg         pwrite,
    output reg  [31:0] pwdata,
    input  wire [31:0] prdata,
    input  wire        pready,
    input  wire        pslverr
);
    localparam IDLE = 2'd0, SETUP = 2'd1, ACCESS = 2'd2;
    reg [1:0] state;
    assign req_ready = presetn && (state == IDLE);
    assign psel = (state != IDLE);
    assign penable = (state == ACCESS);
    // Latch controls in IDLE and hold them through SETUP/ACCESS/wait cycles.
    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            state <= IDLE;
            paddr <= 0;
            pwrite <= 0;
            pwdata <= 0;
            rsp_valid <= 0;
            rsp_rdata <= 0;
            rsp_error <= 0;
        end else begin
            rsp_valid <= 0;
            case (state)
                IDLE: if (req_valid && req_ready) begin
                    paddr <= req_addr;
                    pwrite <= req_write;
                    pwdata <= req_wdata;
                    state <= SETUP;
                end
                SETUP: state <= ACCESS;
                ACCESS: if (pready) begin
                    rsp_valid <= 1;
                    rsp_rdata <= pwrite ? 32'd0 : prdata;
                    rsp_error <= pslverr;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
