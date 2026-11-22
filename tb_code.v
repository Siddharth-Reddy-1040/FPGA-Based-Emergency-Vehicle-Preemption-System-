`timescale 1ns/1ps

module traffic_preemption_priority_tb;

    // Inputs
    reg clk, reset;
    reg ev_lane1_present, ev_lane2_present, ev_lane3_present, ev_lane4_present;
    reg [7:0] ev_lane1_distance, ev_lane2_distance, ev_lane3_distance, ev_lane4_distance;
    reg rfid_lane1_detected, rfid_lane2_detected, rfid_lane3_detected, rfid_lane4_detected;

    // Outputs
    wire [2:0] light_lane1, light_lane2, light_lane3, light_lane4;

    // DUT Instantiation (All 4 Lanes Connected)
    traffic_preemption_priority dut (
        .clk(clk),
        .reset(reset),
        .ev_lane1_present(ev_lane1_present),
        .ev_lane1_distance(ev_lane1_distance),
        .ev_lane2_present(ev_lane2_present),
        .ev_lane2_distance(ev_lane2_distance),
        .ev_lane3_present(ev_lane3_present),
        .ev_lane3_distance(ev_lane3_distance),
        .ev_lane4_present(ev_lane4_present),
        .ev_lane4_distance(ev_lane4_distance),
        .rfid_lane1_detected(rfid_lane1_detected),
        .rfid_lane2_detected(rfid_lane2_detected),
        .rfid_lane3_detected(rfid_lane3_detected),
        .rfid_lane4_detected(rfid_lane4_detected),
        .light_lane1(light_lane1),
        .light_lane2(light_lane2),
        .light_lane3(light_lane3),
        .light_lane4(light_lane4)
    );

    // 100 MHz Clock (10 ns period)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("traffic_preemption_priority_tb.vcd");
        $dumpvars(0, traffic_preemption_priority_tb);

        // INIT
        clk = 0; reset = 1;
        ev_lane1_present = 0; ev_lane2_present = 0; ev_lane3_present = 0; ev_lane4_present = 0;
        ev_lane1_distance = 8'd0; ev_lane2_distance = 8'd0; ev_lane3_distance = 8'd0; ev_lane4_distance = 8'd0;
        rfid_lane1_detected = 0; rfid_lane2_detected = 0; rfid_lane3_detected = 0; rfid_lane4_detected = 0;

        #10 reset = 0;

        // 1. NORMAL OPERATION
        #50;

        // 2. LANE 1 EMERGENCY
        ev_lane1_present    = 1;
        ev_lane1_distance   = 8'd10;
        rfid_lane1_detected = 1;
        #40;
        ev_lane1_present    = 0;
        ev_lane1_distance   = 8'd0;
        rfid_lane1_detected = 0;

        // 3. LANE 2 vs LANE 3 (Lane 2 closer -> Lane 2 wins)
        ev_lane2_present    = 1;
        ev_lane3_present    = 1;
        ev_lane2_distance   = 8'd5;
        ev_lane3_distance   = 8'd15;
        rfid_lane2_detected = 1;
        rfid_lane3_detected = 1;
        #40;
        ev_lane2_present    = 0;
        ev_lane3_present    = 0;
        ev_lane2_distance   = 8'd0;
        ev_lane3_distance   = 8'd0;
        rfid_lane2_detected = 0;
        rfid_lane3_detected = 0;

        // 4. LANE 3 ONLY
        ev_lane3_present    = 1;
        ev_lane3_distance   = 8'd8;
        rfid_lane3_detected = 1;
        #40;
        ev_lane3_present    = 0;
        ev_lane3_distance   = 8'd0;
        rfid_lane3_detected = 0;

        // 5. LANE 4 EMERGENCY
        ev_lane4_present    = 1;
        ev_lane4_distance   = 8'd6;
        rfid_lane4_detected = 1;
        #40;
        ev_lane4_present    = 0;
        ev_lane4_distance   = 8'd0;
        rfid_lane4_detected = 0;

        // 6. NO RFID (Unauthenticated vehicle -> should NOT trigger preemption)
        ev_lane1_present    = 1;
        ev_lane1_distance   = 8'd4;
        rfid_lane1_detected = 0;
        #40;
        ev_lane1_present    = 0;
        ev_lane1_distance   = 8'd0;

        #60;
        $finish;
    end

endmodule
