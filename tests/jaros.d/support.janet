# Jaros-specific checkout fixtures and command logs; the shared runner owns cleanup.
(import ../support :as t)
# Paths are resolved from this test file, independently of the caller's cwd.
(def test-file (os/realpath (dyn :current-file)))
(def test-directory (string/slice test-file 0 (- (length test-file) (length "/support.janet"))))
(def source-bin (os/realpath (string test-directory "/../../bin")))

(defn copy-tree [source target]
  (if (= :directory (os/stat source :mode))
    (do (os/mkdir target)
      (each name (os/dir source) (copy-tree (string source "/" name) (string target "/" name))))
    (spit target (slurp source))))

(defn setup [f]
  (def directory (f :directory))
  (def root (string directory "/checkout with spaces"))
  (os/mkdir root)
  (os/mkdir (string root "/bin"))
  (copy-tree (string source-bin "/jaros") (string root "/bin/jaros"))
  (copy-tree (string source-bin "/jaros.d") (string root "/bin/jaros.d"))
  (spit (string root "/config.local.nix") "{}\n")
  (def mocks (string directory "/mocks"))
  (os/mkdir mocks)
  (each name ["nix" "nixos-rebuild" "sudo" "act" "gitleaks" "actionlint" "pre-commit"]
    (def path (string mocks "/" name))
    (spit path (string "#!" t/interpreter "\n(import "
      (string/format "%q" (string test-directory "/mock.janet")) " :as mock)\n"
      "(defn main [_ & args] (mock/run " (string/format "%q" name) " args))\n"))
    (os/chmod path 8r755))
  (def environment (f :env))
  (each key ["DOCKER_HOST" "NIX_SYSTEM" "JAROS_TEST_FAIL" "JAROS_TEST_STAGE"
             "JAROS_TEST_PACKAGES" "JAROS_TEST_PLATFORMS"] (put environment key nil))
  (put environment "PATH" (string mocks ":" (os/getenv "PATH")))
  (put environment "JAROS_TEST_LOG" (string directory "/calls.jdn"))
  (put environment "JAROS_TEST_NAMES" "[\"default\"]")
  (put environment "XDG_RUNTIME_DIR" (string directory "/runtime"))
  (put f :root root)
  (put f :interpreter t/interpreter))

(defn run [fixture & args]
  (t/launch fixture [(fixture :interpreter) (string (fixture :root) "/bin/jaros") ;args]))
(defn calls [fixture]
  (def path ((fixture :env) "JAROS_TEST_LOG"))
  (if (os/stat path :mode) (parse (slurp path)) @[]))
(defn clear [fixture]
  (def path ((fixture :env) "JAROS_TEST_LOG"))
  (when (os/stat path :mode) (os/rm path)))
