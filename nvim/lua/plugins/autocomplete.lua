return {
    'hrsh7th/nvim-cmp',
    dependencies = {
        'L3MON4D3/LuaSnip',         -- Snippet engine
        'saadparwaiz1/cmp_luasnip', -- Snippet engine adapter
        'hrsh7th/cmp-nvim-lsp',     -- Source for LSP completion
    },
    config = function()
        require('cmp').setup {
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
            mapping = {
                ['<C-p>'] = require('cmp').mapping.select_prev_item { select = false },
                ['<C-n>'] = require('cmp').mapping.select_next_item { select = false },
                ['<C-d>'] = require('cmp').mapping.scroll_docs(-4),
                ['<C-u>'] = require('cmp').mapping.scroll_docs(4),

                ['<C-Space>'] = require('cmp').mapping.complete(),
                ['<C-e>'] = require('cmp').mapping.abort(),

                ['<Tab>'] = require('cmp').mapping.confirm { select = false },
            },
            sources = {
                { name = 'nvim_lsp' },
            },
            preselect = 'item',
            completion = {
                completeopt = 'menu,menuone,noinsert',
            },
        }
    end,
}
