#!/usr/bin/env janet
# Files selected from an untrusted checkout must never become editor commands.
(import ./support :as t)
(var source nil)

(defn setup [f]
  (def mocks (string (f :directory) "/mocks"))
  (os/mkdir mocks)
  (each name ["rg" "fzf" "nvim"]
    (def path (string mocks "/" name))
    (spit path (string "#!" t/interpreter "\n"
      "(defn main [_ & args]\n"
      "  (spit (string (os/getenv \"RFV_LOG\") \"/" name "\") (string/format \"%j\" args))\n"
      (case name
        "rg" "  (print (os/getenv \"RFV_SELECTION\")))\n"
        "fzf" "  (prin (file/read stdin :all)))\n"
        "nvim" "  nil)\n")))
    (os/chmod path 8r755))
  (put (f :env) "PATH" (string mocks ":" (os/getenv "PATH")))
  (put (f :env) "RFV_LOG" (f :directory)))

(defn run [f selection & args]
  (put (f :env) "RFV_SELECTION" selection)
  (t/launch f ["bash" source ;args]))

(t/test "rfv/search text and selected filenames cannot become options" (fn [f]
  (t/success (run f "+source untrusted.vim:12:match" "--pre=untrusted"))
  (def args (parse (slurp (string (f :directory) "/rg"))))
  (t/equal (slice args (- (length args) 2)) ["--" "--pre=untrusted"])
  (t/equal (parse (slurp (string (f :directory) "/nvim")))
    ["+12" "--" "+source untrusted.vim"])))

(t/test "rfv/ambiguous line fields and cancellation never launch an editor" (fn [f]
  (each selection ["file:source untrusted.vim:4:match" "file:1|quit:match" ""]
    (assert (not= 0 ((run f selection) :status))))
  (t/equal (os/stat (string (f :directory) "/nvim") :mode) nil)))

(defn main [_ & args]
  (set source (os/realpath (or (get args 0) "bin/rfv")))
  (t/run-tests (or (get args 1) "janet") setup))
