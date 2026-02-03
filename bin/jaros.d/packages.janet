# Report declared package roots, not their transitive store closures.
(import ./process :as process)

(def tsv-expression
  `rows: let clean = s: builtins.replaceStrings [ "\t" "\n" "\r" ] [ " " " " " " ] s;
   in builtins.concatStringsSep "\n" (map (r: builtins.concatStringsSep "\t"
     (map clean [ r.group r.name r.license r.author r.scope ])) rows)`)

(defn parse-rows [text system]
  (def rows @[])
  (unless (= text "")
    (each line (string/split "\n" text)
      (def fields (string/split "\t" line))
      (unless (and (= 5 (length fields)) (some |(= $ (fields 0)) ["free" "unfree" "unknown"]))
        (error "Invalid package inventory from Nix"))
      (array/push rows {:group (fields 0) :name (fields 1) :license (fields 2)
                        :author (fields 3) :scope (fields 4) :system system})))
  rows)

(defn combine [rows]
  (def grouped @{})
  (each row rows
    (def key [(row :group) (row :name) (row :license) (row :author) (row :system)])
    (if-let [previous (grouped key)]
      (put (previous :scopes) (row :scope) true)
      (put grouped key (merge row {:scopes @{(row :scope) true}}))))
  (sort (values grouped)
    (fn [a b]
      (< (string (a :name) "\t" (a :system) "\t" (a :license) "\t" (a :author))
         (string (b :name) "\t" (b :system) "\t" (b :license) "\t" (b :author))))))

(defn cell [text]
  (if (= text "") "-"
    (string/from-bytes ;(map |(if (or (< $ 32) (= $ 127)) 32 $) (string/bytes text)))))

(defn wrap-cell [text width]
  (def lines @[])
  (var line "")
  (each word (string/split " " text)
    (if (and (not= line "") (> (+ (length line) 1 (length word)) width))
      (do (array/push lines line) (set line word))
      (set line (if (= line "") word (string line " " word)))))
  (array/push lines line)
  lines)

(defn table [rows all-platforms]
  (def headers (if all-platforms ["PLATFORM" "PACKAGE" "LICENSE" "AUTHOR / TEAM" "CONFIGURATION"]
                                ["PACKAGE" "LICENSE" "AUTHOR / TEAM" "CONFIGURATION"]))
  (def lines (map (fn [r]
    (def fields @[(r :name) (r :license) (r :author)
                  (string/join (sort (keys (r :scopes))) ", ")])
    (map cell (if all-platforms [(r :system) ;fields] fields))) rows))
  (def limits (if all-platforms [20 48 40 48 60] [48 40 48 60]))
  (def wrapped @[])
  (def widths (map length headers))
  (each line [headers ;lines]
    (def cells @[])
    (for i 0 (length headers)
      (def chunks (wrap-cell (line i) (limits i)))
      (array/push cells chunks)
      (each chunk chunks (put widths i (max (widths i) (length chunk)))))
    (array/push wrapped cells))
  (each cells wrapped
    (for n 0 (reduce max 1 (map length cells))
      (def padded @[])
      (for i 0 (length headers)
        (def text (get (cells i) n ""))
        (array/push padded (string text (string/repeat " " (- (widths i) (length text))))))
      (print (string/trimr (string/join padded "  "))))))

(defn report [rows all-platforms]
  (def merged (combine rows))
  (each [group title] [["free" "Free"] ["unfree" "Unfree"] ["unknown" "Unknown license"]]
    (def selected (filter |(= group ($ :group)) merged))
    (printf "\n%s (%d package/platform entries)" title (length selected))
    (if (empty? selected) (print "  (none)") (table selected all-platforms)))
  (print "\nmaint: identifies Nixpkgs maintainers/teams, not upstream authors. Missing metadata is shown as '-'.")
  (print "Evaluated profile/system/dev-shell/exported packages, including defaults; dependencies are not expanded."))

(defn run-report [arguments dry-run root]
  (var all-platforms false)
  (each arg arguments
    (case arg
      "--all-platforms" (if all-platforms (process/fail "Duplicate --all-platforms") (set all-platforms true))
      (process/fail (string "Unknown packages option '" arg "'; use jaros packages [--all-platforms]"))))
  (def local-args
    (if (= (os/stat "config.local.nix" :mode) :file)
      ["--override-input" "local-config" (string "path:" root "/config.local.nix")] []))
  (def eval-prefix ["nix" "eval" "--no-write-lock-file" "--raw" ;local-args])
  (def discovery
    (if all-platforms
      [;eval-prefix ".#legacyPackages" "--apply"
       `systems: builtins.concatStringsSep "\n" (builtins.attrNames systems)`]
      ["nix" "eval" "--raw" "--impure" "--expr" "builtins.currentSystem"]))
  (def override (os/getenv "NIX_SYSTEM"))
  (def systems
    (if (and (not all-platforms) override (not= override "")) [override]
      (if dry-run
        (do (process/execute discovery true) [(if all-platforms "<configured-platform>" "<native-system>")])
        (string/split "\n" (string/trim (process/capture discovery))))))
  (def rows @[])
  (when (or (empty? systems) (= (get systems 0) ""))
    (process/fail "No platforms discovered for package inventory"))
  (each system systems
    (def query [;eval-prefix (string ".#legacyPackages." (string/format "%q" system) ".packageInventory")
                "--apply" tsv-expression])
    (if dry-run (process/execute query true)
      (do
        (eprintf "Reading configured packages for %s..." system)
        (array/concat rows (parse-rows (process/capture query) system)))))
  (unless dry-run (report rows all-platforms)))

(defn list-packages [arguments dry-run root]
  (if (or (deep= arguments ["--help"]) (deep= arguments ["-h"]))
    (print "Usage: jaros packages [--all-platforms]\nLists evaluated package roots by license, without building them.")
    (run-report arguments dry-run root)))
