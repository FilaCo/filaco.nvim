-- needs to be registered before vim.pack.add
vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
        local name = ev.data.spec.name
        local kind = ev.data.kind

        if name == 'nvim-treesitter' and (kind == 'install' or kind == 'update') then
            if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
            vim.cmd 'TSUpdate'
        end
    end,
})

vim.pack.add {
    'https://github.com/nvim-mini/mini.nvim',
    'https://github.com/folke/snacks.nvim',
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',

    -- LSP
    'https://github.com/neovim/nvim-lspconfig',
    'https://github.com/mason-org/mason.nvim',
    'https://github.com/mason-org/mason-lspconfig.nvim',

    'https://github.com/stevearc/conform.nvim',
    'https://github.com/folke/which-key.nvim',
    'https://github.com/folke/edgy.nvim',
    'https://github.com/folke/noice.nvim',
    'https://github.com/folke/lazydev.nvim',
    'https://github.com/folke/persistence.nvim',
    'https://github.com/folke/trouble.nvim',

    'https://github.com/nvim-lualine/lualine.nvim',
    'https://github.com/nvim-tree/nvim-web-devicons',
    'https://github.com/romgrk/barbar.nvim',
    'https://github.com/lewis6991/gitsigns.nvim',
    'https://github.com/MunifTanjim/nui.nvim',

    -- Completion
    'https://github.com/saghen/blink.cmp',

    'https://github.com/smjonas/inc-rename.nvim',
    'https://github.com/nickkadutskyi/jb.nvim',
}

-- jb.nvim setup
require('jb').setup {
    snacks = {
        explorer = {
            enabled = true,
        },
    },
}
vim.cmd.colorscheme 'jb'

-- mini.nvim setup
local mini_ai = require 'mini.ai'
local ts_object = mini_ai.gen_spec.treesitter
mini_ai.setup {
    custom_textobjects = {
        F = ts_object {
            a = '@function.outer',
            i = '@function.inner',
        },
        C = ts_object {
            a = '@class.outer',
            i = '@class.inner',
        },
    },
}

require('mini.align').setup {}
require('mini.comment').setup {}

local map_multistep = require('mini.keymap').map_multistep

map_multistep('i', '<CR>', { 'minipairs_cr' })
map_multistep('i', '<BS>', { 'minipairs_bs' })

require('mini.move').setup {}
require('mini.operators').setup {
    replace = { prefix = 'cr' },
}
require('mini.pairs').setup {}
require('mini.splitjoin').setup {}
require('mini.surround').setup {}

-- snacks.nvim setup
---@type snacks.Config
require('snacks').setup {
    animate = {},
    bigfile = {},
    bufdelete = {},
    dashboard = {
        sections = {
            { section = 'header' },
            { icon = ' ', title = 'Keymaps', section = 'keys', indent = 2, padding = 1 },
            { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
            { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
        },
    },
    dim = {},
    explorer = {},
    input = {},
    picker = { layout = { preset = 'vscode' } },
    terminal = {},
    words = {},
}

-- nvim-treesitter setup
require('nvim-treesitter').install {
    'asm',
    'bash',
    'c',
    'c_sharp',
    'cmake',
    'cpp',
    'css',
    'csv',
    'diff',
    'dockerfile',
    'doxygen',
    'fish',
    'git_config',
    'git_rebase',
    'gitcommit',
    'gitignore',
    'html',
    'http',
    'ini',
    'javascript',
    'json',
    'just',
    'llvm',
    'lua',
    'luadoc',
    'markdown',
    'markdown_inline',
    'mermaid',
    'meson',
    'nginx',
    'nix',
    'python',
    'qmljs',
    'regex',
    'rust',
    'sql',
    'svelte',
    'toml',
    'tsx',
    'typescript',
    'ungrammar',
    'vim',
    'vimdoc',
    'xml',
    'yaml',
    'zsh',
}
vim.api.nvim_create_autocmd('FileType', {
    callback = function() pcall(vim.treesitter.start) end,
})

-- lazydev setup
require('lazydev').setup {
    integrations = { cmp = false },
    library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    },
}

-- blink.cmp setup
local blink = require 'blink.cmp'
blink.setup {
    keymap = {
        preset = 'enter',
        ['<C-y>'] = { 'select_and_accept' },
    },

    completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
    },

    cmdline = {
        enabled = true,
        keymap = {
            preset = 'cmdline',
            ['<Right>'] = false,
            ['<Left>'] = false,
        },
        completion = {
            list = { selection = { preselect = false } },
            menu = {
                auto_show = function() return vim.fn.getcmdtype() == ':' end,
            },
            ghost_text = { enabled = true },
        },
    },

    sources = {
        default = { 'lazydev', 'lsp', 'path', 'buffer' },
        providers = {
            lazydev = {
                name = 'LazyDev',
                module = 'lazydev.integrations.blink',
                score_offset = 100,
            },
        },
    },

    fuzzy = { implementation = 'prefer_rust' },
}

-- LSP setup
require('mason').setup {}
vim.lsp.config('*', {
    capabilities = blink.get_lsp_capabilities(),
})
require('mason-lspconfig').setup {
    ensure_installed = {
        'asm_lsp',
        'bashls',
        'clangd',
        'cssls',
        'docker_compose_language_service',
        'docker_language_server',
        'fish_lsp',
        'gh_actions_ls',
        'gitlab_ci_ls',
        'html',
        'jsonls',
        'just',
        'lua_ls',
        'markdown_oxide',
        'mesonlsp',
        'neocmake',
        'nginx_language_server',
        'qmlls',
        'ruff',
        'rust_analyzer',
        'stylua',
        'svelte',
        'taplo',
        'tsc',
        'ty',
        'vimls',
        'yamlls',
    },
    automatic_enable = true,
}

-- conform.nvim setup
require('conform').setup {
    formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'ruff_format' },
        sh = { 'shfmt' },
        c = { 'clang-format' },
        cpp = { 'clang-format' },
        toml = { 'taplo' },
        rust = { 'rustfmt' },

        javascript = { 'prettier' },
        javascriptreact = { 'prettier' },
        typescript = { 'prettier' },
        typescriptreact = { 'prettier' },
        html = { 'prettier' },
        css = { 'prettier' },
        json = { 'prettier' },
        jsonc = { 'prettier' },
        yaml = { 'prettier' },
        markdown = { 'prettier' },
    },
    format_on_save = {
        timeout_ms = 1000,
        lsp_format = 'fallback',
    },
}

-- which-key.nvim setup
require('which-key').setup {
    preset = 'modern',
    delay = 300,
    spec = {
        { '<leader>f', group = 'Files' },
        { '<leader>s', group = 'Search' },
        { '<leader>b', group = 'Buffers' },
        { '<leader>c', group = 'Code' },
        { '<leader>q', group = 'Quit / Session' },
        { '<leader>x', group = 'Diagnostics / Lists' },
    },
}

-- edgy.nvim setup
local edgy_opts = {}
for _, pos in ipairs { 'top', 'bottom', 'left', 'right' } do
    edgy_opts[pos] = edgy_opts[pos] or {}
    table.insert(edgy_opts[pos], {
        ft = 'snacks_terminal',
        size = { height = 0.4 },
        title = '%{b:snacks_terminal.id}: %{b:term_title}',
        filter = function(_buf, win)
            return vim.w[win].snacks_win
                and vim.w[win].snacks_win.position == pos
                and vim.w[win].snacks_win.relative == 'editor'
                and not vim.w[win].trouble_preview
        end,
    })
end
require('edgy').setup(edgy_opts)

-- lualine.nvim setup
require('lualine').setup {
    options = {
        theme = 'jb',
        globalstatus = true,
        component_separators = '',
        section_separators = '',
    },
    sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
            { 'nav_bar', padding = { left = 1, right = 0 } },
            {
                'filetype',
                icon_only = true,
                padding = { left = 0, right = 0 },
            },
            {
                'filename',
                path = 0,
                padding = { left = 0, right = 1 },
            },
        },
        lualine_x = {},
        lualine_y = { 'branch', 'searchcount', 'location' },
        lualine_z = {
            {
                'mode',
                fmt = function(mode)
                    local names = {
                        NORMAL = 'NO',
                        INSERT = 'IN',
                        VISUAL = 'VI',
                        ['V-LINE'] = 'VL',
                        ['V-BLOCK'] = 'VB',
                        REPLACE = 'RE',
                        COMMAND = 'CL',
                        TERMINAL = 'TE',
                    }
                    return names[mode] or mode
                end,
            },
        },
    },
}

-- barbar.nvim setup
require('barbar').setup()

-- gitsigns.nvim setup
require('gitsigns').setup()

-- noice.nvim setup
require('noice').setup {
    lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
        },
    },
    presets = {
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = false,
    },
}

-- inc_rename.nvim setup
require('inc_rename').setup()

-- persistence.nvim setup
require('persistence').setup()

-- trouble.nvim setup
require('trouble').setup()

-- nvim-treesitter-textobjects setup
require('nvim-treesitter-textobjects').setup {
    move = {
        set_jumps = true,
    },
}
