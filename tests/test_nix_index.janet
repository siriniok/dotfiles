#!/usr/bin/env janet
# Exercise the configured upstream handler in a real PTY with deterministic matches.
(import ./support :as t)
(var handler nil)

# Zsh's portable PTY module preserves the handler's terminal guard. Polling is
# bounded so a broken handler cannot hang CI; the child records its actual status.
(def terminal-driver ```
zmodload zsh/zpty || exit 1
zmodload zsh/zselect || exit 1
zpty -b handler zsh -f -c '
  source "$1"
  command_not_found_handler missing-example
  rc=$?
  print -r -- "$rc" > "$2"
' test "$1" "$2"
integer deadline=$((SECONDS + 10))
while (( SECONDS < deadline )); do
  while zpty -r handler chunk; do print -rn -- "$chunk"; done
  if ! zpty -t handler; then break; fi
  zselect -t 1
done
while zpty -r handler chunk; do print -rn -- "$chunk"; done
zpty -d handler
[[ -f $2 ]] || { print -r -- 'handler timed out or exited without a status' >&2; exit 1; }
[[ $(<"$2") == 127 ]]
```)

(defn setup [f]
  (def directory (f :directory))
  (def locate (string directory "/nix-locate"))
  (spit locate "#!/bin/sh\nprintf '%s\\n' \"$@\" > \"$LOOKUP_ARGS\"\nprintf '%s' \"$MATCHES\"\n")
  (os/chmod locate 8r755)
  (def pattern ~(sequence "/nix/store/" (some (if-not (set "/ \t\r\n") 1)) "/bin/nix-locate"))
  (def positions (peg/find-all pattern handler))
  (t/equal (length positions) 1)
  (def lookup (first (peg/match ~(<- ,pattern) handler (first positions))))
  (def script (string directory "/handler.zsh"))
  (spit script (string/replace-all lookup locate handler))
  (put f :script script)
  (put (f :env) "HOME" directory)
  (put (f :env) "LOOKUP_ARGS" (string directory "/args"))
  (each key ["NIX_AUTO_INSTALL" "NIX_AUTO_RUN" "MC_SID" "ZDOTDIR"] (put (f :env) key nil)))

(each [label matches] [["single" "hello.out"] ["multiple" "hello.out\nhello2.out"] ["none" ""]]
  (t/test (string "nix-index/" label) (fn [f]
    (put (f :env) "MATCHES" matches)
    (def result (t/launch f ["zsh" "-f" "-c" terminal-driver "test" (f :script)
      (string (f :directory) "/handler-status")]))
    (t/success result)
    (t/equal (string/trim (slurp (string (f :directory) "/handler-status"))) "127")
    (def output (result :out))
    (each legacy ["nix-env" "nix-shell"] (assert (not (string/find legacy output)) output))
    (if (= matches "")
      (t/contains output "missing-example: command not found")
      (each attr (string/split "\n" matches)
        (t/contains output (string "nix profile install nixpkgs#" attr))
        (t/contains output (string "nix shell nixpkgs#" attr " -c missing-example"))))
    (t/equal (string/split "\n" (string/trim (slurp ((f :env) "LOOKUP_ARGS"))))
      @["--minimal" "--no-group" "--type" "x" "--type" "s"
        "--whole-name" "--at-root" "/bin/missing-example"])
    (t/equal (os/stat (string (f :directory) "/.nix-profile") :mode) nil))))

(defn main [_ handler-path &opt janet]
  (set handler (slurp handler-path))
  (assert (not (string/find "manifest.json" handler)) "Profile detection must not control modern hints")
  (t/run-tests (or janet "janet") setup))
