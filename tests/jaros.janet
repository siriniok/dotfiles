#!/usr/bin/env janet
# Test modules mirror bin/jaros.d; mocks prevent real builds or activation.
(import ./jaros.d/commands)
(import ./jaros.d/cli)
(import ./jaros.d/home)
(import ./jaros.d/process)
(import ./jaros.d/packages)
(import ./jaros.d/vscode)
(import ./support :as t)
(import ./jaros.d/support :as fixture)

(defn main [_ & args]
  (t/run-tests (or (get args 0) "janet") fixture/setup))
