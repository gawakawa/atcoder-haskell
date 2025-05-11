#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 contest-id"
  exit 1
fi

CONTEST_ID=$1
ROOT_DIR=$(dirname "$(realpath "$0")")

# コンテストディレクトリ作成
mkdir -p contests
cd contests || exit 1
acc new $CONTEST_ID
cd $CONTEST_ID || exit 1

# テンプレートファイルコピー
cp "$ROOT_DIR/cabal-template/hie.yaml" .
cp "$ROOT_DIR/cabal-template/task.cabal" "${CONTEST_ID}.cabal"

# 置換処理
perl -pi -e "s/contest-id/$CONTEST_ID/g" "${CONTEST_ID}.cabal"

# 問題ディレクトリとMain.hsを作成
for task in a b c d e f g; do
  if grep -q "\"label\": \"$(echo $task | tr '[:lower:]' '[:upper:]')\"" contest.acc.json; then
    mkdir -p "$task"
    cp "$ROOT_DIR/cabal-template/Main.hs" "$task/Main.hs"
  fi
done

# acc config 設定
cd "$ROOT_DIR"
acc config default-task-choice all

# Cabalでビルド
cd "$ROOT_DIR/contests/$CONTEST_ID"
cabal update
cabal build

echo "Contest directory for $CONTEST_ID has been created successfully!"