(import ../support :as t)
(import ./support :as fixture)

(t/test "home/native system and checkout directory" (fn [f]
  (t/success (fixture/run f "ci-home"))
  (def [native names build] (fixture/calls f))
  (t/equal (native :argv) ["nix" "eval" "--raw" "--impure" "--expr" "builtins.currentSystem"])
  (assert (some |(= $ ".#legacyPackages.x86_64-linux.homeConfigurations") (names :argv)))
  (t/equal (build :argv) ["nix" "build" "--no-update-lock-file" "--no-link" "--print-build-logs"
    ".#legacyPackages.x86_64-linux.homeConfigurations.\"default\".activationPackage"])
  (each call (fixture/calls f) (t/equal (call :cwd) (f :root)))))

(t/test "home/system override skips native query" (fn [f]
  (put (f :env) "NIX_SYSTEM" "aarch64-darwin")
  (t/success (fixture/run f "ci-home"))
  (t/equal (length (fixture/calls f)) 2)
  (t/contains (last ((last (fixture/calls f)) :argv)) "aarch64-darwin")))

(t/test "home/empty system override uses native system" (fn [f]
  (put (f :env) "NIX_SYSTEM" "")
  (t/success (fixture/run f "ci-home"))
  (t/equal (length (fixture/calls f)) 3)))

(t/test "home/quoted names and literal build arguments" (fn [f]
  (def names ["default" "name.with.dots" "with spaces" "quote\"and\\slash" "line\nbreak"])
  (put (f :env) "JAROS_TEST_NAMES" (string/format "%j" names))
  (def argument "value with spaces; $(touch sentinel)")
  (t/success (fixture/run f "ci-home" "--option" "example" argument))
  (def argv ((last (fixture/calls f)) :argv))
  (t/equal (tuple ;(slice argv 5 8)) ["--option" "example" argument])
  (t/equal (tuple ;(slice argv 8)) (tuple ;(map
    |(string ".#legacyPackages.x86_64-linux.homeConfigurations." (string/format "%q" $) ".activationPackage") names)))
  (t/equal (os/stat (string (f :root) "/sentinel") :mode) nil)))

(t/test "home/no profiles fails before build" (fn [f]
  (put (f :env) "JAROS_TEST_NAMES" "[]")
  (def result (fixture/run f "ci-home"))
  (t/equal (result :status) 1)
  (t/contains (result :err) "No Home Manager configurations")
  (t/equal (length (fixture/calls f)) 2)))

(t/test "home/evaluation errors stop immediately" (fn [f]
  (each [stage count] [["native" 1] ["names" 2]]
    (fixture/clear f)
    (put (f :env) "JAROS_TEST_STAGE" stage)
    (t/equal ((fixture/run f "ci-home") :status) 23)
    (t/equal (length (fixture/calls f)) count))))

(t/test "home/build errors propagate" (fn [f]
  (put (f :env) "JAROS_TEST_STAGE" "build")
  (t/equal ((fixture/run f "ci-home") :status) 23)))

(t/test "home/large discovery output drains without deadlock" (fn [f]
  (def names @[])
  (for i 0 3000 (array/push names (string/format "profile-%04d-with-a-long-enough-name" i)))
  (put (f :env) "JAROS_TEST_NAMES" (string/format "%j" names))
  (t/success (fixture/run f "ci-home"))
  (t/equal (- (length ((last (fixture/calls f)) :argv)) 5) 3000)))

(t/test "home/dry run previews discovery without executing" (fn [f]
  (def result (fixture/run f "--dry-run" "ci-home" "--keep-going"))
  (t/success result)
  (each fragment ["<native-system>" "<discovered Home Manager activation packages>" "--keep-going"]
    (t/contains (result :out) fragment))
  (t/equal (fixture/calls f) @[])))
