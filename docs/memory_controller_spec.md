# DDR-Like Memory Controller Verification

## Project Goal
The goal of this project is to verify a simplified DDR-like memory controller using SystemVerilog UVM.

This is not a full DDR3/DDR4/DDR5 protocol controller. It is a simplified memory controller that models common memory-subsystem behavior such as read/write transactions, valid-ready handshaking, burst transfers, bank selection, reset behavior, and data integrity checking.

## Design Overview
The memory controller accepts read and write requests from a simple input interface and performs memory operations on an internal behavioral memory model.

## Interface Signals

| Signal | Direction | Description |
|---|---|---|
| clk | input | Clock |
| rst_n | input | Active-low reset |
| valid | input | Request valid from master |
| ready | output | Controller ready to accept request |
| write_en | input | 1 = write, 0 = read |
| addr | input | Memory address |
| wdata | input | Write data |
| rdata | output | Read data |
| rvalid | output | Read data valid |
| burst_len | input | Number of beats in burst |
| bank | input | Bank select |

## Supported Features

- Single read transaction
- Single write transaction
- Burst write transaction
- Burst read transaction
- Address and data randomization
- Bank selection
- Ready/valid handshake
- Reset handling
- Back-to-back read/write traffic

## Verification Goals

- Verify correct write and read data behavior
- Verify that read data matches previously written data
- Verify controller ready/valid timing
- Verify no response during reset
- Verify back-to-back transactions
- Verify burst transactions
- Verify bank-based memory accesses
- Verify coverage for address range, burst length, bank, and read/write type

## Not Included

- Full DDR3/DDR4/DDR5 JEDEC protocol
- DDR PHY calibration
- Refresh logic
- Activate/precharge timing
- CAS latency modeling
- Real DDR initialization sequence