return {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = 'FzfLua',
    keys = {
        { '<leader>ff', '<cmd>FzfLua files<cr>', desc = 'Find files' },
        { '<leader>f.', '<cmd>FzfLua blines<cr>', desc = 'Find in current file' },
        { '<leader>fw', '<cmd>FzfLua live_grep<cr>', desc = 'Live grep' },
        { '<leader>fv', '<cmd>FzfLua grep_visual<cr>', desc = 'Find selected visual', mode = { 'v', 'x' } },
        { '<leader>fb', '<cmd>FzfLua buffers<cr>', desc = 'Buffers' },
        { '<leader>fh', '<cmd>FzfLua help_tags<cr>', desc = 'Help tags' },
        { '<leader>fo', '<cmd>FzfLua oldfiles<cr>', desc = 'Recent files' },
        { '<leader>fs', '<cmd>FzfLua lsp_document_symbols<cr>', desc = 'Document symbols' },
        { '<leader>fS', '<cmd>FzfLua lsp_workspace_symbols<cr>', desc = 'Workspace symbols' },
        { '<leader>fr', '<cmd>FzfLua lsp_references<cr>', desc = 'LSP references' },
        { '<leader>fd', '<cmd>FzfLua diagnostics_document<cr>', desc = 'Diagnostics' },
        { '<leader>fgc', '<cmd>FzfLua git_commits<cr>', desc = 'Git commits' },
        { '<leader>fgs', '<cmd>FzfLua git_status<cr>', desc = 'Git status' },
        { '<leader>fgb', '<cmd>FzfLua git_branches<cr>', desc = 'Git branches' },
    },
    init = function()
        vim.ui.select = function(...)
            require('lazy').load { plugins = { 'fzf-lua' } }
            require('fzf-lua').register_ui_select()
            return vim.ui.select(...)
        end
    end,
    opts = {
        'default',
        winopts = {
            height = 0.85,
            width = 0.85,
        },
    },
}
