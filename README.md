# AtCoder with Haskell
## Usage

```bash
# Enter the nix shell
nix develop

# Create a new contest
./new.sh abc321

# Implement and run tests
../../test.sh a

# Submit by pasting your code
```

## Directory Structure

```
atcoder/
├── flake.nix            # Nix environment definition
├── flake.lock           # Nix lock file
├── cabal.project        # Cabal project configuration
├── cabal-template/      # Template files
│   ├── Main.hs         # Solution template
│   ├── hie.yaml        # HLS configuration
│   └── task.cabal      # Cabal configuration template
├── new.sh               # Contest creation script
├── test.sh              # Test execution script
├── run.sh               # Execution script
└── contests/            # Contest directory
    └── abc321/          # Example: ABC321 contest
        ├── a/           # Problem A directory
        │   ├── Main.hs # Problem A solution
        │   └── tests/  # Test cases
        ├── b/
        │   └── ...
        ├── ...
        ├── abc123.cabal # Cabal file for the contest
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
