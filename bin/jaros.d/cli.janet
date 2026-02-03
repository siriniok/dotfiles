# Parse arguments and dispatch commands in the current checkout.
(import ./commands :as commands)
(import ./home :as home)
(import ./process :as process)
(import ./packages :as packages)

(defn configure-docker []
  (def host (os/getenv "DOCKER_HOST"))
  (unless (and host (not= host ""))
    (def runtime (os/getenv "XDG_RUNTIME_DIR"))
    (unless (and runtime (not= runtime ""))
      (process/fail "Set DOCKER_HOST or XDG_RUNTIME_DIR to select a Docker socket"))
    (os/setenv "DOCKER_HOST" (string "unix://" runtime "/docker.sock"))))

(defn run [entry arguments]
  (def dry-run (= (get arguments 0) "--dry-run"))
  (def args (if dry-run (slice arguments 1) arguments))
  (def command (get args 0))
  (if (or (nil? command) (= command "help") (= command "--help") (= command "-h"))
    (commands/help)
    (do
      (def root (process/repository-root entry))
      (def extra (slice args 1))
      (when (and (or (= command "run") (= command "clean") (= command "ci-check")) (> (length extra) 0))
        (process/fail (string command " does not accept extra arguments")))
      (def plan (commands/command-plan command extra root (os/which) (os/stat "/etc/NIXOS" :mode)))
      (unless plan (process/fail (string "Unknown command '" command "'; run jaros help")))
      (os/cd root)
      (when (and (= command "run") (not dry-run) (not= (os/stat "config.local.nix" :mode) :file))
        (process/fail "Create config.local.nix with me.hostname, me.email, and me.sshKey before activation"))
      (when (and (= command "ci-local") (not dry-run)) (configure-docker))
      (cond
        (= plan :packages) (packages/list-packages extra dry-run root)
        (= plan :home)
        (home/build extra dry-run)
        (each argv plan (process/execute argv dry-run))))))
