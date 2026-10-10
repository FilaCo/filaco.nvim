# filaco.nvim

Personal Neovim 0.12 config, started from kickstart-modular (vim.pack, no lazy.nvim). Its owner is learning Lua and
Neovim with it: every change is explained (what and why, with `:help` tags) and the setup stays fast and lean.

## Layout

- `init.lua` only requires, in order: `options` → `keymaps` → `pack` → `plugins`. The leader key is set in
  `lua/options.lua` and must stay before anything that maps keys.
- `lua/pack.lua`: `PackChanged` build hooks (telescope-fzf-native, LuaSnip, nvim-treesitter).
- `lua/plugins.lua`: requires `lua/kickstart/plugins/*.lua` one by one, in setup order (colorscheme before plugins
  that read highlights, mini.icons before its users), then `custom.plugins`.
- `lua/kickstart/plugins/<name>.lua`: one plugin (or group) per file: `vim.pack.add { ... }`, then `setup()`.
- `lua/custom/plugins/*.lua`: own additions, loaded by `custom/plugins/init.lua` in unspecified order.
- `nvim-pack-lock.json` is tracked; commit it together with the change that moved a plugin.

## Conventions

- Prefer built-ins and modules of plugins already installed (mini.nvim) over a new plugin.
- Keymaps carry a `desc` (which-key shows it).
- LSP servers go through Mason, except `rust_analyzer` (from rustup) and `cjls` (enabled by cangjie.nvim). Cangjie
  is formatted by cjls through conform's LSP fallback; never configure cjfmt.
- Format with stylua per `.stylua.toml` (160 columns, single quotes, no call parentheses).
- Conventional Commits.

## Checks before calling a change done

- `~/.local/share/nvim/mason/bin/stylua --check .` exits 0.
- `nvim --headless +qa 2>&1` prints nothing. (`vim.v.errmsg` is not a usable signal: mini.files leaves a harmless
  `E216 FileExplorer` in it.)
- Behaviour that only shows interactively (windows, keymaps, highlights) is not verified by the above; say so.
