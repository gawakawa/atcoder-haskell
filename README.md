# AtCoder with Haskell
## Usage

```bash
# Enter the nix shell
nix develop

# Create a new contest
./new.sh abc321

# Navigate to problem directory
cd contests/abc321/a

# Run tests
t  # alias for ../../test.sh $(basename $PWD)
```

## Directory Structure

```
atcoder-haskell/
├── flake.nix            # Nix flake with haskell.nix
├── flake.lock           # Nix lock file
├── cabal.project        # Cabal project configuration
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
