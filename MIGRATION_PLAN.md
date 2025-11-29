# haskell.nix 移行計画

## 現状分析

### 現在の構成（nixpkgs標準のHaskell）
- **flake inputs**: nixpkgs, flake-parts, treefmt-nix
- **GHCバージョン**: GHC 9.8.4 (`haskell.compiler.ghc984`)
- **ビルドシステム**: Cabal + Stack
- **プロジェクト構造**: マルチパッケージ（contests/*/*.cabal）
- **開発環境**: mkShellで構成、HLSやghcid等のツールを含む
- **特徴**:
  - AtCoder用のコンテスト別ディレクトリ構造
  - 各コンテストに複数の実行ファイル（a-g）
  - 共通のテンプレート（cabal-template/）
  - 大量の依存パッケージ（競技プログラミング用ライブラリ）

### 参考構成（flake-templates/haskell）
- **flake inputs**: haskellNix, nixpkgs (follows haskellNix), flake-utils, treefmt-nix, systems, mcp-servers-nix
- **ビルド方式**: haskell-nix.hix.project
- **GHCバージョン**: GHC 9.8 (`compiler-nix-name = "ghc98"`)
- **設定**: nix/hix.nix で設定を分離
- **バイナリキャッシュ**: nixConfig で IOHKのキャッシュを設定
- **開発ツール**: cabal, hlint, haskell-language-server を shellForで提供

## 移行戦略

### 1. 段階的移行アプローチ
haskell.nixへの移行は破壊的変更のため、慎重に進める必要がある。

### 2. 主要な変更点

#### A. flake.nix の書き換え
**Before (nixpkgs標準)**:
```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  flake-parts.url = "github:hercules-ci/flake-parts";
  treefmt-nix.url = "github:numtide/treefmt-nix";
};
```

**After (haskell.nix)**:
```nix
inputs = {
  haskellNix.url = "github:input-output-hk/haskell.nix";
  nixpkgs.follows = "haskellNix/nixpkgs-unstable";  # ← 重要！
  flake-utils.url = "github:numtide/flake-utils";
  treefmt-nix.url = "github:numtide/treefmt-nix";
  systems.url = "github:nix-systems/default";
};
```

**重要**: `nixpkgs.follows = "haskellNix/nixpkgs-unstable"` を設定しないと、GHCを複数回ビルドすることになる。

#### B. overlays の追加
haskell.nixでは、overlayを使ってプロジェクトを定義する必要がある：

```nix
overlays = [
  haskellNix.overlay
  (final: prev: {
    atcoderProject = final.haskell-nix.hix.project {
      src = ./.;
      evalSystem = "x86_64-linux";
    };
  })
];
pkgs = import nixpkgs {
  inherit system overlays;
  inherit (haskellNix) config;
};
```

#### C. nix/hix.nix の作成
プロジェクト設定を分離：

```nix
{ pkgs, ... }:
{
  compiler-nix-name = "ghc98";  # GHC 9.8.4

  # 開発シェルのツール
  shell.tools = {
    cabal = "latest";
    hlint = "latest";
    haskell-language-server = "latest";
  };

  # マルチパッケージプロジェクトのための設定
  # cabal.project の packages 設定が自動的に読み込まれる
}
```

#### D. nixConfig の追加
IOHKのバイナリキャッシュ設定（必須）：

```nix
nixConfig = {
  extra-substituters = [ "https://cache.iog.io" ];
  extra-trusted-public-keys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" ];
  allow-import-from-derivation = "true";
};
```

#### E. devShell の構成変更
**Before**:
```nix
devShells.default = mkShell {
  buildInputs = [ cabal-install llvmPackages.bintools pkg-config stack ];
  packages = [ ghc984 haskellPackages.haskell-language-server ... ];
  shellHook = ''...''
};
```

**After**:
```nix
flake = pkgs.atcoderProject.flake { };

devShells = flake.devShells // {
  default = pkgs.mkShell {
    inputsFrom = [ flake.devShells.default ];
    packages = [
      # 追加のツール（atcoder-cli, oj等）
      atcoder-cli
      pkgs.online-judge-tools
      pkgs.online-judge-verify-helper
    ];
    shellHook = ''
      acc config oj-path $(which oj)
      export ROOT="$PWD"

      alias t='$ROOT/test.sh $(basename $PWD)'
      alias s='acc s'
      alias ts='t && s'

      new() { $ROOT/new.sh $1 }
    '';
  };
};
```

#### F. packages の構成
haskell.nixは各コンポーネントを個別のパッケージとして公開：

```nix
packages = flake.packages // {
  # デフォルトパッケージは不要（AtCoderは個別実行ファイルを使用）
};
```

#### G. formatter と checks
treefmt-nixの統合を維持：

```nix
treefmtEval = treefmt-nix.lib.evalModule pkgs {
  programs = {
    cabal-fmt.enable = true;
    fourmolu.enable = true;
    nixfmt.enable = true;
  };
};

formatter = treefmtEval.config.build.wrapper;

checks = {
  formatting = treefmtEval.config.build.check self;
};
```

### 3. cabal.project の更新（必要に応じて）

現在の `cabal.project`:
```cabal
packages: ./contests/*/*.cabal

package *
  optimization: 2
  ghc-options: -O2 -Wall -optc-O3
```

haskell.nixでも互換性があるが、以下を追加することを推奨：

```cabal
index-state: 2025-01-30T00:00:00Z  -- Hackageのスナップショットをピン留め
```

これにより、Cabalとhaskell.nixで同じパッケージバージョンを使用することが保証される。

### 4. 既存の機能の維持

#### AtCoder CLI統合
- `atcoder-cli` のビルドはそのまま維持
- `online-judge-tools`, `online-judge-verify-helper` もpkgsから取得

#### スクリプト類
- `new.sh`, `test.sh`, `submit.sh`, `run.sh` は変更不要
- shellHookも同様に機能する

#### テンプレート
- `cabal-template/` と `acc-config/` は変更不要

### 5. ビルド方法の変更

#### Before (nixpkgs標準):
```bash
# 開発環境
nix develop

# コンテストディレクトリで
cabal build all
cabal run a-exe
```

#### After (haskell.nix):
```bash
# 開発環境（変更なし）
nix develop

# コンテストディレクトリで（変更なし）
cabal build all
cabal run a-exe

# Nixからビルドする場合（新機能）
nix build .#abc370:exe:a-exe
```

### 6. 想定される課題と対策

#### 課題1: 大量の依存パッケージ
AtCoderプロジェクトは多数の依存パッケージ（fgl, heaps, massiv, lens等）を使用している。

**対策**:
- haskell.nixは全パッケージをHackageから自動解決
- バイナリキャッシュの活用により、ほとんどのパッケージはビルド不要
- 初回のflake評価は遅いが、materializationで高速化可能（オプション）

#### 課題2: マルチパッケージ構成
`cabal.project` の `packages: ./contests/*/*.cabal` でマルチパッケージを定義。

**対策**:
- haskell.nixの `hix.project` は `cabal.project` を自動読み込み
- 各コンテストパッケージが個別にビルド可能
- HLSも正常に動作する

#### 課題3: IFD（Import From Derivation）
haskell.nixは評価時にDerivationをビルドするため、最初の評価が遅い。

**対策**:
- `allow-import-from-derivation = "true"` を nixConfig に設定
- 2回目以降はキャッシュにより高速化
- 必要に応じて materialization を導入（上級）

#### 課題4: flake-parts の非使用
参考構成は `flake-utils` を使用（flake-partsではない）。

**対策**:
- flake-utils に移行する（推奨）
- または flake-parts と haskell.nix を統合する（やや複雑）
- **本移行では flake-utils を採用**

### 7. 移行手順

#### ステップ1: バックアップ
```bash
git add -A
git commit -m "🚧 Backup before haskell.nix migration"
```

#### ステップ2: flake.nix の書き換え
1. inputs を haskell.nix 用に変更
2. flake-parts から flake-utils に移行
3. overlays を追加
4. devShells, packages, formatter, checks を更新
5. nixConfig を追加

#### ステップ3: nix/hix.nix の作成
```bash
mkdir -p nix
# nix/hix.nix を作成
```

#### ステップ4: cabal.project の更新
```bash
# index-state の追加
```

#### ステップ5: flake.lock の更新
```bash
nix flake update
```

#### ステップ6: 動作確認
```bash
nix develop
cabal build all
./test.sh abc370
```

#### ステップ7: コミット
```bash
git add -A
git commit -m "✨ Migrate to haskell.nix"
```

### 8. 移行後の利点

#### パフォーマンス
- **ビルドキャッシュ**: IOHKのバイナリキャッシュによりビルド時間が大幅短縮
- **正確な依存管理**: Cabal/Stackの解決結果とNixの依存関係が完全一致

#### 柔軟性
- **任意のGHCバージョン**: 簡単に切り替え可能
- **パッケージオーバーライド**: 特定パッケージのバージョン固定や改変が容易
- **クロスコンパイル**: 必要に応じて静的バイナリや他プラットフォーム向けビルドが可能

#### 再現性
- **完全な再現性**: nixpkgsとHackageのスナップショットをピン留め
- **CI統合**: Hydra/GitHub Actionsとの相性が良い

### 9. 移行後の保守

#### GHCバージョンの更新
```nix
# nix/hix.nix
compiler-nix-name = "ghc910";  # GHC 9.10.3 に更新
```

#### パッケージの追加
```bash
# cabalファイルに追加するだけ
# haskell.nixが自動的にHackageから解決
```

#### materialization（オプション）
評価を高速化したい場合：
```bash
# plan.nix の生成
nix build .#plan-nix
# materialized/ に保存
```

### 10. ロールバック計画

移行後に問題が発生した場合：

```bash
git revert HEAD  # 移行コミットを取り消し
nix flake update # flake.lockを更新
nix develop      # 元の環境を復元
```

または、移行前のコミットに戻す：
```bash
git reset --hard <移行前のコミットハッシュ>
```

## まとめ

### 変更ファイル
- ✏️ `flake.nix` - 完全書き換え
- ➕ `nix/hix.nix` - 新規作成
- ✏️ `cabal.project` - index-state追加（オプション）
- 🔒 `flake.lock` - 更新

### 変更不要なファイル
- ✅ `cabal-template/`
- ✅ `acc-config/`
- ✅ `contests/`
- ✅ `*.sh` スクリプト
- ✅ `fourmolu.yaml`

### 期待される効果
- 📦 ビルド時間の短縮（バイナリキャッシュ）
- 🔄 完全な再現性
- 🛠️ より柔軟な開発環境
- 🚀 最新のHaskellインフラストラクチャ

### リスク
- ⚠️ 初回評価の遅延（IFD）
- ⚠️ flake-partsからflake-utilsへの移行
- ⚠️ haskell.nixの学習コスト

移行は慎重に行い、各ステップで動作確認を行うこと。
