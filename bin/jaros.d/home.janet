# Build every standalone Home Manager profile for the selected/native platform.
(import ./process :as process)

(defn build [arguments dry-run]
  (def native-command ["nix" "eval" "--raw" "--impure" "--expr" "builtins.currentSystem"])
  (var system (os/getenv "NIX_SYSTEM"))
  (unless (and system (not= system ""))
    (if dry-run
      (do (process/execute native-command true) (set system "<native-system>"))
      (set system (string/trim (process/capture native-command)))))
  (eprintf "Discovering Home Manager configurations for %s..." system)
  # Have Nix quote attribute names so this library needs no JSON dependency.
  (def names-command ["nix" "eval" "--no-update-lock-file" "--raw"
    (string ".#legacyPackages." system ".homeConfigurations")
    "--apply" "configs: builtins.concatStringsSep \"\\n\" (map builtins.toJSON (builtins.attrNames configs))"])
  (def targets
    (if dry-run
      (do
        (process/execute names-command true)
        ["<discovered Home Manager activation packages>"])
      (do
        (def names (process/capture names-command))
        (when (= names "")
          (eprintf "No Home Manager configurations exported for %s" system)
          (os/exit 1))
        (def targets (map
          (fn [name] (string ".#legacyPackages." system ".homeConfigurations." name ".activationPackage"))
          (string/split "\n" names)))
        (eprintf "Building %d Home Manager configuration(s)..." (length targets))
        targets)))
  (process/execute ["nix" "build" "--no-update-lock-file" "--no-link" "--print-build-logs"
    ;arguments ;targets] dry-run))
