(import ../support :as t)
(import ./support :as fixture)
(def mock-source (os/realpath (string fixture/test-directory "/../vscode-mock.janet")))

(defn setup [f]
  (def root (f :root))
  (os/mkdir (string root "/lib"))
  (spit (string root "/lib/vscode-marketplace.nix") "original pins\n")
  (spit (string root "/bin/update-vscode-exts") (slurp (string fixture/source-bin "/update-vscode-exts")))
  (def mocks (string (f :directory) "/mocks"))
  (os/mkdir (string mocks "/bin"))
  (each [program path] [["nix" (string mocks "/nix")] ["curl" (string mocks "/bin/curl")]]
    (spit path (string "#!" t/interpreter "\n(import " (string/format "%q" mock-source) " :as mock)\n"
      "(defn main [_ & args] (mock/run " (string/format "%q" program) " args))\n"))
    (os/chmod path 8r755))
  (def jq (string mocks "/bin/jq"))
  (spit jq (string "#!" t/interpreter "\n(defn main [_ & args] (os/exit (os/execute [\"jq\" ;args] :p)))\n"))
  (os/chmod jq 8r755)
  (put (f :env) "VSCODE_TEST_TOOLS" mocks)
  (put (f :env) "VSCODE_TEST_LOG" (string (f :directory) "/vscode-calls.jdn")))

(defn run [f]
  (t/launch f [t/interpreter (string (f :root) "/bin/update-vscode-exts")]))
(defn pins [f] (string (slurp (string (f :root) "/lib/vscode-marketplace.nix"))))

(t/test "vscode/version-specific hashes, locked tools, progress and complete output" (fn [f]
  (setup f)
  (def result (run f))
  (t/success result)
  (t/contains (result :err) "[2/2] Downloading and hashing example.second 2.3.4")
  (each expected ["publisher = \"example\";" "name = \"first\";" "name = \"second\";"
                  "version = \"2.3.4\";" "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="]
    (t/contains (pins f) expected))
  (def calls (slurp ((f :env) "VSCODE_TEST_LOG")))
  (each expected ["--inputs-from" "--no-update-lock-file" "nixpkgs#curl" "nixpkgs#jq"
                  "--proto-redir" "=https" "--tlsv1.2"
                  "/latest/assetbyname/Microsoft.VisualStudio.Code.Manifest"
                  "/2.3.4/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"]
    (t/contains calls expected))
  (assert (not (string/find "/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage" calls)))))

(t/test "vscode/failed download or malformed metadata preserves existing pins" (fn [f]
  (setup f)
  (each stage ["prefetch" "manifest"]
    (put (f :env) "VSCODE_TEST_FAIL" stage)
    (assert (not= 0 ((run f) :status)))
    (t/equal (pins f) "original pins\n"))))

(t/test "vscode/empty, duplicate and unsafe declarations fail before downloading" (fn [f]
  (setup f)
  (each rows ["" "example\tfirst\nexample\tfirst" "example\t../unsafe"]
    (put (f :env) "VSCODE_TEST_ENTRIES" rows)
    (assert (not= 0 ((run f) :status)))
    (t/equal (pins f) "original pins\n"))))
