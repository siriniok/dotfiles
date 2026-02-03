{ lib, pkgs, ... }:
let
  # Sidekick's default package pulls in Copilot, which this CLI-only setup skips.
  sidekick = pkgs.vimPlugins.sidekick-nvim.overrideAttrs { runtimeDeps = [ ]; };
in
{
  home.packages = [ pkgs.codex ];

  programs.lazyvim.plugins.codex = ''
    return {
      "folke/sidekick.nvim",
      dir = "${sidekick}",
      dev = false,
      pin = true,
      cmd = { "Codex", "Sidekick" },
      opts = {
        nes = { enabled = false },
        copilot = { status = { enabled = false } },
        cli = {
          -- Use a Neovim terminal; sessions don't require tmux or Zellij.
          mux = { enabled = false },
          tools = { codex = { cmd = { "${lib.getExe pkgs.codex}" } } },
        },
      },
      keys = {
        {
          "<leader>ac",
          function() require("sidekick.cli").toggle({ name = "codex", focus = true }) end,
          desc = "Codex: toggle terminal",
        },
        {
          "<leader>af",
          function() require("sidekick.cli").send({ name = "codex", msg = "{file}", submit = false }) end,
          desc = "Codex: send file",
        },
        {
          "<leader>av",
          function() require("sidekick.cli").send({ name = "codex", msg = "{selection}", submit = false }) end,
          mode = "x",
          desc = "Codex: send selection",
        },
        {
          "<c-.>",
          function() require("sidekick.cli").focus({ name = "codex" }) end,
          mode = { "n", "i", "t", "x" },
          desc = "Codex: focus terminal",
        },
      },
      config = function(_, opts)
        require("sidekick").setup(opts)
        vim.api.nvim_create_user_command("Codex", function()
          require("sidekick.cli").toggle({ name = "codex", focus = true })
        end, { desc = "Toggle Codex terminal" })
      end,
    }
  '';
}
