vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', {
    desc = 'Clear search highlighting',
})

vim.keymap.set(
    'n',
    '<leader>?',
    function() require('which-key').show { global = false } end,
    { desc = 'Show buffer keymaps' }
)

vim.keymap.set('n', '<space>tt', function() Snacks.terminal.toggle() end, { desc = 'Toggle terminal' })

-- Files
vim.keymap.set('n', '<leader>e', function() Snacks.explorer() end, { desc = 'Toggle explorer' })

vim.keymap.set('n', '<leader>fe', function() Snacks.explorer.reveal() end, { desc = 'Reveal current file' })

vim.keymap.set('n', '<leader><space>', function() Snacks.picker.smart() end, { desc = 'Find files (smart)' })

vim.keymap.set('n', '<leader>ff', function() Snacks.picker.files() end, { desc = 'Find files' })

vim.keymap.set('n', '<leader>fb', function() Snacks.picker.buffers() end, { desc = 'Switch buffer' })

vim.keymap.set('n', '<leader>fr', function() Snacks.picker.recent() end, { desc = 'Find recent files' })

vim.keymap.set(
    'n',
    '<leader>fc',
    function() Snacks.picker.files { cwd = vim.fn.stdpath 'config' } end,
    { desc = 'Find config files' }
)

-- Search
vim.keymap.set('n', '<leader>/', function() Snacks.picker.grep() end, { desc = 'Search project text' })

vim.keymap.set('n', '<leader>sg', function() Snacks.picker.grep() end, { desc = 'Search project text' })

vim.keymap.set('n', '<leader>sw', function() Snacks.picker.grep_word() end, { desc = 'Search word under cursor' })

vim.keymap.set('n', '<leader>sr', function() Snacks.picker.resume() end, { desc = 'Resume last picker' })

vim.keymap.set('n', '<leader>sd', function() Snacks.picker.diagnostics() end, { desc = 'Search workspace diagnostics' })

vim.keymap.set('n', '<leader>ss', function() Snacks.picker.lsp_symbols() end, { desc = 'Search document symbols' })

vim.keymap.set('n', '<leader>sk', function() Snacks.picker.keymaps() end, { desc = 'Search keymaps' })

-- Buffers
vim.keymap.set('n', '<leader>,', function() Snacks.picker.buffers() end, { desc = 'Switch buffer' })

vim.keymap.set('n', '<leader>bd', function() Snacks.bufdelete() end, { desc = 'Delete buffer' })

vim.keymap.set('n', '<leader>bo', function() Snacks.bufdelete.other() end, { desc = 'Delete other buffers' })

vim.keymap.set('n', '<leader>bp', '<Cmd>BufferPrevious<CR>', { desc = 'Previous buffer' })

vim.keymap.set('n', '<leader>bn', '<Cmd>BufferNext<CR>', { desc = 'Next buffer' })

vim.keymap.set('n', '<leader>bb', '<Cmd>BufferPick<CR>', { desc = 'Pick buffer by letter' })

vim.keymap.set('n', '<leader>bt', '<Cmd>BufferPin<CR>', { desc = 'Toggle buffer pin' })

-- Code
vim.keymap.set(
    'n',
    '<leader>cf',
    function()
        require('conform').format {
            async = true,
            lsp_format = 'fallback',
        }
    end,
    { desc = 'Format buffer' }
)

-- LSP
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('filaco-lsp-keymaps', { clear = true }),
    callback = function(event)
        local buf = event.buf

        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {
            buffer = buf,
            desc = 'Goto definition',
        })

        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, {
            buffer = buf,
            desc = 'Goto declaration',
        })

        vim.keymap.set('n', 'gr', function() Snacks.picker.lsp_references() end, {
            buffer = buf,
            desc = 'Find references',
        })

        vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, {
            buffer = buf,
            desc = 'Goto implementation',
        })

        vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, {
            buffer = buf,
            desc = 'Goto type definition',
        })

        vim.keymap.set('n', 'K', vim.lsp.buf.hover, {
            buffer = buf,
            desc = 'Hover documentation',
        })

        vim.keymap.set('n', 'gK', vim.lsp.buf.signature_help, {
            buffer = buf,
            desc = 'Signature help',
        })

        vim.keymap.set({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, {
            buffer = buf,
            desc = 'Code action',
        })

        vim.keymap.set('n', '<leader>cr', function() return ':IncRename ' .. vim.fn.expand '<cword>' end, {
            buffer = buf,
            expr = true,
            desc = 'Rename symbol',
        })
    end,
})

-- Quit and session
vim.keymap.set('n', '<leader>qs', function() require('persistence').load() end, { desc = 'Restore project session' })

vim.keymap.set('n', '<leader>qS', function() require('persistence').select() end, { desc = 'Select session' })

vim.keymap.set(
    'n',
    '<leader>ql',
    function() require('persistence').load { last = true } end,
    { desc = 'Restore last session' }
)

vim.keymap.set('n', '<leader>qd', function() require('persistence').stop() end, { desc = 'Stop session saving' })

-- Diagnostics and lists
vim.keymap.set('n', '<leader>xx', '<Cmd>Trouble diagnostics toggle<CR>', { desc = 'Workspace diagnostics' })

vim.keymap.set('n', '<leader>xX', '<Cmd>Trouble diagnostics toggle filter.buf=0<CR>', { desc = 'Buffer diagnostics' })

vim.keymap.set('n', '<leader>xq', '<Cmd>Trouble qflist toggle<CR>', { desc = 'Quickfix list' })

vim.keymap.set('n', '<leader>xl', '<Cmd>Trouble loclist toggle<CR>', { desc = 'Location list' })

vim.keymap.set('n', '<leader>cs', '<Cmd>Trouble symbols toggle focus=false<CR>', { desc = 'Document symbols' })
