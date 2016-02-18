module test;

`include "./addr_defines.v"
`include "./apis_tb.v"

// Inputs to testbench
reg [5:0]   ttlin_pad;

panda_top_tb tb(
    .ttlin_pad      ( ttlin_pad)
);

//reg [511:0]     test_name = "COUNTER_TEST";
//reg [511:0]     test_name = "READBACK_BIT_TEST";
//reg [511:0]     test_name = "PCAP_TEST";
reg [511:0]     test_name = "FRAMING_TEST";
//reg [511:0]     test_name = "ENCODER_TEST";

reg [ 1:0]      wrs, rsp;
reg [31:0]      IRQ_STATUS;
reg [ 7:0]      IRQ_FLAGS;
reg [15:0]      SMPL_COUNT;
reg [31:0]      dma_addr;
reg [31:0]      addr;
reg [31:0]      base;
reg [31:0]      total_samples;
reg [31:0]      addr_table[31: 0];
reg [31:0]      smpl_table[31: 0];
reg [31:0]      read_data;
reg [31:0]      readback;
reg [31:0]      read_addr;
reg             active;
reg             pcap_completed;

integer         fid;
integer         r;
integer         len;
integer         irq_count;
integer         data;
integer i, n, j;
integer NUMSAMPLE;

// Wrapper for Zynx AXI4 transactions.
task REG_WRITE;
    input [31: 0] base;
    input [31: 0] addr;
    input [31: 0] val;
begin
    tb.uut.ps.ps.ps.inst.write_data(base + 4*addr,  4, val, wrs);
end
endtask

task REG_READ;
    input  [31: 0] base;
    input  [31: 0] addr;
    output [31: 0] val;
begin
    tb.uut.ps.ps.ps.inst.read_data(base + 4*addr,  4, val, wrs);
end
endtask

task WAIT_IRQ;
    input  [31: 0] status;
begin
    // Wait for DMA irq
    tb.uut.ps.ps.ps.inst.wait_interrupt(0,IRQ_STATUS);
end
endtask

initial begin
    repeat(2) @(posedge tb.uut.ps.FCLK);
    tb.uut.ps.ps.hp1.cdn_axi3_master_bfm_inst.RESPONSE_TIMEOUT = 0;
    tb.uut.ps.ps.hp1.cdn_axi3_master_bfm_inst.set_channel_level_info(0);
    tb.uut.ps.ps.hp1.cdn_axi3_master_bfm_inst.set_function_level_info(0);
    tb.uut.ps.ps.ps.inst.set_function_level_info("ALL",0);
    tb.uut.ps.ps.ps.inst.set_channel_level_info("ALL",0);
end

initial begin
    ttlin_pad <= 0;

    wait(tb.uut.ps.tb_ARESETn === 0) @(posedge tb.uut.ps.FCLK);
    wait(tb.uut.ps.tb_ARESETn === 1) @(posedge tb.uut.ps.FCLK);

    $display("Reset Done. Setting the Slave profiles \n");
    tb.uut.ps.ps.ps.inst.set_slave_profile("S_AXI_HP0",2'b11);
    $display("Profile Done\n");

    tb.uut.ps.ps.ps.inst.fpga_soft_reset(32'h1);
    tb.uut.ps.ps.ps.inst.fpga_soft_reset(32'h0);

if (test_name == "READBACK_BIT_TEST") begin
    repeat(1250) @(posedge tb.uut.ps.FCLK);
    REG_WRITE(REG_BASE, REG_BIT_READ_RST, 1);
    for (i = 0; i < 8; i = i + 1) begin
        REG_READ(REG_BASE, REG_BIT_READ_VALUE, readback);
        $display("System Bus Readback %d = %08x", i, readback);
    end

    repeat(1250) @(posedge tb.uut.ps.FCLK);
    ttlin_pad <= 6'b101010;
    repeat(1250) @(posedge tb.uut.ps.FCLK);
    ttlin_pad <= 0;

    repeat(1250) @(posedge tb.uut.ps.FCLK);
    REG_WRITE(REG_BASE, REG_BIT_READ_RST, 1);
    for (i = 0; i < 8; i = i + 1) begin
        REG_READ(REG_BASE, REG_BIT_READ_VALUE, readback);
        $display("System Bus Readback %d = %08x", i, readback);
    end

    repeat(1250) @(posedge tb.uut.ps.FCLK);
    REG_WRITE(BITS_BASE, BITS_A_SET, 1);
    REG_WRITE(BITS_BASE, BITS_B_SET, 1);
    REG_WRITE(BITS_BASE, BITS_A_SET, 0);
    repeat(1250) @(posedge tb.uut.ps.FCLK);

    repeat(1250) @(posedge tb.uut.ps.FCLK);
    REG_WRITE(REG_BASE, REG_BIT_READ_RST, 1);
    for (i = 0; i < 8; i = i + 1) begin
        REG_READ(REG_BASE, REG_BIT_READ_VALUE, readback);
        $display("System Bus Readback %d = %08x", i, readback);
    end

    repeat(1250) @(posedge tb.uut.ps.FCLK);
    REG_WRITE(BITS_BASE, BITS_A_SET, 1);
    REG_WRITE(BITS_BASE, BITS_B_SET, 0);
    repeat(1250) @(posedge tb.uut.ps.FCLK);

    repeat(1250) @(posedge tb.uut.ps.FCLK);
    REG_WRITE(REG_BASE, REG_BIT_READ_RST, 1);
    for (i = 0; i < 8; i = i + 1) begin
        REG_READ(REG_BASE, REG_BIT_READ_VALUE, readback);
        $display("System Bus Readback %d = %08x", i, readback);
    end

    repeat(1250) @(posedge tb.uut.ps.FCLK);
    $finish;
end
if (test_name == "READBACK_POS_TEST") begin
    repeat(1250) @(posedge tb.uut.ps.FCLK);
    REG_WRITE(REG_BASE, REG_POS_READ_RST, 1);
    for (i = 0; i < 32; i = i + 1) begin
        REG_READ(REG_BASE, REG_POS_READ_VALUE, readback);
        $display("System Bus Readback %d = %08x", i, readback);
    end

    tb.encoder.Turn(1500);

    repeat(1250) @(posedge tb.uut.ps.FCLK);
    REG_WRITE(REG_BASE, REG_POS_READ_RST, 1);
    for (i = 0; i < 32; i = i + 1) begin
        REG_READ(REG_BASE, REG_POS_READ_VALUE, readback);
        $display("System Bus Readback %d = %08x", i, readback);
    end

    REG_READ(REG_BASE, REG_POS_READ_CHANGES, readback);
   $display("REG_POS_READ_CHANGES = %08x", i, readback);

    repeat(1250) @(posedge tb.uut.ps.FCLK);
    $finish;
end
if (test_name == "COUNTER_TEST") begin
    repeat(1250) @(posedge tb.uut.ps.FCLK);
    REG_WRITE(CLOCKS_BASE, CLOCKS_A_PERIOD, 125);
    REG_WRITE(COUNTER_BASE, COUNTER_STEP, 1);
    REG_WRITE(COUNTER_BASE, COUNTER_TRIGGER, 122);
    REG_WRITE(COUNTER_BASE, COUNTER_ENABLE, 1);
    repeat(1250) @(posedge tb.uut.ps.FCLK);
    $finish;
end
else if (test_name == "TTL_TEST") begin
    // TTL Loopback for TTLOUT[5:0]
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_0000,  4, 0, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_0100,  4, 1, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_0200,  4, 2, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_0300,  4, 3, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_0400,  4, 4, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_0500,  4, 5, wrs);
    // LVDS Loopback
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_1000,  4, 6, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_1100,  4, 7, wrs);

end
else if (test_name == "LUT_TEST") begin
    // LUT -1
    // A
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_2000,  4, 0, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_2004,  4, 1, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_2008,  4, 2, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_200C,  4, 3, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_2010,  4, 4, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_2014,  4, 32'hffff0000, wrs);

    // LUT -2
    // A&B|C&~D
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_2100,  4, 0, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_2104,  4, 1, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_2108,  4, 2, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_210C,  4, 3, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_2110,  4, 4, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_2114,  4, 32'hff303030, wrs);
end
else if (test_name == "SRGATE_TEST") begin
    // SRGATE
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_3000,  4, 0, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_3004,  4, 3, wrs);
end
else if (test_name == "DIV_TEST") begin
    // DIV-1
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_4000,  4, 0, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_400C,  4, 4000, wrs);

    // DIV-2
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_4100,  4, 3, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_410C,  4, 4000, wrs);

        // Force Reset on both DIVs.
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_4014,  4, 0, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_4114,  4, 0, wrs);

        // Read COUNT status from DIVs
    repeat(100) @(posedge tb.uut.ps.FCLK);
    tb.uut.ps.ps.ps.inst.read_data(32'h43C0_4010,  4, read_data, wrs);
    $display("Read Data = (%0d)\n",read_data);
    tb.uut.ps.ps.ps.inst.read_data(32'h43C0_4110,  4, read_data, wrs);
    $display("Read Data = (%0d)\n",read_data);

end
else if (test_name == "PULSE_TEST") begin
    $display("RUNNING PULSE TEST...");
        // CLOCKS-CLKA/B/C/D
    tb.uut.ps.ps.ps.inst.write_data(32'h43C1_C000,  4,125, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C1_C004,  4,250, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C1_C008,  4,500, wrs);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C1_C00C,  4,1000, wrs);

        // PULSE-1
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5000,  4,122, wrs); //INP
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5004,  4,127, wrs); //RST
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5008,  4,  5, wrs); //D-L
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_500C,  4,  0, wrs); //D-H
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5010,  4, 25, wrs); //W-L
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5014,  4,  0, wrs); //W-H
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5018,  4,  0, wrs); //FORCE
        // PULSE-2
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5100,  4, 0, wrs); //INP
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5108,  4, 5, wrs); //D-L
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_510C,  4, 0, wrs); //D-H
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5110,  4,20, wrs); //W-L
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5114,  4, 0, wrs); //W-H
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5118,  4, 0, wrs); //FORCE
        // PULSE-3
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5200,  4, 0, wrs); //INP
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5208,  4, 5, wrs); //D-L
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_520C,  4, 0, wrs); //D-H
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5210,  4,30, wrs); //W-L
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5214,  4, 0, wrs); //W-H
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5218,  4, 0, wrs); //FORCE
        // PULSE-2
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5300,  4, 0, wrs); //INP
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5308,  4, 5, wrs); //D-L
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_530C,  4, 0, wrs); //D-H
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5310,  4,40, wrs); //W-L
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5314,  4, 0, wrs); //W-H
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_5318,  4, 0, wrs); //FORCE
end
else if (test_name == "SEQ_TEST") begin
    $display("RUNNING SEQUENCER TEST...");
    len <= 1;
    fid = $fopen("table.dat", "r");
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_6004,  4, 0, wrs); //INPA
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_6008,  4, 0, wrs); //INPA
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_600C,  4, 0, wrs); //INPA
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_6010,  4, 0, wrs); //INPA
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_6014,  4, 2, wrs); //PRESC

    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_601C,  4, 2, wrs); //TREPEAT
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_6024,  4, 1, wrs); //TRST

    while (!$feof(fid)) begin
        r = $fscanf(fid, "%d\n", data);
        tb.uut.ps.ps.ps.inst.write_data(32'h43C0_6028,  4, data, wrs); //TDAT
        len <= len + 1;
        repeat(1) @(posedge tb.uut.ps.FCLK);
    end

    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_6020,  4, len, wrs);//TLEN
    repeat(1250) @(posedge tb.uut.ps.FCLK);
    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_6018,  4, 1, wrs);//SGATE
    repeat(1250) @(posedge tb.uut.ps.FCLK);

    tb.uut.ps.ps.ps.inst.read_data(32'h43C0_602C,  4, read_data, wrs);
    $display("CUR_FRAME = (%0d)\n",read_data);
    tb.uut.ps.ps.ps.inst.read_data(32'h43C0_6030,  4, read_data, wrs);
    $display("CUR_FCYCLE = (%0d)\n",read_data);
    tb.uut.ps.ps.ps.inst.read_data(32'h43C0_6034,  4, read_data, wrs);
    $display("CUR_TCYCLE = (%0d)\n",read_data);
    tb.uut.ps.ps.ps.inst.read_data(32'h43C0_6038,  4, read_data, wrs);
    $display("STATE = (%0d)\n",read_data);
end
else if (test_name == "ENCODER_TEST") begin
    repeat(1250) @(posedge tb.uut.ps.FCLK);
    REG_WRITE(INENC_BASE, INENC_PROTOCOL, 0);
    REG_WRITE(OUTENC_BASE, OUTENC_PROTOCOL, 0);
    tb.encoder.Turn(1500);
    repeat(2500) @(posedge tb.uut.ps.FCLK);

    // SSI Loopback
    // Setup Clock-A
    REG_WRITE(CLOCKS_BASE, CLOCKS_A_PERIOD, 12500); // 100 usec trigger rate

    // Setup a timer for capture input test
    REG_WRITE(COUNTER_BASE, COUNTER_ENABLE, 1);     // BITS_ONE
    REG_WRITE(COUNTER_BASE, COUNTER_TRIGGER, 122);  // CLOCKS_A
    REG_WRITE(COUNTER_BASE, COUNTER_STEP, 1);

    REG_WRITE(INENC_BASE, INENC_PROTOCOL, 1);
    REG_WRITE(INENC_BASE, INENC_CLKRATE, 125);
    REG_WRITE(INENC_BASE, INENC_FRAMERATE, 12500);
    REG_WRITE(INENC_BASE, INENC_BITS, 24);

    REG_WRITE(OUTENC_BASE, OUTENC_PROTOCOL, 1);
    REG_WRITE(OUTENC_BASE, OUTENC_POSN, 12);        // COUNTER_COUNT(0);
    REG_WRITE(OUTENC_BASE, OUTENC_BITS, 24);

    repeat(12500 * 10) @(posedge tb.uut.ps.FCLK);

    $finish;
end
else if (test_name == "SSIENC_TEST") begin
//    repeat(1250) @(posedge tb.uut.ps.FCLK);
//    // CLOCKS-CLKA as trigger source
//    tb.uut.ps.ps.ps.inst.write_data(32'h43C1_C000,  4, 12500, wrs);
//    // Set-up Counters 0 as position source
//    REG_WRITE(COUNTER_BASE, COUNTER_ENABLE, 118);
//    REG_WRITE(COUNTER_BASE, COUNTER_TRIGGER, 122);
//    REG_WRITE(COUNTER_BASE, COUNTER_STEP, 1);
//
//    // SLOW_INENC_CTRL
//    tb.uut.ps.ps.ps.inst.write_data(32'h43C1_B000, 4, 32'hC, wrs);
//    // SLOW_OUTENC_CTRL
//    tb.uut.ps.ps.ps.inst.write_data(32'h43C1_B004, 4, 32'h28, wrs);
//
//    // Set-up OutEnc
//    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_8000 + 4*OUTENC_PROTOCOL, 4, 1, wrs);
//    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_8000 + 4*OUTENC_BITS, 4, 24, wrs);
//    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_8000 + 4*OUTENC_POSN, 4, 12, wrs);
//    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_8000 + 4*OUTENC_BITS, 4, 24, wrs);
//
//    // Set-up InEnc
//    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_7000 + 4*INENC_PROTOCOL, 4, 1, wrs);
//    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_7000 + 4*INENC_BITS, 4, 24, wrs);
//    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_7000 + 4*INENC_CLKRATE, 4, 125, wrs);
//    tb.uut.ps.ps.ps.inst.write_data(32'h43C0_7000 + 4*INENC_FRAMERATE, 4, 100, wrs);
//
//    repeat(1250) @(posedge tb.uut.ps.FCLK);
//    tb.uut.ps.ps.ps.inst.write_data(32'h43C1_D000,  4, 1, wrs);
//
//    repeat(40000) @(posedge tb.uut.ps.FCLK);
//    $finish;
end
else if (test_name == "PCAP_TEST") begin
    $display("Running PCAP TEST...");

    base = 32'h43C1_1000;
    addr = 32'h1000_0000;
    read_addr = 32'h1000_0000;
    irq_count = 0;
    total_samples = 0;

    repeat(1250) @(posedge tb.uut.ps.FCLK);

    repeat(1250) @(posedge tb.uut.ps.FCLK);
    REG_WRITE(INENC_BASE, INENC_PROTOCOL, 0);
    REG_WRITE(OUTENC_BASE, OUTENC_PROTOCOL, 0);

    // Setup a timer for capture input test
    REG_WRITE(COUNTER_BASE, COUNTER_ENABLE, 106);       // pcap_act
    REG_WRITE(COUNTER_BASE, COUNTER_TRIGGER, 102);      // pcomp_pulse
    REG_WRITE(COUNTER_BASE, COUNTER_START, 1000);
    REG_WRITE(COUNTER_BASE, COUNTER_STEP, 500);

    // Setup Position Compare Block
    REG_WRITE(PCOMP_BASE, PCOMP_ENABLE, 106);           // pcap_act
    REG_WRITE(PCOMP_BASE, PCOMP_POSN, 1);               // inenc_posn(0)
    REG_WRITE(PCOMP_BASE, PCOMP_START, 100);
    REG_WRITE(PCOMP_BASE, PCOMP_STEP, 0);
    REG_WRITE(PCOMP_BASE, PCOMP_WIDTH, 1400);
    REG_WRITE(PCOMP_BASE, PCOMP_PNUM, 3);
    REG_WRITE(PCOMP_BASE, PCOMP_FLTR_DELTAT, 32);
    REG_WRITE(PCOMP_BASE, PCOMP_FLTR_THOLD, 1);

    // Setup Position Capture
    REG_WRITE(REG_BASE, REG_PCAP_START_WRITE, 1);
    REG_WRITE(REG_BASE, REG_PCAP_WRITE, 1);             // enc #1
    REG_WRITE(REG_BASE, REG_PCAP_WRITE, 11);            // counter #1

    REG_WRITE(PCAP_BASE, PCAP_ENABLE, 98);              // pcomp_act(0)
    REG_WRITE(PCAP_BASE, PCAP_CAPTURE, 102);            // pcomp_pulse
    REG_WRITE(DRV_BASE, DRV_PCAP_TIMEOUT, 0);
    REG_WRITE(DRV_BASE, DRV_PCAP_DMA_ADDR, addr);
    REG_WRITE(REG_BASE, REG_PCAP_ARM, 1);
    addr = addr + tb.BLOCK_SIZE;
    REG_WRITE(DRV_BASE, DRV_PCAP_DMA_ADDR, addr);
    repeat(1250) @(posedge tb.uut.ps.FCLK);

fork
begin
    for (i=0; i<10; i=i+1) begin
        tb.encoder.Turn(1500);
        tb.encoder.Turn(-1500);
    end
end

begin
    `include "./irq_handler.v"
end

join

    repeat(1250) @(posedge tb.uut.ps.FCLK);

    $finish;
end
else if (test_name == "FRAMING_TEST") begin
    $display("Running FRAMING TEST...");

    base = 32'h43C1_1000;
    addr = 32'h1000_0000;
    read_addr = 32'h1000_0000;
    irq_count = 0;
    total_samples = 0;
    ttlin_pad = 0;
    NUMSAMPLE = 16;

    repeat(500) @(posedge tb.uut.ps.FCLK);

    // Setup a timer for capture input test
    REG_WRITE(COUNTER_BASE, COUNTER_ENABLE, 2);       // TTL #0
    REG_WRITE(COUNTER_BASE, COUNTER_TRIGGER, 4);      // TTL #2
    REG_WRITE(COUNTER_BASE, COUNTER_START, 100);
    REG_WRITE(COUNTER_BASE, COUNTER_STEP, 50);

    REG_WRITE(COUNTER_BASE + 32'h100, COUNTER_ENABLE, 2);       // TTL #0
    REG_WRITE(COUNTER_BASE + 32'h100, COUNTER_TRIGGER, 4);      // TTL #2
    REG_WRITE(COUNTER_BASE + 32'h100, COUNTER_START, 1000);
    REG_WRITE(COUNTER_BASE + 32'h100, COUNTER_STEP, 100);

    // Setup Position Capture
    REG_WRITE(REG_BASE, REG_PCAP_START_WRITE, 1);
    REG_WRITE(REG_BASE, REG_PCAP_WRITE, 12);    // counter #1
    REG_WRITE(REG_BASE, REG_PCAP_WRITE, 13);    // counter #2

    REG_WRITE(PCAP_BASE, PCAP_ENABLE,  2);      // TTL #0
    REG_WRITE(PCAP_BASE, PCAP_FRAME,   3);      // TTL #1
    REG_WRITE(PCAP_BASE, PCAP_CAPTURE, 4);      // TTL #2

    REG_WRITE(REG_BASE, REG_PCAP_FRAMING_MASK, 32'h180);
    REG_WRITE(REG_BASE, REG_PCAP_FRAMING_ENABLE, 0);
    REG_WRITE(REG_BASE, REG_PCAP_FRAMING_MODE, 0);

    REG_WRITE(DRV_BASE, DRV_PCAP_BLOCK_SIZE, tb.BLOCK_SIZE);
    REG_WRITE(DRV_BASE, DRV_PCAP_TIMEOUT, 0);
    REG_WRITE(DRV_BASE, DRV_PCAP_DMA_RESET, 1);     // DMA reset
    REG_WRITE(DRV_BASE, DRV_PCAP_DMA_ADDR, addr);   // Init
    REG_WRITE(DRV_BASE, DRV_PCAP_DMA_START, 1);     // ...
    addr = addr + tb.BLOCK_SIZE;                    //
    REG_WRITE(DRV_BASE, DRV_PCAP_DMA_ADDR, addr);   //

    REG_WRITE(REG_BASE, REG_PCAP_ARM, 1);
    repeat(1250) @(posedge tb.uut.ps.FCLK);

    // Number of samples per channel
    pcap_completed = 0;
    NUMSAMPLE = 16;

fork

// Enable
begin
    ttlin_pad[0] = 1;
    repeat(1250) @(posedge tb.uut.ps.FCLK);
    wait (n == NUMSAMPLE - 1);
    repeat(1) @(posedge tb.uut.ps.FCLK);
    ttlin_pad[0] = 0;
    wait (pcap_completed == 1);
    $finish;
end

// Frame
begin
    for (i = 0; i < 10; i = i+1) begin
        ttlin_pad[1] = 1;
        repeat(500) @(posedge tb.uut.ps.FCLK);
        ttlin_pad[1] = 0;
        repeat(1500) @(posedge tb.uut.ps.FCLK);
    end
end

// Capture @ 1MHz
begin
    wait (ttlin_pad[0] == 1);
    repeat(750) @(posedge tb.uut.ps.FCLK);
    for (n = 0; n < NUMSAMPLE; n = n+1) begin
        ttlin_pad[2] = 1;
        repeat(1) @(posedge tb.uut.ps.FCLK);
        ttlin_pad[2] = 0;
        repeat(124) @(posedge tb.uut.ps.FCLK);
    end
end

begin
end
    `include "./irq_handler.v"
join

    repeat(1250) @(posedge tb.uut.ps.FCLK);

    $finish;
end
else
    $display("NO TEST SELECTED...");
    repeat(100000) @(posedge tb.uut.ps.FCLK);

    $finish;
end

endmodule
