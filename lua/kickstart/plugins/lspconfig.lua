local function gh(repo) return 'https://github.com/' .. repo end

-- [[ LSP Configuration ]]
-- Brief aside: **What is LSP?**
--
-- LSP is an initialism you've probably heard, but might not understand what it is.
--
-- LSP stands for Language Server Protocol. It's a protocol that helps editors
-- and language tooling communicate in a standardized fashion.
--
-- In general, you have a "server" which is some tool built to understand a particular
-- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
-- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
-- processes that communicate with some "client" - in this case, Neovim!
--
-- LSP provides Neovim with features like:
--  - Go to definition
--  - Find references
--  - Autocompletion
--  - Symbol Search
--  - and more!
--
-- Thus, Language Servers are external tools that must be installed separately from
-- Neovim. This is where `mason` and related plugins come into play.
--
-- If you're wondering about lsp vs treesitter, you can check out the wonderfully
-- and elegantly composed help section, `:help lsp-vs-treesitter`

-- Useful status updates for LSP.
vim.pack.add { gh 'j-hui/fidget.nvim' }
require('fidget').setup {}

--  This function gets run when an LSP attaches to a particular buffer.
--    That is to say, every time a new file is opened that is associated with
--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
--    function will be executed to configure the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    -- NOTE: Remember that Lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    -- Rename the variable under your cursor.
    --  Most Language Servers support renaming across files, etc.
    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

    -- Execute a code action, usually your cursor needs to be on top of an error
    -- or a suggestion from your LSP for this to activate.
    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

    -- WARN: This is not Goto Definition, this is Goto Declaration.
    --  For example, in C this would take you to the header.
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed
    --
    -- When you move your cursor, the highlights will be cleared (the second autocommand).
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    -- The following code creates a keymap to toggle inlay hints in your
    -- code, if the language server you are using supports them
    --
    -- This may be unwanted, since they displace some of your code
    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
    end
  end,
})

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--  See `:help lsp-config` for information about keys and how to configure
---@type table<string, vim.lsp.Config>
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  --
  -- Some languages (like typescript) have entire language plugins that can be useful:
  --    https://github.com/pmizio/typescript-tools.nvim
  --
  -- But for many setups, the LSP (`ts_ls`) will work just fine
  -- ts_ls = {},

  -- Special Lua Config, as recommended by neovim help docs
  lua_ls = {
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
      end

      -- `workspace.library` lists extra directories whose Lua files lua_ls treats as read-only
      -- definitions (types, globals, `require` targets). lua_ls loads *every* `.lua` file under
      -- every library directory before it answers the first request, so this list decides how long
      -- a cold start takes. Pulling in the whole 'runtimepath' (`nvim_get_runtime_file('', true)`)
      -- meant ~17 MB of Lua from every plugin, their test suites included: tens of seconds of wait.
      -- See https://github.com/neovim/nvim-lspconfig/issues/3189 and `:help lsp-config`.
      --
      -- $VIMRUNTIME alone gives all of `vim.*`: the API, `vim.fn`, options and `vim.uv` are typed in
      -- `$VIMRUNTIME/lua/vim/_meta/` and `$VIMRUNTIME/lua/uv/_meta.lua` (see `:help lua-guide`,
      -- `:help vim.uv`). That is why lua_ls's bundled `${3rd}/luv/library` is no longer needed.
      local library = { vim.env.VIMRUNTIME }

      -- Plugins whose API this config calls beyond `setup()`, so their types are worth the load time.
      -- mini.nvim defines the `MiniFiles`/`MiniIcons` globals and the `mini.pick`/`mini.extra`
      -- modules used in `kickstart/plugins/mini.lua` and `pick.lua`; without it lua_ls would warn
      -- "Undefined global `MiniFiles`" and know nothing of the pickers. Add a name here when you start
      -- calling into another plugin. The name is the plugin directory name, as in `:help vim.pack.get()`.
      local typed_plugins = { 'mini.nvim' }
      -- `info = false` skips the git queries `vim.pack.get()` would otherwise run for every plugin.
      for _, plugin in ipairs(vim.pack.get(nil, { info = false })) do
        if vim.tbl_contains(typed_plugins, plugin.spec.name) then table.insert(library, plugin.path) end
      end
      -- A library entry may also be a single file. nvim-lspconfig ships settings types for every
      -- server it knows (~1 MB); this one file is the `lspconfig.settings.lua_ls` type used below.
      vim.list_extend(library, vim.api.nvim_get_runtime_file('lua/lspconfig/types/lsp/lua_ls.lua', false))

      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          version = 'LuaJIT',
          -- Resolve `require('a.b')` the way Neovim does: `lua/a/b.lua` or `lua/a/b/init.lua` inside
          -- the workspace or a library directory (`:help lua-module-load`). That is why the library
          -- entries above are plugin roots, not their `lua/` subdirectories.
          path = { 'lua/?.lua', 'lua/?/init.lua' },
        },
        workspace = {
          checkThirdParty = false,
          library = library,
          -- Directories skipped in the workspace *and* in every library directory (gitignore-style
          -- names). Plugin test suites are large (mini.nvim: 15 MB under `tests/`) and define nothing
          -- this config uses. `.vscode` is lua_ls's own default, kept because this list replaces it.
          ignoreDir = { '.vscode', 'tests', 'test', 'spec' },
        },
      })
    end,
    ---@type lspconfig.settings.lua_ls
    settings = {
      Lua = {
        format = { enable = false }, -- Disable formatting (formatting is done by stylua)
      },
    },
  },
}

vim.pack.add {
  gh 'neovim/nvim-lspconfig',
  gh 'mason-org/mason.nvim',
  gh 'mason-org/mason-lspconfig.nvim',
  gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
}

-- Automatically install LSPs and related tools to stdpath for Neovim
require('mason').setup {}

-- Ensure the servers and tools above are installed
--
-- To check the current status of installed tools and/or manually install
-- other tools, you can run
--    :Mason
--
-- You can press `g?` for help in this menu.
local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  -- You can add other tools here that you want Mason to install.
  -- These are not language servers, so they live outside `servers`.
  'stylua', -- Lua formatter, used by conform.nvim (`kickstart.plugins.conform`)
})

require('mason-tool-installer').setup { ensure_installed = ensure_installed }

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end

-- [[ Servers installed outside Mason ]]
-- `vim.lsp.enable` just turns on a config that nvim-lspconfig ships in its `lsp/` directory
-- (see `:help lsp-config`); the binary has to be on PATH.
--
-- rust-analyzer should match the toolchain, so it comes from rustup, not Mason:
--   rustup component add rust-analyzer
vim.lsp.enable 'rust_analyzer'

-- cjls (Cangjie) is enabled by cangjie.nvim itself, see `lua/custom/plugins/cangjie.lua`.

-- vim: ts=2 sts=2 sw=2 et
