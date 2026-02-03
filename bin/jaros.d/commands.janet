# Command descriptions and platform-independent command plans.

(def descriptions
  [["run" "Activate the local NixOS, Darwin, or Home Manager configuration"]
   ["update" "Update the flake lock file"]
   ["clean" "Collect unused Nix paths and optimise store storage"]
   ["packages" "List configured packages by license; --all-platforms includes every platform"]
   ["setup-keyd" "Install shared keyd mappings and the system service on Ubuntu/Linux"]
   ["lint" "Format Nix files"]
   ["check" "Run flake checks"]
   ["ci-check" "Run workflow lint, pre-commit, and flake checks"]
   ["ci-home" "Build standalone Home Manager profiles"]
   ["ci-nixos" "Build the nixos-laptop system without activation"]
   ["ci-darwin" "Build the darwin-laptop system without activation"]
   ["ci-local" "Run the Linux Actions job in rootless Docker"]
   ["ci-plan" "List the local Actions execution plan"]
   ["secrets-history" "Scan all Git history for credentials (redacted)"]
   ["dev" "Enter the Nix development shell"]])

(defn help []
  (print "Usage: jaros [--dry-run] COMMAND [ARGS...]\n")
  (each [name description] descriptions
    (printf "  %-17s %s" name description))
  (print "\nExtra arguments are forwarded, except for run, clean, ci-check, and packages."))

# Keep profile selection independent of machine hostnames and usernames.
(defn activation-command [platform nixos? root]
  (def local-input (string "path:" root "/config.local.nix"))
  (cond
    (and (= platform :linux) nixos?)
    ["nixos-rebuild" "switch" "--flake" (string root "#nixos-laptop")
     "--sudo" "--no-write-lock-file" "--override-input" "local-config" local-input]
    (= platform :macos)
    ["sudo" "darwin-rebuild" "switch" "--flake" (string root "#darwin-laptop")
     "--no-write-lock-file" "--override-input" "local-config" local-input]
    ["nix" "run" "--no-write-lock-file" "--override-input" "local-config" local-input "."]))

(defn command-plan [command args root platform nixos?]
  (case command
    "run" [(activation-command platform nixos? root)]
    "update" [["nix" "flake" "update" ;args]]
    "setup-keyd" [["nix" "run" "--no-write-lock-file" ".#keyd-setup" "--" ;args]]
    "clean" [["nix" "store" "gc"] ["nix" "store" "optimise"]]
    "lint" [["nix" "fmt" ;args]]
    "check" [["nix" "flake" "check" ;args]]
    "ci-check" [["actionlint"]
                ["pre-commit" "run" "--all-files"]
                ["nix" "flake" "check" "--no-update-lock-file" "--print-build-logs"]]
    "ci-home" :home
    "packages" :packages
    "ci-nixos" [["nix" "build" "--no-update-lock-file" "--no-link" "--print-build-logs"
                 ".#nixosConfigurations.nixos-laptop.config.system.build.toplevel" ;args]]
    "ci-darwin" [["nix" "build" "--no-update-lock-file" "--no-link" "--print-build-logs"
                  ".#darwinConfigurations.darwin-laptop.system" ;args]]
    "ci-local" [["act" "workflow_dispatch" "--workflows" ".github/workflows/ci.yaml"
                 "--job" "nix" "--matrix" "os:ubuntu-24.04" ;args]]
    "ci-plan" [["act" "workflow_dispatch" "--workflows" ".github/workflows/ci.yaml"
                "--job" "nix" "--matrix" "os:ubuntu-24.04" "--list" ;args]]
    "secrets-history" [["gitleaks" "git" "--redact" "--no-banner" "--log-opts=--all" "." ;args]]
    "dev" [["nix" "develop" ;args]]
    nil))
