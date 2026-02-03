# TODO

## Debt

### DEBT-001: Prefer modern Nix CLI command-not-found suggestions

- Status: resolved locally.
- Affected module: `modules/home/nix-index.nix`.
- Upstream: <https://github.com/nix-community/nix-index/issues/191>
- Resolution: Zsh sources an adapted copy of the upstream handler that always
  selects modern CLI suggestions, without creating or changing profile files.
  The database-backed nix-index package and comma integration are unchanged.
- Maintenance: the adaptation fails to build if upstream removes or changes
  the profile check. Replace it with an upstream format option when available.
- Acceptance: verified single and multiple matches without a modern profile,
  no-match behavior, and exit status 127; suggestions use `nix profile install`
  and `nix shell`.
