-- [[ Fuzzy Finder (files, grep, help, LSP, ...) ]]
--
-- mini.pick is the picker of mini.nvim, which `kickstart.plugins.mini` has already
-- installed, so nothing new is downloaded. mini.extra adds more pickers on top of it
-- (keymaps, diagnostics, LSP, old files, ...).
--  See `:help mini.pick` and `:help MiniExtra.pickers`
--
-- Every picker is also a command: `:Pick files`, `:Pick grep_live`, `:Pick colorschemes`
-- (<Tab> completes the names).
--
-- Inside a picker:
--  - type to filter, <C-n>/<C-p> to move, <CR> to choose, <Esc> to close
--  - <C-s>/<C-v>/<C-t> open the choice in a split / vertical split / tab
--  - <Tab> toggles the preview, <S-Tab> shows all the picker's mappings
--  - <C-x> marks items, <M-CR> chooses the marked ones (e.g. into the quickfix list)
--  - <C-Space> "refines": keeps the current matches and starts filtering them again
--
-- Files and grep use `rg` (or `fd`, `git`) when installed. `:help MiniPick-cli-tools`

local pick = require 'mini.pick'
pick.setup() -- also makes `vim.ui.select()` (e.g. LSP code actions) use mini.pick
require('mini.extra').setup()
local extra = require('mini.extra').pickers

vim.keymap.set('n', '<leader>sh', pick.builtin.help, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', extra.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', pick.builtin.files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sg', pick.builtin.grep_live, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', extra.diagnostic, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', pick.builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', extra.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>sc', extra.commands, { desc = '[S]earch [C]ommands' })
vim.keymap.set('n', '<leader><leader>', pick.builtin.buffers, { desc = '[ ] Find existing buffers' })

-- A picker of pickers: every name in `MiniPick.registry` (mini.pick's and mini.extra's).
vim.keymap.set('n', '<leader>ss', function()
  local names = vim.tbl_keys(pick.registry)
  table.sort(names)
  vim.ui.select(names, { prompt = 'Pickers' }, function(name)
    -- `vim.schedule`: start the chosen picker after this one has closed
    if name then vim.schedule(pick.registry[name]) end
  end)
end, { desc = '[S]earch [S]elect Picker' })

-- Grep for the word under the cursor, or for the selected text in visual mode.
-- `method = 'plain'` searches the text literally (`rg --fixed-strings`), not as a regex.
vim.keymap.set({ 'n', 'v' }, '<leader>sw', function()
  local pattern = vim.fn.expand '<cword>'
  if vim.fn.mode() ~= 'n' then
    -- `:help getregion()`: the text between the other end of the selection ('v') and the cursor ('.').
    -- rg searches line by line, so only the first selected line is used.
    pattern = vim.fn.getregion(vim.fn.getpos 'v', vim.fn.getpos '.', { type = vim.fn.mode() })[1]
    vim.api.nvim_feedkeys(vim.keycode '<Esc>', 'nx', false)
  end
  pick.builtin.grep { pattern = pattern, method = 'plain' }
end, { desc = '[S]earch current [W]ord' })

-- Fuzzy search over the lines of the current buffer, or of all open buffers.
vim.keymap.set('n', '<leader>/', function() extra.buf_lines { scope = 'current' } end, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>s/', function() extra.buf_lines { scope = 'all' } end, { desc = '[S]earch [/] in Open Files' })

-- Search the Neovim configuration files. `source.cwd` is the directory the picker lists.
vim.keymap.set('n', '<leader>sn', function() pick.builtin.files(nil, { source = { cwd = vim.fn.stdpath 'config' } }) end, { desc = '[S]earch [N]eovim files' })

-- LSP pickers, set when an LSP attaches to a buffer. With a single result (one definition,
-- say) mini.extra jumps straight to it; with several it opens a picker.
-- These buffer-local maps override Neovim's own `grr`, `gri`, `grt`, `gO`, which fill the
-- quickfix list instead (`:help lsp-defaults`).
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('pick-lsp-attach', { clear = true }),
  callback = function(event)
    local function map(keys, scope, desc)
      vim.keymap.set('n', keys, function() extra.lsp { scope = scope } end, { buffer = event.buf, desc = desc })
    end

    -- Find references for the word under your cursor.
    map('grr', 'references', '[G]oto [R]eferences')
    -- Jump to the implementation of the word under your cursor.
    -- Useful when your language has ways of declaring types without an actual implementation.
    map('gri', 'implementation', '[G]oto [I]mplementation')
    -- Jump to where a variable was declared, or where a function is defined, etc.
    -- To jump back, press <C-o>.
    map('grd', 'definition', '[G]oto [D]efinition')
    -- Jump to the *type* of the word under your cursor, not to where it was defined.
    map('grt', 'type_definition', '[G]oto [T]ype Definition')
    -- Fuzzy find the symbols (variables, functions, types, ...) of the current file.
    map('gO', 'document_symbol', 'Open Document Symbols')
    -- Same over the whole workspace; the prompt is sent to the server as the query.
    map('gW', 'workspace_symbol_live', 'Open Workspace Symbols')
  end,
})

-- vim: ts=2 sts=2 sw=2 et
