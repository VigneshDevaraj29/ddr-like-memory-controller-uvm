#!/bin/bash

rm -rf simv simv.daidir csrc ucli.key vc_hdrs.h *.log

vcs -full64 -sverilog -debug_access+all \
  -ntb_opts uvm \
  -timescale=1ns/1ps \
  +incdir+../tb \
  +incdir+../tb/agent \
  +incdir+../tb/env \
  +incdir+../tb/sequences \
  +incdir+../tb/tests \
  ../rtl/ddr_like_mem_ctrl.sv \
  ../tb/interfaces/mem_if.sv \
  ../tb/mem_pkg.sv \
  ../tb/top_tb.sv \
  -o simv

./simv +UVM_TESTNAME=${1:-mem_write_read_test}