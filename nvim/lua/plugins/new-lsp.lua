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
                'pyright',
                'vimls',
                'cssls',
                'docker-language-server',
            },
        },
        dependencies = {
            'neovim/nvim-lspconfig',
        },
    },
    {
        'neovim/nvim-lspconfig',
        config = function()
            local lspconfig = require 'lspconfig'

            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            lspconfig.lua_ls.setup {
                capabilities = capabilities,
            }

            lspconfig.ts_ls.setup {
                capabilities = capabilities,
                on_attach = function(_client, buffer)
                    local function goto_source_definition()
                        local position_params = vim.lsp.util.make_position_params()
                        vim.lsp.buf.execute_command {
                            command = '_typescript.goToSourceDefinition',
                            arguments = { vim.api.nvim_buf_get_name(0), position_params.position },
                        }
                    end
                    local opts = { buffer = buffer }
                    vim.keymap.set('n', 'gs', goto_source_definition, opts)
                end,
                handlers = {
                    ['workspace/executeCommand'] = function(_err, result, ctx, _config)
                        if ctx.params.command ~= '_typescript.goToSourceDefinition' then
                            return
                        end
                        if result == nil or #result == 0 then
                            return
                        end
                        vim.lsp.util.jump_to_location(result[1], 'utf-8')
                    end,
                },
            }

            vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Code [K]over Documentation' })

            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Code [G]oto [D]efinition' })

            vim.keymap.set({ 'n', 'v' }, '<A-Enter>', vim.lsp.buf.code_action, { desc = '[A-Enter] Code Actions' })

            vim.keymap.set(
                'n',
                'gr',
                require('telescope.builtin').lsp_references,
                { desc = 'Code [G]oto [R]eferences' }
            )

            vim.keymap.set(
                'n',
                'gi',
                require('telescope.builtin').lsp_implementations,
                { desc = 'Code [G]oto [I]mplementations' }
            )

            vim.keymap.set('n', 'rn', vim.lsp.buf.rename, { desc = 'Code [R]e[N]ame' })
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Code [G]oto [D]eclaration' })
        end,
    },
    { 'mfussenegger/nvim-jdtls', dependencies = 'hrsh7th/cmp-nvim-lsp' },
}
