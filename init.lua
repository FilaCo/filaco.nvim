-- filaco.nvim: a personal Neovim 0.12 config, started from kickstart-modular.
-- Plugins are installed by the built-in `vim.pack` (see `:help vim.pack`).
--
-- Where to look when stuck:
--  - `:Tutor` for the editing basics, `:help` for how the built-in help works
--  - `:help lua-guide` for how Neovim uses Lua
--  - `<leader>sh` (space, s, h) to [s]earch the [h]elp with Telescope
--  - `:checkhealth` when something is broken

-- The configuration is split into modules under `lua/`. `require 'options'` loads
-- `lua/options.lua`, `require 'kickstart.plugins.mini'` loads `lua/kickstart/plugins/mini.lua`:
-- a dot in the module name is a directory separator. See `:help lua-require`.
--
-- Order matters: options first (the leader key must be set before any keymap or
-- plugin reads it), then keymaps, then the plugin manager, then the plugins.

-- [[ Setting options ]]
require 'options'

-- [[ Basic Keymaps ]]
require 'keymaps'

-- [[ Set up vim.pack ]]
require 'pack'

-- [[ Configure and install plugins ]]
require 'plugins'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
