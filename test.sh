#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 problem-id"
  exit 1
fi

PROBLEM_ID=$1
CONTEST_ID=$(basename "$PWD")

cd "$PROBLEM_ID" || exit 1

echo "Testing problem $PROBLEM_ID..."
oj test -c "cabal run -v0 $PROBLEM_ID" -d tests