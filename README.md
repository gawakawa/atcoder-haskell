# AtCoder with Haskell

AtCoder competitive programming environment using Haskell with GHC 9.8.4, matching AtCoder's exact library versions.

## Setup

1. Install [Nix](https://nixos.org/download.html) with flakes enabled and [direnv](https://direnv.net/)
2. Clone and setup:
   ```bash
   cd atcoder-haskell
   direnv allow
   ```
3. Login to AtCoder (first time only):
   ```bash
   # Setup browser cookie for CLI tools
   # See: https://github.com/key-moon/aclogin
   aclogin

   # Login to atcoder-cli
   acc login
   ```

## Usage

```bash
# Create a new contest (from repository root)
new.sh abc321

# Navigate to problem directory and test
cd contests/abc321/a
t  # Run tests for current problem
```

## Directory Structure

```
atcoder-haskell/
├── flake.nix            # Nix flake with haskell.nix
├── flake.lock           # Nix lock file
├── cabal.project        # Cabal project configuration
├── nix/                 # External package definitions
│   ├── aclogin.nix     # aclogin package
│   └── atcoder-cli.nix # atcoder-cli package
├── cabal-template/      # Template files
│   ├── Main.hs         # Solution template
│   ├── hie.yaml        # HLS configuration
│   └── task.cabal      # Cabal configuration template
├── scripts/
│   ├── new.sh          # Contest creation script
│   ├── test.sh         # Test execution script
│   └── run.sh          # Execution script
└── contests/            # Contest directory
    └── abc321/          # Example: ABC321 contest
        ├── a/           # Problem A directory
        │   ├── Main.hs # Problem A solution
        │   └── tests/  # Test cases
        ├── b/
        │   └── ...
        ├── ...
        ├── abc321.cabal # Cabal file for the contest
        ├── hie.yaml     # HLS configuration
        └── contest.acc.json # AtCoder CLI configuration
```

## Commit Messages

Commit messages in the contests/ directory indicate the solution status.

| Emoji | Meaning          |
|-------|------------------|
| 🎉    | Not attempted    |
| 🚧    | Work in progress |
| ✨    | AC               |
| 🌱    | Editorial AC     |
