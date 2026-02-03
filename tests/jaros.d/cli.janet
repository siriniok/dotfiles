(import ../support :as t)
(import ./support :as fixture)

(t/test "cli/help and unknown commands" (fn [f]
  (each args [[] ["help"] ["--help"] ["-h"]]
    (def result (fixture/run f ;args))
    (t/success result)
    (t/contains (result :out) "ci-check"))
  (t/equal ((fixture/run f "unknown") :status) 2)
  (t/equal (fixture/calls f) @[])))

(t/test "cli/dispatch and checkout directory" (fn [f]
  (each [command prefix] [["update" ["nix" "flake" "update"]]
                         ["lint" ["nix" "fmt"]] ["check" ["nix" "flake" "check"]]
                         ["dev" ["nix" "develop"]]]
    (t/success (fixture/run f command "extra argument"))
    (def call (last (fixture/calls f)))
    (t/equal (call :argv) [;prefix "extra argument"])
    (t/equal (call :cwd) (f :root)))))

(t/test "cli/check order and failure propagation" (fn [f]
  (t/success (fixture/run f "ci-check"))
  (t/equal (map |(get ($ :argv) 0) (fixture/calls f)) @["actionlint" "pre-commit" "nix"])
  (fixture/clear f)
  (put (f :env) "JAROS_TEST_FAIL" "pre-commit")
  (t/equal ((fixture/run f "ci-check") :status) 23)
  (t/equal (map |(get ($ :argv) 0) (fixture/calls f)) @["actionlint" "pre-commit"])))

(t/test "cli/cleanup collects before optimising and stops on failure" (fn [f]
  (t/success (fixture/run f "clean"))
  (t/equal (map |($ :argv) (fixture/calls f)) @[["nix" "store" "gc"] ["nix" "store" "optimise"]])
  (fixture/clear f)
  (put (f :env) "JAROS_TEST_FAIL" "nix")
  (t/equal ((fixture/run f "clean") :status) 23)
  (t/equal (length (fixture/calls f)) 1)))

(t/test "cli/dry runs execute no commands" (fn [f]
  (each command ["run" "update" "clean" "ci-check" "ci-home" "ci-local" "ci-plan" "secrets-history"]
    (def result (fixture/run f "--dry-run" command))
    (t/success result)
    (t/contains (result :out) "$ "))
  (t/equal (fixture/calls f) @[])))

(t/test "cli/activation requires local configuration" (fn [f]
  (os/rm (string (f :root) "/config.local.nix"))
  (def result (fixture/run f "run"))
  (t/equal (result :status) 2)
  (t/contains (result :err) "config.local.nix")
  (t/success (fixture/run f "--dry-run" "run"))
  (t/equal (fixture/calls f) @[])))

(t/test "cli/fixed commands reject extra arguments" (fn [f]
  (each command ["run" "clean" "ci-check"] (t/equal ((fixture/run f command "unexpected") :status) 2))
  (t/equal (fixture/calls f) @[])))

(t/test "cli/rootless Docker and literal arguments" (fn [f]
  (def argument "TOKEN=a 'b'; $(touch sentinel)")
  (t/success (fixture/run f "ci-local" "--dryrun" "--secret" argument))
  (def call (last (fixture/calls f)))
  (t/equal (tuple ;(slice (call :argv) (- (length (call :argv)) 3))) ["--dryrun" "--secret" argument])
  (t/equal (call :docker) (string "unix://" ((f :env) "XDG_RUNTIME_DIR") "/docker.sock"))
  (t/equal (os/stat (string (f :root) "/sentinel") :mode) nil)
  (put (f :env) "DOCKER_HOST" "unix:///custom/docker.sock")
  (t/success (fixture/run f "ci-local"))
  (t/equal ((last (fixture/calls f)) :docker) "unix:///custom/docker.sock")))

(t/test "cli/plan does not require Docker" (fn [f]
  (put (f :env) "XDG_RUNTIME_DIR" nil)
  (t/success (fixture/run f "ci-plan"))
  (assert (some |(= $ "--list") ((last (fixture/calls f)) :argv)))
  (fixture/clear f)
  (t/equal ((fixture/run f "ci-local") :status) 2)
  (t/equal (fixture/calls f) @[])))
