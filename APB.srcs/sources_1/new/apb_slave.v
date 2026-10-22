`timescale 1ns / 1ps
// 16 x 32-bit registers at byte addresses 0x00, 0x04, ... 0x3C.
module apb_slave (
    input wire pclk, presetn,
    input wire [31:0] paddr,
    input wire psel, penable, pwrite,
    input wire [31:0] pwdata,
    output reg [31:0] prdata,
    output wire pready, pslverr
);
    reg [31:0] registers [0:15];
    integer i;
    wire access_active = psel && penable;
    wire address_valid = (paddr[31:6] == 26'd0) && (paddr[1:0] == 2'b00);
    // Zero wait states; invalid accesses complete with an error.
    assign pready = presetn && access_active;
    assign pslverr = presetn && access_active && !address_valid;
    always @(*) begin
        prdata = 32'd0;
        if (presetn && access_active && !pwrite && address_valid)
            prdata = registers[paddr[5:2]];
    end
    // A register changes only on the completion edge of a valid write.
    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            for (i = 0; i < 16; i = i + 1)
                registers[i] <= 32'd0;
        end else if (access_active && pready && pwrite && address_valid)
            registers[paddr[5:2]] <= pwdata;
    end
endmodule
