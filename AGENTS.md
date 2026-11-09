# filaco.nvim

## Project context

This is a personal Neovim 0.12 configuration derived from kickstart-modular. Plugins are managed by the
built-in `vim.pack`. Keep the setup fast, lean, and understandable for an owner learning Lua and Neovim.
Explain what changes and why; add useful `:help` tags to comments when introducing unfamiliar APIs.

This checkout is the live configuration at `~/.config/nvim`: edits take effect on the next Neovim start.
The README and `doc/kickstart.txt` retain upstream Kickstart material; use the actual configuration and
this file for project-specific conventions.

## Layout and load order

- `init.lua` requires `options` → `keymaps` → `pack` → `plugins`, in that order. Set leader keys in
  `lua/options.lua` before any keymaps or plugins read them.
- `lua/options.lua` contains editor options; `lua/keymaps.lua` contains general keymaps and autocommands.
- `lua/pack.lua` defines `PackChanged` build hooks for LuaSnip and nvim-treesitter.
- `lua/plugins.lua` explicitly loads plugin modules in setup order. Load the colorscheme before plugins
  that read highlights, mini.nvim icons before their users, and the picker before hipatterns.
- `lua/kickstart/plugins/<name>.lua` installs one plugin or related group with `vim.pack.add`, then
  configures it. Some example modules are disabled in `lua/plugins.lua`; a file's presence does not mean
  it is enabled.
- `lua/custom/plugins/*.lua` contains personal additions. `lua/custom/plugins/init.lua` loads these in
  unspecified order. Keep dependent plugins together or require them explicitly in the required order.
- `colors/filaco.lua` defines the colorscheme through mini.hues; its loader is
  `lua/kickstart/plugins/colorscheme.lua`.
- `nvim-pack-lock.json` is tracked. Include intentional plugin revision changes with the corresponding
  configuration change; preserve unrelated local lockfile changes.

## Implementation conventions

- Prefer Neovim built-ins and modules of installed plugins (especially mini.nvim) before adding a plugin.
- Follow the existing module structure and keep changes focused on the requested behavior.
- Add a `desc` to new keymaps so which-key can display them; keep plugin-specific keymaps with their plugin.
- Use native `vim.lsp.config` / `vim.lsp.enable`. Install language servers through Mason, except
  `rust_analyzer` (rustup) and `cjls` (enabled by cangjie.nvim).
- Cangjie formatting goes through cjls via conform's LSP fallback; never configure cjfmt.
- Lua formatting belongs to StyLua, not lua_ls. Keep lua_ls's library list narrow; avoid loading the
  entire runtimepath just for type definitions.
- Follow `.stylua.toml`: two spaces, Unix line endings, 160 columns, preferred single quotes, and omitted
  call parentheses where supported. CI uses StyLua 2.5.2 (`.github/workflows/stylua.yml`).
- Write repository documentation and code comments in English, matching the existing files.
- Use Conventional Commits when creating commits.

## Validation

For Lua configuration changes, run from the repository root:

```sh
~/.local/share/nvim/mason/bin/stylua --check .
nvim --headless +qa 2>&1
```

StyLua must exit successfully; Neovim should exit successfully with no output. Do not use `vim.v.errmsg`
as the startup signal: mini.files can leave a harmless `E216 FileExplorer` there.

Plugins normally live in `~/.local/share/nvim/site/pack/core/opt`, and Mason tools in
`~/.local/share/nvim/mason`. Read their local help or source when checking API behavior.

For documentation-only changes, check the diff and referenced paths; a Neovim startup is unnecessary.
Startup and formatting checks do not verify interactive behavior (windows, keymaps, highlights, or LSP
attachment). Report what was checked and which relevant behavior still needs an interactive check.

## Maintaining agent instructions

Keep shared project instructions in this root `AGENTS.md` instead of duplicating rules in agent-specific
files. Keep `.claude/settings.json` for Claude-specific environment settings.
