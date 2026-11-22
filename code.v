`timescale 1ns/1ps

module traffic_preemption_priority (
    input clk,
    input reset,

    // Emergency vehicle presence and distance
    input ev_lane1_present,
    input [7:0] ev_lane1_distance,
    input ev_lane2_present,
    input [7:0] ev_lane2_distance,
    input ev_lane3_present,
    input [7:0] ev_lane3_distance,
    input ev_lane4_present,
    input [7:0] ev_lane4_distance,

    // RFID authentication signals
    input rfid_lane1_detected,
    input rfid_lane2_detected,
    input rfid_lane3_detected,
    input rfid_lane4_detected,

    output reg [2:0] light_lane1,
    output reg [2:0] light_lane2,
    output reg [2:0] light_lane3,
    output reg [2:0] light_lane4
);

    // Light encoding
    localparam RED    = 3'b100;
    localparam YELLOW = 3'b010;
    localparam GREEN  = 3'b001;

    // FSM states (normal traffic)
    localparam L1_G = 3'd0, L1_Y = 3'd1,
               L2_G = 3'd2, L2_Y = 3'd3,
               L3_G = 3'd4, L3_Y = 3'd5,
               L4_G = 3'd6, L4_Y = 3'd7;

    reg [2:0] state;
    reg [7:0] counter;

    localparam T_GREEN  = 8'd50;
    localparam T_YELLOW = 8'd20;

    // Emergency valid signals
    wire ev1_valid = ev_lane1_present && rfid_lane1_detected;
    wire ev2_valid = ev_lane2_present && rfid_lane2_detected;
    wire ev3_valid = ev_lane3_present && rfid_lane3_detected;
    wire ev4_valid = ev_lane4_present && rfid_lane4_detected;

    wire ev_active = ev1_valid | ev2_valid | ev3_valid | ev4_valid;

    // Normal FSM (freezes during emergency preemption)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state   <= L1_G;
            counter <= 8'd0;
        end else if (!ev_active) begin
            counter <= counter + 8'd1;

            case (state)
                L1_G: if (counter >= T_GREEN)  begin state <= L1_Y; counter <= 8'd0; end
                L1_Y: if (counter >= T_YELLOW) begin state <= L2_G; counter <= 8'd0; end
                L2_G: if (counter >= T_GREEN)  begin state <= L2_Y; counter <= 8'd0; end
                L2_Y: if (counter >= T_YELLOW) begin state <= L3_G; counter <= 8'd0; end
                L3_G: if (counter >= T_GREEN)  begin state <= L3_Y; counter <= 8'd0; end
                L3_Y: if (counter >= T_YELLOW) begin state <= L4_G; counter <= 8'd0; end
                L4_G: if (counter >= T_GREEN)  begin state <= L4_Y; counter <= 8'd0; end
                L4_Y: if (counter >= T_YELLOW) begin state <= L1_G; counter <= 8'd0; end
                default: begin
                    state   <= L1_G;
                    counter <= 8'd0;
                end
            endcase
        end
    end

    // Emergency priority decision (closest valid EV wins; ties favor lower lane index)
    reg [2:0] priority_lane;
    reg [7:0] min_distance;

    always @(*) begin
        priority_lane = 3'd0;
        min_distance  = 8'hFF;

        if (ev1_valid) begin
            priority_lane = 3'd1;
            min_distance  = ev_lane1_distance;
        end
        if (ev2_valid && (priority_lane == 3'd0 || ev_lane2_distance < min_distance)) begin
            priority_lane = 3'd2;
            min_distance  = ev_lane2_distance;
        end
        if (ev3_valid && (priority_lane == 3'd0 || ev_lane3_distance < min_distance)) begin
            priority_lane = 3'd3;
            min_distance  = ev_lane3_distance;
        end
        if (ev4_valid && (priority_lane == 3'd0 || ev_lane4_distance < min_distance)) begin
            priority_lane = 3'd4;
            min_distance  = ev_lane4_distance;
        end
    end

    // Output logic
    always @(*) begin
        // Default all RED (prevents latch inference)
        light_lane1 = RED;
        light_lane2 = RED;
        light_lane3 = RED;
        light_lane4 = RED;

        if (priority_lane != 3'd0) begin
            // Emergency Mode
            case (priority_lane)
                3'd1: light_lane1 = GREEN;
                3'd2: light_lane2 = GREEN;
                3'd3: light_lane3 = GREEN;
                3'd4: light_lane4 = GREEN;
                default: ;
            endcase
        end else begin
            // Normal Mode
            case (state)
                L1_G: light_lane1 = GREEN;
                L1_Y: light_lane1 = YELLOW;
                L2_G: light_lane2 = GREEN;
                L2_Y: light_lane2 = YELLOW;
                L3_G: light_lane3 = GREEN;
                L3_Y: light_lane3 = YELLOW;
                L4_G: light_lane4 = GREEN;
                L4_Y: light_lane4 = YELLOW;
                default: ;
            endcase
        end
    end

endmodule
