{
  programs.lazyvim.config.options = ''
    vim.opt.wrap = false -- Keep code unwrapped; prose buffers opt in below.
    vim.opt.expandtab = true -- Indent with spaces rather than literal tabs.
    vim.opt.shiftwidth = 2 -- Use two spaces for each indentation level.
    vim.opt.tabstop = 2 -- Display literal tabs as two spaces.
    vim.opt.smarttab = true -- Use shiftwidth when inserting indentation.
    vim.opt.autoindent = true -- Carry indentation onto the next line.
    vim.opt.smartindent = true -- Add context-aware indentation where supported.
    vim.opt.wildmenu = true -- Enable command-line completion menus.
    vim.opt.backspace = { "indent", "eol", "start" } -- Delete across indentation and line boundaries.

    -- Neovim and Lua configuration already use UTF-8.
    vim.opt.hidden = true -- Keep modified buffers when switching files.
    vim.opt.history = 1000 -- Remember command-line and search history.
    -- Exclude these paths from filename completion; pickers have their own filters.
    vim.opt.wildignore:append({ "*/tmp/*", "*/node_modules/*", "*.so", "*.swp", "*.zip" })

    vim.opt.tabpagemax = 50 -- Allow up to 50 tabs when opening files with -p.
    vim.opt.sessionoptions:remove({ "blank", "options" }) -- Keep sessions focused on files/layout.
    vim.opt.signcolumn = "number" -- Display signs in the line-number column.
    vim.opt.ruler = true -- Show the cursor position.
    vim.opt.showcmd = true -- Show partially typed commands.
    vim.opt.cmdheight = 2 -- Reserve two lines for the command area.
    vim.opt.laststatus = 2 -- Give each window its own status line.
    vim.opt.mouse = "a" -- Enable the mouse in all modes.

    vim.cmd("syntax enable")
    vim.opt.background = "light" -- Use the theme's light palette.
    vim.opt.updatetime = 250 -- Update idle events and swap files more often.
    vim.opt.scrolloff = 5 -- Keep five lines visible above and below the cursor.
    vim.opt.showmatch = true -- Briefly highlight a matching bracket when typing.
    vim.opt.cursorline = true -- Highlight the current line.
    vim.opt.colorcolumn = "100" -- Mark the preferred line-length boundary.

    -- Make whitespace and horizontally clipped or wrapped lines visible.
    vim.opt.list = true
    vim.opt.listchars = {
      tab = "▸·",
      space = "·",
      nbsp = "·",
      extends = ">",
      precedes = "<",
    }
    vim.opt.showbreak = "↳·"

    -- Search without case sensitivity unless the pattern contains uppercase.
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.opt.incsearch = true -- Show matches while typing.
    vim.opt.hlsearch = true -- Keep matches highlighted after searching.

    -- Use the visual-bell setting instead of audible beeps.
    vim.opt.visualbell = true
    vim.opt.errorbells = false

    -- Keep writable news/UI state separate from the old runtime extras list.
    -- Language/plugin selection is declared below through Nix.
    require("lazyvim.config").json.path = vim.fn.stdpath("state") .. "/lazyvim-nix.json"
    vim.g.lazyvim_ts_lsp = "vtsls"
    vim.g.lazyvim_ruby_lsp = "ruby_lsp"
    vim.g.lazyvim_ruby_formatter = "rubocop"
    -- Prettier formats web files; ESLint supplies diagnostics and code actions.
    vim.g.lazyvim_eslint_auto_format = false
  '';

}
