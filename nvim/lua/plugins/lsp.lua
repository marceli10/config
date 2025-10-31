return {
    {
        'mason-org/mason.nvim',
        opts = {},
    },
    {
        'mason-org/mason-lspconfig.nvim',
        opts = {
            ensure_installed = {
                'lua_ls',
                'ts_ls',
                'html',
                'postgres_lsp',
                'jdtls',
                'pyright',
                'vimls',
                'cssls',
                'jdtls',
            },
            automatic_enable = {
                exclude = { 'jdtls' },
            },
        },
        dependencies = {
            'neovim/nvim-lspconfig',
            'hrsh7th/cmp-nvim-lsp',
        },
        config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            -- vim.lsp.config('lua_ls', {
            --     capabilities = capabilities,
            -- })
            --
            -- vim.lsp.config('ts_ls', {
            --     capabilities = capabilities,
            --     on_attach = function(client, bufnr)
            --         local function goto_source_definition()
            --             local position_params = vim.lsp.util.make_position_params()
            --             vim.lsp.buf.execute_command {
            --                 command = '_typescript.goToSourceDefinition',
            --                 arguments = { vim.api.nvim_buf_get_name(0), position_params.position },
            --             }
            --         end
            --         local opts = { buffer = bufnr }
            --         vim.keymap.set('n', 'gs', goto_source_definition, opts)
            --     end,
            --     handlers = {
            --         ['workspace/executeCommand'] = function(_err, result, ctx, _config)
            --             if ctx.params.command ~= '_typescript.goToSourceDefinition' then
            --                 return
            --             end
            --             if result == nil or #result == 0 then
            --                 return
            --             end
            --             vim.lsp.util.jump_to_location(result[1], 'utf-8')
            --         end,
            --     },
            -- })
            --
            -- Enable all servers except jdtls, which is handled by nvim-jdtls
            -- local servers = {
            --     'lua_ls',
            --     'ts_ls',
            --     'html',
            --     'postgres_lsp',
            --     'pyright',
            --     'vimls',
            --     'cssls',
            -- }
            -- vim.lsp.enable(servers)
        end,
    },
    { 'mfussenegger/nvim-jdtls', dependencies = 'hrsh7th/cmp-nvim-lsp' },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
        opts = {
            file_types = { 'markdown' },
        },
    },
}
