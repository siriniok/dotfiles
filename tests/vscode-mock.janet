# Network-free Marketplace/Nix subprocess fixture; jq remains the real parser.
(defn run [program args]
  (def log (os/getenv "VSCODE_TEST_LOG"))
  (with [file (file/open log :a)] (file/write file (string/format "%j\n" [program args])))
  (when (and (= "prefetch" (os/getenv "VSCODE_TEST_FAIL"))
             (= program "nix") (= "store" (first args))
             (string/find "/second/" (last args)))
    (os/exit 23))
  (case program
    "curl" (print (if (= "manifest" (os/getenv "VSCODE_TEST_FAIL")) "not JSON" `{"version":"2.3.4"}`))
    "nix" (case (first args)
      "eval" (print (or (os/getenv "VSCODE_TEST_ENTRIES") "example\tfirst\nexample\tsecond"))
      "build" (do (print (os/getenv "VSCODE_TEST_TOOLS")) (print (os/getenv "VSCODE_TEST_TOOLS")))
      "store" (print `{"hash":"sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="}`)
      (os/exit 24))
    (os/exit 25)))
