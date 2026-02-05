return {
    'nickkadutskyi/jb.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
        vim.o.termguicolors = true
        vim.o.background = 'light'
        vim.cmd 'colorscheme jb'
    end,
}
