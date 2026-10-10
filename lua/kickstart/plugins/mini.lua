local function gh(repo) return 'https://github.com/' .. repo end

-- [[ mini.nvim ]]
--  A collection of various small independent plugins/modules
vim.pack.add { gh 'nvim-mini/mini.nvim' }

-- If a nerd font is available, load the icons module for pretty icons in various plugins.
if vim.g.have_nerd_font then
  require('mini.icons').setup()
  -- Used for backwards compatibility with plugins that require `nvim-web-devicons` (e.g. telescope.nvim)
  MiniIcons.mock_nvim_web_devicons()
end

-- Better Around/Inside textobjects
--
-- Examples:
--  - va)  - [V]isually select [A]round [)]paren
--  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
--  - ci'  - [C]hange [I]nside [']quote
require('mini.ai').setup {
  -- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
  mappings = {
    around_next = 'aa',
    inside_next = 'ii',
  },
  n_lines = 500,
}

-- Add/delete/replace surroundings (brackets, quotes, etc.)
--
-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
-- - sd'   - [S]urround [D]elete [']quotes
-- - sr)'  - [S]urround [R]eplace [)] [']
require('mini.surround').setup()

-- Auto-insert the closing bracket/quote when typing the opening one.
-- Comes with mini.nvim, so no extra plugin is needed (kickstart's optional
-- `kickstart.plugins.autopairs` would pull in nvim-autopairs for the same job).
require('mini.pairs').setup()

-- File explorer that edits the file system like a buffer:
-- rename a file by editing its line, delete with `dd`, create with `o`, then `=` to apply.
-- Navigation: `l`/`h` go into/out of a directory, `<CR>` opens, `q` closes.
-- See `:help MiniFiles-navigation` and `:help MiniFiles-manipulation`
require('mini.files').setup()
vim.keymap.set('n', '<leader>e', function()
  -- Open at the current file when the buffer has a real file behind it, else at cwd
  local path = vim.api.nvim_buf_get_name(0)
  if vim.uv.fs_stat(path) == nil then path = nil end
  MiniFiles.open(path)
end, { desc = 'File [E]xplorer' })

-- Simple and easy statusline.
--  You could remove this setup call if you don't like it,
--  and try some other statusline plugin
local statusline = require 'mini.statusline'
-- Set `use_icons` to true if you have a Nerd Font
statusline.setup { use_icons = vim.g.have_nerd_font }

-- You can configure sections in the statusline by overriding their
-- default behavior. For example, here we set the section for
-- cursor location to LINE:COLUMN
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function() return '%2l:%-2v' end

-- ... and there is more!
--  Check out: https://github.com/nvim-mini/mini.nvim

-- vim: ts=2 sts=2 sw=2 et
