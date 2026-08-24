return {
    {
        'neovim/nvim-lspconfig',
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            'saghen/blink.cmp',
        },
        config = function()
            vim.lsp.config('*', {
                capabilities = require('blink.cmp').get_lsp_capabilities(),
            })

            vim.diagnostic.config {
                underline = true,
                update_in_insert = false,
                severity_sort = true,
                virtual_text = {
                    spacing = 4,
                    source = 'if_many',
                    prefix = '●',
                },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = '',
                        [vim.diagnostic.severity.WARN] = '',
                        [vim.diagnostic.severity.HINT] = '',
                        [vim.diagnostic.severity.INFO] = '',
                    },
                },
            }

            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(event)
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client == nil then
                        return
                    end

                    local opts = function(desc)
                        return { buffer = event.buf, desc = desc }
                    end

                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts 'Goto Definition')
                    vim.keymap.set('n', 'gr', '<cmd>FzfLua lsp_references<cr>', opts 'References')
                    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts 'Goto Implementation')
                    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts 'Goto Type Definition')
                    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts 'Goto Declaration')
                    vim.keymap.set('n', 'K', function()
                        vim.lsp.buf.hover { border = 'rounded' }
                    end, opts 'Hover')
                    vim.keymap.set('n', 'gK', vim.lsp.buf.signature_help, opts 'Signature Help')
                    vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, opts 'Signature Help')
                    vim.keymap.set({ 'n', 'x' }, '<A-Enter>', vim.lsp.buf.code_action, opts 'Code Action')
                    vim.keymap.set({ 'n', 'x' }, 'gca', vim.lsp.codelens.run, opts 'Run Codelens')
                    vim.keymap.set('n', 'gcr', vim.lsp.codelens.refresh, opts 'Refresh Codelens')
                    vim.keymap.set('n', 'rn', vim.lsp.buf.rename, opts 'Rename')

                    if client:supports_method 'textDocument/inlayHint' then
                        vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
                    end
                end,
            })

            vim.lsp.config('lua_ls', {
                settings = {
                    Lua = {
                        workspace = { checkThirdParty = false },
                        codeLens = { enable = true },
                        completion = { callSnippet = 'Replace' },
                        doc = { privateName = { '^_' } },
                        hint = {
                            enable = true,
                            setType = false,
                            paramType = true,
                            paramName = 'Disable',
                            semicolon = 'Disable',
                            arrayIndex = 'Disable',
                        },
                    },
                },
            })

            vim.lsp.config('zls', {
                settings = {
                    zls = {
                        enable_build_on_save = true,
                        build_on_save_step = 'install',
                    },
                },
            })

            vim.lsp.config('ruff', {
                on_attach = function(client)
                    client.server_capabilities.hoverProvider = false
                end,
            })

            vim.lsp.config('eslint', {
                settings = {
                    workingDirectories = { mode = 'auto' },
                    format = false,
                },
            })
        end,
    },
}
