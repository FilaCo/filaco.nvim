local function gh(repo) return 'https://github.com/' .. repo end

-- [[ Colorscheme ]]
-- The scheme itself is `colors/filaco.lua` (mini.hues with low saturation). It needs
-- mini.nvim, so it is added here, before the plugins that read highlight groups.
-- `kickstart.plugins.mini` adds it again later; a second `vim.pack.add` of an already
-- added plugin does nothing. `:help vim.pack.add()`
--
-- To try the installed colorschemes with a live preview, use `:Pick colorschemes`.
vim.pack.add { gh 'nvim-mini/mini.nvim' }
vim.cmd.colorscheme 'filaco'

-- vim: ts=2 sts=2 sw=2 et
