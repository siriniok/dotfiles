(import ../../bin/jaros.d/process :as process)
(import ../support :as t)

(t/test "process/shell quoting preserves apostrophes and metacharacters" (fn [_]
  (t/equal (process/shell-quote "a 'b'; $(touch sentinel)") "'a '\\''b'\\''; $(touch sentinel)'")
  (t/equal (process/shell-quote "") "''")))

(t/test "process/checkout path preserves spaces" (fn [_]
  (t/equal (process/repository-root "/tmp/checkout with spaces/bin/jaros") "/tmp/checkout with spaces")))

(t/test "process/capture returns complete output" (fn [f]
  (t/equal (process/capture [(f :interpreter) "-e" "(print \"captured output\")"])
    "captured output\n")))
