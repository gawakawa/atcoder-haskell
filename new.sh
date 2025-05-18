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

# contest.acc.jsonからタスク一覧を取得
TASKS=$(jq -r '.tasks[].label | ascii_downcase' contest.acc.json)

# cabalファイルを最初から作成
cat > "${CONTEST_ID}.cabal" << EOL
cabal-version: 3.0
name:          ${CONTEST_ID}
version:       0.1.0.0
build-type:    Simple

common deps
  build-depends:
    , base
    , array
    , attoparsec
    , bytestring
    , containers
    , deepseq
    , extra
    , mtl
    , parsec
    , text
    , transformers
    , unordered-containers
    , vector

  default-language: GHC2021
  ghc-options:
    -threaded -rtsopts -with-rtsopts=-N -Wall -O2 -optc-O3

EOL

# 動的にタスクごとの設定を追加
for task in $TASKS; do
  # ディレクトリとMain.hsを作成
  mkdir -p "$task"
  cp "$ROOT_DIR/cabal-template/Main.hs" "$task/Main.hs"
  echo "Created directory and template for task $task"
  
  # cabalファイルに追記
  cat >> "${CONTEST_ID}.cabal" << EOL
executable $task
  import:         deps
  main-is:        Main.hs
  hs-source-dirs: $task

EOL
done

# hie.yamlを生成
echo "cradle:" > hie.yaml
echo "  cabal:" >> hie.yaml

for task in $TASKS; do
  cat >> hie.yaml << EOL
    - path: "./$task/Main.hs"
      component: "${CONTEST_ID}:exe:$task"

EOL
done

# acc config 設定
cd "$ROOT_DIR"
acc config default-task-choice all

# Cabalでビルド
cd "$ROOT_DIR/contests/$CONTEST_ID"
cabal update
cabal build

# Git add と commit
cd "$ROOT_DIR"
git add "contests/$CONTEST_ID"
git commit -m "🎉 $CONTEST_ID"

echo "Contest directory for $CONTEST_ID has been created successfully!"