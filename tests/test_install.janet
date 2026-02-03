#!/usr/bin/env janet
# Bootstrap routing without building or activating a real configuration.
(import ./support :as t)
(def test-path (os/realpath (dyn :current-file)))
(def test-directory (string/slice test-path 0 (- (length test-path) (length "/test_install.janet"))))
(var source nil)

(defn setup [f]
  (def directory (f :directory))
  (def root (string directory "/checkout with spaces"))
  (def mocks (string directory "/mocks"))
  (def output (string directory "/build output"))
  (each path [root mocks output (string output "/bin")] (os/mkdir path))
  (put f :root root)
  (put f :script (string root "/install.sh"))
  (spit (f :script) (slurp source))
  (each name ["flake.nix" "flake.lock" "config.local.nix"] (spit (string root "/" name) "{}\n"))
  (os/mkdir (string root "/bin"))
  (spit (string root "/bin/jaros") "# mock checkout marker\n")
  (each name ["git" "nix" "sudo" "uname" "darwin-rebuild" "nixos-rebuild" "activate"]
    (def body (string "#!" t/interpreter "\n(import "
      (string/format "%q" (string test-directory "/install-mock.janet")) " :as mock)\n"
      "(defn main [_ & args] (mock/run " (string/format "%q" name) " args))\n"))
    (def paths @[ (string mocks "/" name) ])
    (when (string/has-suffix? "-rebuild" name) (array/push paths (string output "/bin/" name)))
    (when (= name "activate") (array/push paths (string output "/activate")))
    (each path paths (spit path body) (os/chmod path 8r755)))
  (def env (f :env))
  (put env "PATH" (string mocks ":" (os/getenv "PATH")))
  (put env "INSTALL_TEST_PLATFORM" "Darwin")
  (put env "INSTALL_TEST_LOG" (string directory "/calls.jdn"))
  (put env "INSTALL_TEST_OUTPUT" output)
  (put env "INSTALL_TEST_SOURCE" source)
  (put env "INSTALL_TEST_FAIL" nil)
  (put env "INSTALL_TEST_CONFIG_DIRECTORY" nil)
  (put env "INSTALL_TEST_CONFIG_FAIL" nil)
  (def home (string directory "/home"))
  (os/mkdir home)
  (os/mkdir (string home "/Work"))
  (put env "HOME" home))

(defn run [f & args] (t/launch f ["bash" (f :script) ;args]))
(defn piped [f & args] (t/launch f ["bash" "-s" "--" ;args] (slurp source)))
(defn calls [f]
  (def path ((f :env) "INSTALL_TEST_LOG"))
  (if (os/stat path :mode) (parse (slurp path)) @[]))

(t/test "install/help and invalid arguments" (fn [f]
  (t/success (run f "--help"))
  (each args [["--mode"] ["--mode" "unknown"] ["--directory"] ["--ref"] ["--config"] ["--unknown"]]
    (assert (not= 0 ((run f ;args) :status))))
  (t/equal (calls f) @[])))

(t/test "install/dry run needs no local file and executes nothing" (fn [f]
  (os/rm (string (f :root) "/config.local.nix"))
  (each mode ["auto" "home" "darwin"]
    (def result (run f "--mode" mode "--dry-run"))
    (t/success result)
    (t/contains (result :out) "--override-input"))
  (t/equal (calls f) @[])))

(t/test "install/ref cannot inject Git options" (fn [f]
  (each ref ["--upload-pack=unexpected-program" "-c" "--help"]
    (def result (piped f "--clone-only" "--ref" ref "--dry-run"))
    (assert (not= 0 (result :status)))
    (t/contains (result :err) "must not start with a dash"))
  (t/equal (calls f) @[])))

(t/test "install/destination symlink cannot redirect a configuration copy" (fn [f]
  (def config (string (f :directory) "/input.nix"))
  (spit config "{}\n")
  (def target (string (f :directory) "/outside.nix"))
  (def destination (string (f :root) "/config.local.nix"))
  (os/rm destination)
  (os/symlink target destination)
  (def result (piped f "--config" config "--directory" (f :root) "--clone-only"))
  (assert (not= 0 (result :status)))
  (t/contains (result :err) "is a symlink")
  (t/equal (os/stat target :mode) nil)
  (t/equal (calls f) @[])))

(t/test "install/wrong platform is rejected" (fn [f]
  (put (f :env) "INSTALL_TEST_PLATFORM" "Linux")
  (assert (not= 0 ((run f "--mode" "darwin" "--dry-run") :status)))
  (t/equal (calls f) @[])))

(t/test "install/piped dry run never creates checkout" (fn [f]
  (def destination (string (f :directory) "/new checkout"))
  (def result (piped f "--directory" destination "--mode" "home" "--dry-run"))
  (t/success result)
  (each fragment ["git clone" "--override-input"] (t/contains (result :out) fragment))
  (t/equal (os/stat destination :mode) nil)
  (t/equal (calls f) @[])))

(t/test "install/unrelated destination is preserved" (fn [f]
  (def destination (string (f :directory) "/unrelated"))
  (os/mkdir destination)
  (spit (string destination "/keep.txt") "existing contents")
  (assert (not= 0 ((piped f "--directory" destination "--clone-only" "--dry-run") :status)))
  (t/equal (string (slurp (string destination "/keep.txt"))) "existing contents")
  (t/equal (calls f) @[])))

(t/test "install/existing checkout is never reset to a ref" (fn [f]
  (assert (not= 0 ((run f "--ref" "some-revision" "--dry-run") :status)))
  (t/equal (calls f) @[])))

(t/test "install/unrelated Nix checkout is not activated" (fn [f]
  (os/rm (string (f :root) "/bin/jaros"))
  (assert (not= 0 ((run f "--directory" (f :root) "--mode" "home" "--dry-run") :status)))
  (t/equal (calls f) @[])))

(t/test "install/piped clone-only uses default destination and requested ref" (fn [f]
  (t/success (piped f "--clone-only" "--ref" "test-commit"))
  (def destination (string ((f :env) "HOME") "/Work/dotfiles"))
  (assert (os/stat (string destination "/install.sh") :mode))
  (t/equal (calls f) @[
    ["git" "clone" "--no-checkout" "--" "https://github.com/siriniok/dotfiles.git" destination]
    ["git" "-C" destination "fetch" "--depth=1" "--" "origin" "test-commit"]
    ["git" "-C" destination "checkout" "--detach" "FETCH_HEAD"]])) true)

(t/test "install/downloaded script clones then activates" (fn [f]
  (def downloaded (string (f :directory) "/downloaded-install.sh"))
  (spit downloaded (slurp source))
  (def destination (string (f :directory) "/new checkout"))
  (t/success (t/launch f ["bash" downloaded "--directory" destination "--mode" "home"]))
  (def [clone build activate] (calls f))
  (t/equal (length (calls f)) 3)
  (t/equal (slice clone 0 4) ["git" "clone" "--branch" "nix"])
  (t/equal (last clone) destination)
  (t/equal (first build) "nix")
  (assert (some |(= $ (string "path:" destination "/config.local.nix")) build))
  (t/equal activate ["activate"])) true)

(t/test "install/failed clone never builds or activates" (fn [f]
  (put (f :env) "INSTALL_TEST_FAIL" "git")
  (t/equal ((piped f "--mode" "home") :status) 23)
  (t/equal (length (calls f)) 1)
  (t/equal (first (first (calls f))) "git")) true)

(t/test "install/missing local file stops before Nix" (fn [f]
  (os/rm (string (f :root) "/config.local.nix"))
  (def result (run f "--mode" "home"))
  (assert (not= 0 (result :status)))
  (t/contains (result :err) "config.local.nix")
  (t/equal (calls f) @[])) true)

(t/test "install/home activation preserves local path" (fn [f]
  (t/success (run f "--mode" "home"))
  (t/equal (calls f) @[
    ["nix" "--extra-experimental-features" "nix-command flakes" "build"
     "--no-write-lock-file" "--override-input" "local-config"
     (string "path:" (f :root) "/config.local.nix") "--no-link" "--print-out-paths"
     (string (f :root) "#homeConfigurations.default.activationPackage")]
    ["activate"]])) true)

(t/test "install/Darwin bootstraps pinned rebuild before sudo" (fn [f]
  (t/success (run f))
  (t/equal (length (calls f)) 2)
  (def [build switch] (calls f))
  (each argument ["--inputs-from" (f :root)] (assert (some |(= $ argument) build)))
  (t/equal (last build) "nix-darwin#darwin-rebuild")
  (t/equal (slice switch 0 3) ["sudo" (string ((f :env) "INSTALL_TEST_OUTPUT") "/bin/darwin-rebuild") "switch"])
  (each argument [(string (f :root) "#darwin-laptop") (string "path:" (f :root) "/config.local.nix")]
    (assert (some |(= $ argument) switch)))) true)

(t/test "install/build failure never activates" (fn [f]
  (put (f :env) "INSTALL_TEST_FAIL" "nix")
  (t/equal ((run f) :status) 23)
  (t/equal (length (calls f)) 1)) true)

(t/test "install/local configuration chooses clone destination" (fn [f]
  (def destination (string (f :directory) "/configured checkout"))
  (put (f :env) "INSTALL_TEST_CONFIG_DIRECTORY" destination)
  (def config (string/format "{ me.dotfilesDirectory = %q; }\n" destination))
  (spit (string (f :root) "/config.local.nix") config)
  (t/success (run f "--clone-only"))
  (t/equal (last (first (calls f))) destination)
  (t/equal (string (slurp (string destination "/config.local.nix"))) config)) true)

(t/test "install/clones into an existing empty configured directory" (fn [f]
  (def destination (string (f :directory) "/empty checkout"))
  (os/mkdir destination)
  (put (f :env) "INSTALL_TEST_CONFIG_DIRECTORY" destination)
  (t/success (run f "--clone-only"))
  (t/equal (last (first (calls f))) destination)
  (assert (os/stat (string destination "/flake.nix") :mode))
  (assert (os/stat (string destination "/config.local.nix") :mode))) true)

(t/test "install/piped installer reads configuration from current directory" (fn [f]
  (def destination (string (f :directory) "/configured checkout"))
  (put (f :env) "INSTALL_TEST_CONFIG_DIRECTORY" destination)
  (spit (string (f :directory) "/config.local.nix") "{ me.hostname = \"local\"; }\n")
  (t/success (piped f "--clone-only"))
  (t/equal (last (first (calls f))) destination)
  (t/equal (slurp (string destination "/config.local.nix"))
    (slurp (string (f :directory) "/config.local.nix")))) true)

(t/test "install/explicit configuration supports a downloaded installer" (fn [f]
  (def destination (string (f :directory) "/configured checkout"))
  (put (f :env) "INSTALL_TEST_CONFIG_DIRECTORY" destination)
  (t/success (piped f "--config" (string (f :root) "/config.local.nix") "--mode" "home"))
  (def [clone build activate] (calls f))
  (t/equal (last clone) destination)
  (assert (some |(= $ (string "path:" destination "/config.local.nix")) build))
  (t/equal activate ["activate"])) true)

(t/test "install/conflicting explicit destination is rejected" (fn [f]
  (put (f :env) "INSTALL_TEST_CONFIG_DIRECTORY" (string (f :directory) "/configured checkout"))
  (def result (run f "--directory" (string (f :directory) "/other checkout") "--clone-only"))
  (assert (not= 0 (result :status)))
  (t/contains (result :err) "conflicts")
  (t/equal (calls f) @[])))

(t/test "install/configured dry run never writes a checkout" (fn [f]
  (def destination (string (f :directory) "/configured checkout"))
  (put (f :env) "INSTALL_TEST_CONFIG_DIRECTORY" destination)
  (t/success (run f "--clone-only" "--dry-run"))
  (t/equal (os/stat destination :mode) nil)
  (t/equal (calls f) @[])))

(t/test "install/configuration errors stop before cloning" (fn [f]
  (put (f :env) "INSTALL_TEST_CONFIG_FAIL" "1")
  (t/equal ((run f "--clone-only") :status) 23)
  (t/equal (calls f) @[])))

(t/test "install/existing destination configuration is preserved" (fn [f]
  (def config (string (f :directory) "/other-config.nix"))
  (spit config "{ me.hostname = \"different\"; }\n")
  (put (f :env) "INSTALL_TEST_CONFIG_DIRECTORY" (f :root))
  (def result (piped f "--config" config "--clone-only"))
  (assert (not= 0 (result :status)))
  (t/contains (result :err) "different config.local.nix")
  (t/equal (string (slurp (string (f :root) "/config.local.nix"))) "{}\n")
  (t/equal (calls f) @[])))

(defn main [_ & args]
  (set source (os/realpath (or (get args 0) (string test-directory "/../install.sh"))))
  (t/run-tests (or (get args 1) "janet") setup))
