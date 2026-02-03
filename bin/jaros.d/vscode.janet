# Refresh only the declared Marketplace pins; language/theme packages follow nixpkgs.
(defn capture [argv &opt input]
  (def proc (os/spawn argv :p (merge {:out :pipe} (if input {:in :pipe} {}))))
  (def heartbeat (ev/go (fn []
    (protect (forever
      (ev/sleep 15)
      (eprintf "Still working: %s..." (argv 0)))))))
  (defer (do (ev/cancel heartbeat :done) (os/proc-close proc))
    (when input
      (ev/write (proc :in) input)
      (ev/close (proc :in)))
    (def output (string (or (ev/read (proc :out) :all) "")))
    (def status (os/proc-wait proc))
    (assert (= 0 status) (string/format "%s exited with status %d" (argv 0) status))
    (string/trim output)))

(defn component? [value]
  (and (> (length value) 0)
       (peg/match '(sequence (some (choice (range "az" "AZ" "09") "-" "_" "." "+")) -1) value)))

(defn asset-url [publisher name version asset]
  (string "https://" publisher ".gallery.vsassets.io/_apis/public/gallery/publisher/"
          publisher "/extension/" name "/" version "/assetbyname/" asset))

(defn update [root]
  (os/cd root)
  (def pins (string root "/lib/vscode-marketplace.nix"))
  (eprint "Reading declared VS Code extensions...")
  (def rows (string/split "\n" (capture
    ["nix" "eval" "--raw" "--file" pins "--apply"
     `extensions: builtins.concatStringsSep "\n" (map (e: e.publisher + "\t" + e.name) extensions)`])))
  (def seen @{})
  (def extensions (map (fn [row]
    (def fields (string/split "\t" row))
    (assert (and (= 2 (length fields)) (every? (map component? fields))) "Invalid extension declaration")
    (assert (not (seen row)) "Duplicate extension declaration")
    (put seen row true)
    fields) rows))

  # --inputs-from resolves both tools through this checkout's locked nixpkgs.
  (eprint "Preparing tools from locked nixpkgs...")
  (def tools (string/split "\n" (capture
    ["nix" "build" "--no-link" "--print-out-paths" "--no-update-lock-file"
     "--inputs-from" root "nixpkgs#curl" "nixpkgs#jq"])))
  (assert (= 2 (length tools)) "Expected curl and jq store paths")
  (defn tool [name]
    (or (some (fn [path]
                (def executable (string path "/bin/" name))
                (when (= :file (os/stat executable :mode)) executable)) tools)
        (error (string "Missing locked tool: " name))))
  (def curl (tool "curl"))
  (def jq (tool "jq"))
  (def output @"# Marketplace-only extensions, refreshed by the weekly CI workflow.\n[\n")
  (eachp [index [publisher name]] extensions
    (eprintf "[%d/%d] Reading %s.%s..." (+ index 1) (length extensions) publisher name)
    (def manifest (capture [curl "--fail" "--silent" "--show-error" "--location"
                           "--proto" "=https" "--proto-redir" "=https" "--tlsv1.2"
      "--retry" "3" "--connect-timeout" "30" "--max-time" "180"
      (asset-url publisher name "latest" "Microsoft.VisualStudio.Code.Manifest")]))
    (def version (capture [jq "-er" ".version | strings | select(length > 0)"] manifest))
    (assert (component? version) "Invalid Marketplace version")
    (eprintf "[%d/%d] Downloading and hashing %s.%s %s..."
      (+ index 1) (length extensions) publisher name version)
    # Hash exactly the URL used by Nix builds, rather than the mutable /latest VSIX.
    (def fetched (capture ["nix" "store" "prefetch-file" "--json"
      (asset-url publisher name version "Microsoft.VisualStudio.Services.VSIXPackage")]))
    (def hash (capture [jq "-er" ".hash | strings | select(startswith(\"sha256-\"))"] fetched))
    (buffer/push-string output (string/format
      "  {\n    publisher = %q;\n    name = %q;\n    version = %q;\n    sha256 = %q;\n  }\n"
      publisher name version hash)))
  (buffer/push-string output "]\n")
  # Replace the file only after every lookup and download succeeds.
  (def temporary (string pins "." (os/getpid) ".tmp"))
  (defer (when (os/stat temporary) (os/rm temporary))
    (spit temporary output)
    (os/rename temporary pins))
  (eprintf "Updated %d VS Code Marketplace extensions." (length extensions)))
