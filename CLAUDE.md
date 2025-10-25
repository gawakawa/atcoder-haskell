# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands
- Create new contest: `./new.sh [contest-id]` (from repository root)
- Test problem: `./test.sh [problem-id]` or `t` (from contest directory)
- Run with first test case: `./run.sh [contest-id] [problem-id]` (from repository root)
- Submit solution: `./submit.sh [problem-id]` or `s` (from contest directory)
- Format code: `nix fmt` (runs fourmolu, nixfmt, cabal-fmt via treefmt-nix)

## Development Environment
- Enter dev shell: `nix develop`
- Shell aliases:
  - `t`: `./test.sh $(basename $PWD)` (test current problem)
  - `s`: `acc s` (submit current problem)
  - `ts`: `t && s` (test then submit)
  - `new [contest-id]`: create new contest

## Project Structure
- Main solutions: `contests/[contest-id]/[problem-id]/Main.hs`
- Test cases: `contests/[contest-id]/[problem-id]/tests/sample-N.in`/`.out`
- Template: `cabal-template/Main.hs` (copied when creating new contests)
- Cabal files: `[contest-id].cabal` generated per contest directory
- hie.yaml: Auto-generated per contest directory for HLS

## Code Style
- Format with Fourmolu (80 character limit)
- Use qualified imports with standard aliases: `BS` (ByteString), `IM` (IntMap), `VU` (Vector.Unboxed), etc.
- Enable `{-# LANGUAGE StrictData #-}`
- Prefer `UArray` for performance-critical matrix operations
- Use exhaustive pattern matching with explicit edge case handling
- Use standard utility functions for input parsing: `ints`, `integers`, `intMat`, etc.
  - `ints :: IO [Int]`: Read a line of integers
  - `integers :: IO [Integer]`: Read a line of large integers
  - `intMat :: Int -> Int -> IO (UArray (Int, Int) Int)`: Read h×w matrix (1-indexed)
- Use `where` instead of `let` for local definitions
- Add type annotations for all bindings including local variables
- Use `pure` instead of `return`
- Use `<$>` instead of `fmap`
- Use `>>>` as pipeline operator (from Control.Arrow)

## Utility Functions
The template includes these helper functions:
- `binarySearch :: (Ord a, Integral a) => a -> a -> (a -> Bool) -> a`
- `ceiling :: (Integral a) => a -> a -> a` (ceiling division)
- `fromBase :: Int -> String -> Int`, `toBase :: Int -> Int -> String` (base conversion)
- `showIntMat :: UArray (Int, Int) Int -> String` (matrix to string)

## Build Configuration
- Language: GHC2021
- GHC flags: `-threaded -rtsopts -with-rtsopts=-N -Wall -O2 -optc-O3`
- Dependencies: base, array, attoparsec, bytestring, containers, deepseq, extra, mtl, parsec, text, transformers, unordered-containers, vector

## Commit Message Convention
Use these emojis for commits in contests/ directory:
- 🎉: Not attempted
- 🚧: Work in progress
- ✨: AC (Accepted)
- 🌱: Editorial AC

## References
- https://hoogle.haskell.org/ (Haskell function search API - searchable by function name or type)
