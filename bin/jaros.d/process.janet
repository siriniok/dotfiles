# Subprocess execution, output capture, and checkout location.

(defn fail [message]
  (eprint (string "jaros: " message))
  (os/exit 2))

(defn shell-quote [argument]
  (string "'" (string/replace-all "'" "'\\''" argument) "'"))

(defn execute [argv dry-run]
  (printf "$ %s" (string/join (map shell-quote argv) " "))
  (file/flush stdout)
  (unless dry-run
    (def status (os/execute argv :p))
    (unless (= status 0) (os/exit status))))

(defn capture [argv]
  (def process (os/spawn argv :p {:out :pipe}))
  # Drain stdout before waiting so large profile lists cannot fill the pipe.
  (def output (ev/read (process :out) :all))
  (def status (os/proc-wait process))
  (os/proc-close process)
  (unless (= status 0) (os/exit status))
  (string (or output "")))

(defn repository-root [entry]
  (def parts (array ;(string/split "/" entry)))
  (array/pop parts)
  (array/pop parts)
  (string/join parts "/"))
