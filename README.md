# FPGA-Based Emergency Vehicle Preemption System

An FPGA-based intelligent traffic signal controller designed in **Verilog HDL** and implemented in **Xilinx Vivado**. The system integrates **GPS** distance tracking, **LoRa** wireless telemetry, and **RFID** authentication to dynamically prioritize approaching emergency vehicles at a 4-lane intersection while maintaining deterministic normal signal cycling.

## System Overview

* **Multi-Factor Emergency Validation:** Combines emergency vehicle presence (`ev_laneX_present`) with RFID authentication (`rfid_laneX_detected`) to prevent false preemption triggers.
* **Distance-Based Priority Arbitration:** Evaluates real-time GPS distance telemetry (`ev_laneX_distance[7:0]`) across all four lanes and grants immediate green-corridor priority to the closest authenticated emergency vehicle.
* **Deterministic 4-Lane Traffic FSM:** Cycles sequentially through `L1_G -> L1_Y -> L2_G -> L2_Y -> L3_G -> L3_Y -> L4_G -> L4_Y` under normal traffic conditions (`T_GREEN = 50` cycles, `T_YELLOW = 20` cycles) and freezes the state timer during emergency preemption so normal operation resumes seamlessly afterward.

## Repository Contents

* **`traffic_preemption_priority.v`**: Synthesizable Verilog RTL module implementing the 4-lane traffic signal FSM, RFID + presence validation logic, distance-based priority resolver, and signal output decoder.
* **`traffic_preemption_priority_tb.v`**: Self-contained Verilog testbench verifying normal signal cycling, single-lane emergency preemption, multi-lane distance arbitration (Lane 2 vs. Lane 3), and rejection of unauthenticated vehicles lacking RFID detection.

## Running Simulation (Icarus Verilog / Vivado XSim)

```bash
iverilog -o preemption_sim.vvp traffic_preemption_priority.v traffic_preemption_priority_tb.v
vvp preemption_sim.vvp
```

## Tools & Technologies

* **HDL:** Verilog HDL
* **EDA Tools:** Xilinx Vivado Design Suite, Icarus Verilog / GTKWave
* **Hardware & Interfaces:** FPGA, GPS Positioning, LoRa Wireless Communication, RFID Authentication
