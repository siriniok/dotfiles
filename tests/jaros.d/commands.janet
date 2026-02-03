(import ../../bin/jaros.d/commands :as commands)
(import ../support :as t)

(t/test "commands/activation routes across platforms" (fn [_]
  (def root "/checkout with spaces")
  (def common ["--no-write-lock-file" "--override-input" "local-config" (string "path:" root "/config.local.nix")])
  (each [platform nixos expected]
    [[:linux true ["nixos-rebuild" "switch" "--flake" (string root "#nixos-laptop") "--sudo" ;common]]
     [:macos false ["sudo" "darwin-rebuild" "switch" "--flake" (string root "#darwin-laptop") ;common]]
     [:linux false ["nix" "run" ;common "."]]]
    (t/equal (commands/activation-command platform nixos root) expected))))

(t/test "commands/plans preserve forwarded arguments" (fn [_]
  (each [command prefix]
    [["update" ["nix" "flake" "update"]]
     ["setup-keyd" ["nix" "run" "--no-write-lock-file" ".#keyd-setup" "--"]]
     ["lint" ["nix" "fmt"]]
     ["check" ["nix" "flake" "check"]]
     ["dev" ["nix" "develop"]]
     ["ci-nixos" ["nix" "build" "--no-update-lock-file" "--no-link" "--print-build-logs"
       ".#nixosConfigurations.nixos-laptop.config.system.build.toplevel"]]
     ["ci-darwin" ["nix" "build" "--no-update-lock-file" "--no-link" "--print-build-logs"
       ".#darwinConfigurations.darwin-laptop.system"]]
     ["secrets-history" ["gitleaks" "git" "--redact" "--no-banner" "--log-opts=--all" "."]]]
    (t/equal (commands/command-plan command ["extra argument"] "/repo" :linux false)
      [[;prefix "extra argument"]]))
  (t/equal (commands/command-plan "ci-home" [] "/repo" :linux false) :home)
  (t/equal (commands/command-plan "missing" [] "/repo" :linux false) nil)))
