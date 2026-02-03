# The CLI uses only Janet's standard library; Nix pins the toolchain.
(declare-project
  :name "jaros"
  :description "Commands for managing this dotfiles checkout"
  :dependencies [])

# Run bin/jaros as a script so it can locate its checkout from its source path.
(task "help" []
  (shell (dyn :janet) "bin/jaros" "help"))

# Run the source-aligned Janet suites through their shared runner.
(put-in (getrules) ["test" :recipe] @[])
(task "test" []
  (shell (dyn :janet) "tests/jaros.janet" (dyn :janet))
  (shell (dyn :janet) "tests/test_install.janet" "install.sh" (dyn :janet)))
