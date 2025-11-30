#!/usr/bin/env bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 contest-id problem-id"
  exit 1
fi

CONTEST_ID=$1
PROBLEM_ID=$2

cd "contests/$CONTEST_ID/$PROBLEM_ID" || exit 1

echo "Running $CONTEST_ID:$PROBLEM_ID..."
cabal run --verbose=0 "$CONTEST_ID:$PROBLEM_ID" < tests/sample-1.in