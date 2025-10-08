return {
        "hrsh7th/nvim-cmp",
        dependencies = {
            'L3MON4D3/LuaSnip',         -- Snippet engine
            'saadparwaiz1/cmp_luasnip', -- Snippet engine adapter
            'hrsh7th/cmp-nvim-lsp',     -- Source for LSP completion
        },
        config = function()
            require'cmp'.setup({
                snippet = {
                    expand = function(args)
                        require'luasnip'.lsp_expand(args.body)
                    end
                },
                mapping = {
                    ["<C-p>"] = require('cmp').mapping.select_prev_item(),
                    ["<C-n>"] = require('cmp').mapping.select_next_item(),
                    ["<C-d>"] = require('cmp').mapping.scroll_docs(-4),
                    ["<C-u>"] = require('cmp').mapping.scroll_docs(4),

                    ["<C-w>"] = require('cmp').mapping.complete(),
                    ["<C-e>"] = require('cmp').mapping.abort(),

                    ["<Tab>"] = require('cmp').mapping.confirm()
                },
                sources = {
                    { name = 'nvim_lsp' },
                },
            })
        end

        -- config = function()
        --     local cmp = require("cmp")
        --     local luasnip = require("luasnip")
        --
        --     require("luasnip.loaders.from_vscode").lazy_load()
        --
        --     cmp.setup({
        --         completion = {
        --             competeopt = "menu,menuone,preview,noselect"
        --         },
        --         snippet = {
        --             expand = function(args)
        --                 luasnip.lsp_expand(args.body)
        --             end
        --         },
        --         mapping = cmp.mapping.preset.insert({
        --             ["<C-p>"] = cmp.mapping.select_prev_item(),
        --             ["<C-n>"] = cmp.mapping.select_next_item(),
        --             ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        --             ["<C-u>"] = cmp.mapping.scroll_docs(4),
        --
        --             ["<C-a>"] = cmp.mapping.complete(),
        --
        --             ["<C-e>"] = cmp.mapping.abort(),
        --
        --             ["<Tab>"] = cmp.mapping.confirm()
        --         }),
        --
        --         sources = cmp.config.sources({
        --             { name = 'nvim_lsp' },
        --             -- { name = 'luasnip' },
        --             -- { name = 'buffer' },
        --             -- { name = 'path' }
        --         })
        --     })
        -- end
}
