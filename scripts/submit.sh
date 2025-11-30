#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 problem-id"
  exit 1
fi

PROBLEM_ID=$1
cd "$PROBLEM_ID" || exit 1

acc s