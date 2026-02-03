(import ../../bin/jaros.d/packages :as packages)
(import ../support :as t)
(import ./support :as fixture)

(t/test "packages/license groups and author provenance" (fn [f]
  (def result (fixture/run f "packages"))
  (t/success result)
  (each text ["Free (1" "Unfree (1" "Unknown license (1" "LICENSE" "AUTHOR / TEAM"
              "Upstream team" "maint: Nix maintainer" "not upstream authors"]
    (t/contains (result :out) text))
  (def calls (fixture/calls f))
  (t/equal (length calls) 2)
  (assert (some |(= $ "--override-input") ((last calls) :argv)))
  (assert (some |(string/find "packageInventory" $) ((last calls) :argv)))
  (each call calls (t/equal (call :cwd) (f :root)))))

(t/test "packages/all platforms are discovered and reported separately" (fn [f]
  (put (f :env) "NIX_SYSTEM" "ignored")
  (def result (fixture/run f "packages" "--all-platforms"))
  (t/success result)
  (t/equal (length (fixture/calls f)) 3)
  (each text ["PLATFORM" "x86_64-linux" "aarch64-darwin" "Free (2"]
    (t/contains (result :out) text))
  (assert (not (some |(some (fn [arg] (= arg "--impure")) ($ :argv)) (fixture/calls f))))))

(t/test "packages/native override and absent local file" (fn [f]
  (os/rm (string (f :root) "/config.local.nix"))
  (put (f :env) "NIX_SYSTEM" "aarch64-linux")
  (t/success (fixture/run f "packages"))
  (def argv ((first (fixture/calls f)) :argv))
  (t/equal (length (fixture/calls f)) 1)
  (assert (not (some |(= $ "--override-input") argv)))
  (assert (some |(string/find "aarch64-linux" $) argv))))

(t/test "packages/duplicate rows combine scopes without merging platforms or versions" (fn [_]
  (def text "free\tfoo-1\tMIT\tTeam\thome/a\nfree\tfoo-1\tMIT\tTeam\tdev/a\nfree\tfoo-2\tMIT\tTeam\thome/a")
  (def rows (packages/combine [;(packages/parse-rows text "x86_64-linux")
                              ;(packages/parse-rows text "aarch64-darwin")]))
  (t/equal (length rows) 4)
  (each row rows
    (when (= (row :name) "foo-1")
      (t/equal (length (row :scopes)) 2)))))

(t/test "packages/reject invalid options and malformed metadata" (fn [f]
  (each args [["--all-platforms" "--all-platforms"] ["--system"] ["$(touch sentinel)"]]
    (t/equal ((fixture/run f "packages" ;args) :status) 2))
  (t/equal (fixture/calls f) @[])
  (put (f :env) "JAROS_TEST_PACKAGES" "not\ta\tvalid\trow")
  (assert (not= ((fixture/run f "packages") :status) 0))
  (t/equal (os/stat (string (f :root) "/sentinel") :mode) nil)))

(t/test "packages/help and dry runs do not execute Nix" (fn [f]
  (t/success (fixture/run f "packages" "--help"))
  (each args [[] ["--all-platforms"]]
    (def result (fixture/run f "--dry-run" "packages" ;args))
    (t/success result)
    (t/contains (result :out) "packageInventory"))
  (t/equal (fixture/calls f) @[])))

(t/test "packages/discovery and evaluation failures propagate" (fn [f]
  (each [stage args] [["native" []] ["platforms" ["--all-platforms"]] ["packages" []]]
    (put (f :env) "JAROS_TEST_STAGE" stage)
    (t/equal ((fixture/run f "packages" ;args) :status) 23))
  (put (f :env) "JAROS_TEST_STAGE" nil)
  (put (f :env) "JAROS_TEST_PLATFORMS" "")
  (t/equal ((fixture/run f "packages" "--all-platforms") :status) 2)))
