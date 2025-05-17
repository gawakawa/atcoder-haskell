# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## コマンド
- 問題をテスト: `./test.sh [problem-id]` (コンテストディレクトリから実行)
- 最初のテストケースで実行: `./run.sh [contest-id] [problem-id]`
- 解答を提出: `./submit.sh [problem-id]`
- 新しいコンテストを作成: `./new.sh [contest-id]`

## コードスタイル
- Fourmoluでフォーマット (80文字制限)
- 標準エイリアスを使用した修飾インポート: BS (ByteString), IM (IntMap) など
- StrictData言語拡張を有効化
- パフォーマンスが重要な行列操作にはUArrayを優先
- 網羅的なパターンマッチングとエッジケースの明示的な処理
- 入力パース用の標準ユーティリティ関数を使用: ints, intMat など
- 局所変数定義には `let` ではなく `where` を使用
- 局所変数も含めて基本的に型注釈は書く

## プロジェクト構造
- メインソリューションは `contests/[contest-id]/[problem-id]/Main.hs`
- テストケースは `tests/` または `test/` ディレクトリにsample-N.in/outファイルとして保存
- ビルドにはCabalを使用し、標準フラグ: -threaded -rtsopts -O2
- 一貫した開発環境のためのNix flake

## 参考 URL
- https://hoogle.haskell.org/ (Haskell の関数を検索する API で、関数名や型で検索をかけることができる )
