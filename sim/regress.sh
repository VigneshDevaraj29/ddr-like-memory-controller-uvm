#!/bin/bash

rm -rf logs
mkdir logs

TESTS=(
  mem_write_read_test
  mem_reset_test
  mem_burst_stress_test
)

echo "Running DDR-Like Memory Controller Regression..."

for test in "${TESTS[@]}"; do
  echo "----------------------------------------"
  echo "Running test: $test"
  echo "----------------------------------------"

  ./run.sh $test | tee logs/${test}.log

  grep "UVM_ERROR" logs/${test}.log
  grep "UVM_FATAL" logs/${test}.log
done

echo "----------------------------------------"
echo "Regression completed."
echo "Logs saved in sim/logs/"