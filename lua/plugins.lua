-- Load plugin modules in order.
--
-- Each module under `lua/kickstart/plugins/` installs one plugin (or one group of
-- related plugins) with `vim.pack.add` and configures it. The order is the order
-- the plugins are set up in: the colorscheme before anything that reads highlight
-- groups, mini.icons before Telescope and mini.files that use them.

require 'kickstart.plugins.guess-indent'
require 'kickstart.plugins.gitsigns'
require 'kickstart.plugins.which-key'
require 'kickstart.plugins.tokyonight'
require 'kickstart.plugins.todo-comments'
require 'kickstart.plugins.mini'
require 'kickstart.plugins.telescope'
require 'kickstart.plugins.lspconfig'
require 'kickstart.plugins.conform'
require 'kickstart.plugins.blink-cmp'
require 'kickstart.plugins.treesitter'

-- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
--
--  Here are some example plugins that I've included in the Kickstart repository.
--  Uncomment any of the lines below to enable them (you will need to restart nvim).
--
-- require 'kickstart.plugins.debug'
-- require 'kickstart.plugins.indent_line'
-- require 'kickstart.plugins.lint'
-- require 'kickstart.plugins.autopairs' -- mini.pairs does this already, see `kickstart.plugins.mini`
-- require 'kickstart.plugins.neo-tree' -- mini.files does this already, see `kickstart.plugins.mini`

-- NOTE: You can add your own plugins, configuration, etc. in `lua/custom/plugins/*.lua`.
--
-- `custom.plugins` automatically loads every file from that directory, but their
-- order is unspecified. If plugins depend on each other, keep them in the same
-- file and put their `vim.pack.add()` and `setup()` calls in the required order.
--
-- If separate modules need a specific order, require them explicitly instead:
-- require 'custom.plugins.colorscheme'
-- require 'custom.plugins.ui'
require 'custom.plugins'

-- vim: ts=2 sts=2 sw=2 et
