{
  programs.lazyvim.config.keymaps = ''
    vim.keymap.set("i", "ii", "<Esc>", { desc = "Leave insert mode" })
    vim.keymap.set("c", "ii", "<C-C>", { desc = "Cancel command line" })
    -- Keep deletions in their own undo block in insert mode.
    vim.keymap.set("i", "<C-U>", "<C-G>u<C-U>", { desc = "Delete to line start with undo boundary" })
    vim.keymap.set("i", "<C-W>", "<C-G>u<C-W>", { desc = "Delete word with undo boundary" })
    -- Add a line and immediately return to normal mode.
    vim.keymap.set("n", "oo", "o<Esc>", { desc = "Insert blank line below" })
    vim.keymap.set("n", "OO", "O<Esc>", { desc = "Insert blank line above" })
  '';

  programs.lazyvim.config.autocmds = ''
    -- Terminal jobs reuse their parent Neovim instead of nesting editors.
    vim.env.EDITOR = "nvim-editor"
    vim.env.VISUAL = "nvim-editor"
    vim.api.nvim_create_autocmd("QuitPre", {
      group = vim.api.nvim_create_augroup("dotfiles_external_editor", { clear = true }),
      callback = function(event)
        local clients = vim.b[event.buf].nvr
        if type(clients) == "table" and #clients > 0 and not vim.bo[event.buf].modified then
          vim.bo[event.buf].bufhidden = "wipe"
        end
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("dotfiles_prose", { clear = true }),
      pattern = { "markdown", "text", "gitcommit" },
      callback = function()
        vim.opt_local.wrap = true -- Wrap prose without inserting line breaks.
        vim.opt_local.linebreak = true -- Wrap at word boundaries.
      end,
    })
  '';

}
