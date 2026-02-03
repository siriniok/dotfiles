# Small standard-library runner for subprocess regression suites.
(def cases @[])
(var interpreter nil)

(defn test [name callback &opt user-only]
  (array/push cases [name callback user-only]))
(defn equal [actual expected]
  (assert (deep= actual expected) (string/format "expected %j, got %j" expected actual)))
(defn contains [text fragment]
  (assert (string/find fragment text) (string/format "%q not found in %q" fragment text)))
(defn success [result]
  (assert (= 0 (result :status)) (string (result :err) (result :out))))

(defn remove-tree [path]
  (if (= :directory (os/stat path :mode))
    (do (each name (os/dir path) (remove-tree (string path "/" name))) (os/rmdir path))
    (os/rm path)))

(defn fixture []
  (def suffix (string/join (map |(string/format "%02x" $) (os/cryptorand 8)) ""))
  (def temporary (string (or (os/getenv "TMPDIR") "/tmp") "/dotfiles-tests-" suffix))
  (os/mkdir temporary)
  @{:directory (os/realpath temporary) :env (os/environ)})

(defn launch [fixture argv &opt input]
  (def directory (fixture :directory))
  (def out-path (string directory "/stdout"))
  (def err-path (string directory "/stderr"))
  (def in-path (string directory "/stdin"))
  (spit in-path (or input ""))
  (def original (os/cwd))
  (def status
    (defer (os/cd original)
      (os/cd directory)
      (with [in (file/open in-path :r)]
        (with [out (file/open out-path :w)]
          (with [err (file/open err-path :w)]
            (os/execute argv :ep (merge (fixture :env) {:in in :out out :err err})))))))
  {:status status :out (slurp out-path) :err (slurp err-path)})

(defn run-tests [janet setup]
  (set interpreter
    (or (some (fn [directory]
                (def path (if (string/find "/" janet) janet (string directory "/" janet)))
                (when (= :file (os/stat path :mode)) (os/realpath path)))
              (string/split ":" (os/getenv "PATH")))
        (error "Janet interpreter not found")))
  (var failures 0)
  (var skipped 0)
  (each [name callback user-only] cases
    (var skip false)
    (def [ok problem] (protect
      (def state (fixture))
      (defer (remove-tree (state :directory))
        # Newly created directories belong to the effective user running the suite.
        (if (and user-only (= 0 (os/stat (state :directory) :uid)))
          (set skip true)
          (do (setup state) (callback state))))))
    (cond skip (do (++ skipped) (printf "SKIP %s (requires a non-root user)" name))
          ok (printf "PASS %s" name)
          (do (++ failures) (eprintf "FAIL %s: %s" name problem))))
  (printf "%d tests, %d failures, %d skipped" (length cases) failures skipped)
  (when (> failures 0) (os/exit 1)))
