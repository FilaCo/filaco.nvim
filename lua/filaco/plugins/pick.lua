vim.pack.add {
    'https://github.com/nvim-mini/mini.nvim',
}

local pick = require 'mini.pick'
pick.setup()

vim.keymap.set('n', '<leader>ff', pick.builtin.files, { desc = '[F]ind [f]iles' })

vim.keymap.set('n', '<leader>sg', pick.builtin.grep_live, { desc = '[S]earch project text with [g]rep' })
