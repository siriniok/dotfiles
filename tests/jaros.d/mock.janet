# Fake external commands. Logs use Janet data notation, not a shell or JSON parser.
(defn run [name args]
  (def log (os/getenv "JAROS_TEST_LOG"))
  (def calls (if (os/stat log :mode) (parse (slurp log)) @[]))
  (array/push calls {:argv [name ;args] :cwd (os/cwd) :docker (os/getenv "DOCKER_HOST")})
  (spit log (string/format "%j" calls))
  (def stage (if (some |(= $ "--expr") args) "native"
    (if (some |(string/find "packageInventory" $) args) "packages"
      (if (some |(= $ ".#legacyPackages") args) "platforms"
        (if (= (get args 0) "eval") "names" "build")))))
  (when (or (= name (os/getenv "JAROS_TEST_FAIL"))
            (and (= name "nix") (= stage (os/getenv "JAROS_TEST_STAGE"))))
    (os/exit 23))
  (when (= name "nix")
    (case stage
      "native" (print "x86_64-linux")
      "platforms" (file/write stdout (or (os/getenv "JAROS_TEST_PLATFORMS") "x86_64-linux\naarch64-darwin"))
      "packages" (file/write stdout (or (os/getenv "JAROS_TEST_PACKAGES")
        "free\talpha-1.0\tMIT\tUpstream team\thome/default\nunfree\tzeta-2.0\tUnfree\tmaint: Nix maintainer\tdev/default\nunknown\tcustom\t\t\tflake/custom"))
      "names" (file/write stdout (string/join
        (map |(string/format "%q" $) (parse (os/getenv "JAROS_TEST_NAMES"))) "\n"))
      nil)))
