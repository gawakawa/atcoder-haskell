#!/usr/bin/env bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 contest-id"
  exit 1
fi

CONTEST_ID=$1
ROOT_DIR=$ROOT

# コンテストディレクトリ作成
mkdir -p contests
cd contests || exit 1
acc new $CONTEST_ID
cd $CONTEST_ID || exit 1

# contest.acc.jsonからタスク情報を取得（directoryのpathを使用）
TASKS=$(jq -r '.tasks[].directory.path' contest.acc.json)

# cabalファイルをテンプレートからコピーして編集
cp "$ROOT_DIR/acc-config/haskell/template.cabal" "${CONTEST_ID}.cabal"
sed -i "s/template/${CONTEST_ID}/g" "${CONTEST_ID}.cabal"

# テンプレート用のexecutableセクションを削除（直前の空行も含む）
sed -i '/^$/{N;/\nexecutable main$/{s/^\n//}}' "${CONTEST_ID}.cabal"
sed -i '/^executable main$/,/^$/d' "${CONTEST_ID}.cabal"

# 動的にタスクごとの設定を追加
for task in $TASKS; do
  # cabalファイルに追記
  cat >> "${CONTEST_ID}.cabal" << EOL

executable $task
  import:         deps
  main-is:        Main.hs
  hs-source-dirs: $task
EOL
done

# hie.yamlをテンプレートからコピーして編集
cp "$ROOT_DIR/acc-config/haskell/hie.yaml" hie.yaml

for task in $TASKS; do
  cat >> hie.yaml << EOL
    - path: "./$task/Main.hs"
      component: "${CONTEST_ID}:exe:$task"
EOL
done

# Cabalでビルド
cd "$ROOT_DIR/contests/$CONTEST_ID"
cabal update
cabal build

# Git add と commit
cd "$ROOT_DIR"
git add "contests/$CONTEST_ID"
git commit -m "🎉 $CONTEST_ID"

echo "Contest directory for $CONTEST_ID has been created successfully!"