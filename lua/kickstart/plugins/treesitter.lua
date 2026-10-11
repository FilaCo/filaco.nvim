local function gh(repo) return 'https://github.com/' .. repo end

-- [[ Configure Treesitter ]]
--  Used to highlight, edit, and navigate code
--
--  See `:help nvim-treesitter-intro`

-- NOTE: You can also specify a branch or a specific commit
vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }

-- Ensure basic parsers are installed
-- NOTE: `cangjie` is not listed here on purpose: cangjie.nvim registers that grammar after
-- init.lua has run, and the FileType autocommand below installs it on the first `.cj` buffer.
local parsers = {
  'bash',
  'c',
  'diff',
  'fish',
  'git_config',
  'git_rebase',
  'gitcommit',
  'html',
  'json',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'query',
  'regex',
  'rust',
  'toml',
  'vim',
  'vimdoc',
  'yaml',
}
require('nvim-treesitter').install(parsers)

-- One group for every autocommand in this file, created with `clear = true`: if this file is
-- sourced again, the group is emptied first instead of collecting duplicate autocommands.
-- See `:help nvim_create_augroup()`
local treesitter_augroup = vim.api.nvim_create_augroup('kickstart-treesitter', { clear = true })

-- Folds are *window*-local options, not buffer-local (`:help local-options`): each window keeps its
-- own copy, and Neovim also remembers the values a buffer had in a window, so they come back when
-- that buffer is shown again (in that window, or in a new one).
--
-- `vim.wo[win][0]` addresses the buffer currently shown in window `win` and works like `:setlocal`.
-- Plain `vim.wo.foldmethod = ...` would work like `:set` on the *current* window: it also changes
-- that window's global value, which any other buffer later opened in the window inherits.
-- See `:help vim.wo`, `:help :setlocal`
---@param buf integer
local function treesitter_set_folds(buf)
  -- `win_findbuf()` lists every window (in any tab page) that shows `buf`. See `:help win_findbuf()`
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.wo[win][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo[win][0].foldmethod = 'expr'
  end
end

---@param buf integer
---@param language string
local function treesitter_try_attach(buf, language)
  -- This can run long after the `FileType` event (see the async install below), so the buffer may be
  -- gone by now. See `:help nvim_buf_is_valid()`
  if not vim.api.nvim_buf_is_valid(buf) then return end
  -- Check if a parser exists and load it
  if not vim.treesitter.language.add(language) then return end
  -- Enable syntax highlighting and other treesitter features
  vim.treesitter.start(buf, language)

  -- Enable treesitter based folds (all open by default, see 'foldlevelstart' in `options.lua`)
  -- For more info on folds see `:help folds`
  -- Set them on the windows that show `buf`, which need not include the current window: after an
  -- async install the user may have moved to another window or buffer.
  treesitter_set_folds(buf)
  if #vim.fn.win_findbuf(buf) == 0 then
    -- `buf` is hidden (in no window) right now, so there was no window to set the folds on. Do it the
    -- first time it is displayed again; from then on Neovim carries the values along with the buffer.
    -- `buf = buf` makes the autocommand buffer-local, `once = true` deletes it after it ran.
    -- See `:help BufWinEnter`, `:help autocmd-buflocal`, `:help autocmd-once`
    vim.api.nvim_create_autocmd('BufWinEnter', {
      group = treesitter_augroup,
      buf = buf,
      once = true,
      callback = function() treesitter_set_folds(buf) end,
    })
  end

  -- Check if treesitter indentation is available for this language, and if so enable it
  -- in case there is no indent query, the indentexpr will fallback to the vim's built in one
  local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil

  -- Enable treesitter based indentation
  -- `vim.bo[buf]` targets `buf` itself; plain `vim.bo` would hit whatever buffer is current. See `:help vim.bo`
  if has_indent_query then vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
end

vim.api.nvim_create_autocmd('FileType', {
  group = treesitter_augroup,
  callback = function(args)
    local buf, filetype = args.buf, args.match

    -- The filetype may have changed: drop a pending `BufWinEnter` from an earlier attach to this buffer.
    -- See `:help nvim_clear_autocmds()`
    vim.api.nvim_clear_autocmds { group = treesitter_augroup, buf = buf }

    local language = vim.treesitter.language.get_lang(filetype)
    if not language then return end

    local installed_parsers = require('nvim-treesitter').get_installed 'parsers'
    -- Asked here, not once at startup: plugins loaded after init.lua (cangjie.nvim) can
    -- register extra grammars, and `get_available()` re-reads the parser table every call.
    local available_parsers = require('nvim-treesitter').get_available()

    if vim.tbl_contains(installed_parsers, language) then
      -- Enable the parser if it is already installed
      treesitter_try_attach(buf, language)
    elseif vim.tbl_contains(available_parsers, language) then
      -- If a parser is available in `nvim-treesitter`, auto-install it and enable it after the installation is done
      -- The callback runs later, when the current window and buffer may be different ones;
      -- `treesitter_try_attach` therefore only uses `buf`, never "the current" anything.
      require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
    else
      -- Try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
      treesitter_try_attach(buf, language)
    end
  end,
})

-- vim: ts=2 sts=2 sw=2 et
