vim.keymap.set(
    'n',
    'K',
    function() vim.cmd.RustLsp { 'hover', 'actions' } end,
    { buffer = true, desc = 'Rust hover actions' }
)

vim.keymap.set(
    'n',
    '<leader>cm',
    function() vim.cmd.RustLsp 'expandMacro' end,
    { buffer = true, desc = 'Rust expand macro' }
)
vim.keymap.set(
    'n',
    '<leader>ca',
    function() vim.cmd.RustLsp 'codeAction' end,
    { buffer = true, desc = 'Rust code actions' }
)
