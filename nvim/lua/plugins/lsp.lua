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
                    -- Call hover lazily: noice overrides vim.lsp.buf.hover after this autocmd runs,
                    -- so binding the value directly races and often keeps the borderless native hover.
                    -- The border arg is the fallback when noice is not the one rendering.
                    vim.keymap.set('n', 'K', function()
                        vim.lsp.buf.hover { border = 'rounded' }
                    end, opts 'Hover')
                    vim.keymap.set('n', 'gK', vim.lsp.buf.signature_help, opts 'Signature Help')
                    vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, opts 'Signature Help')
                    vim.keymap.set({ 'n', 'x' }, '<A-Enter>', vim.lsp.buf.code_action, opts 'Code Action')
                    vim.keymap.set({ 'n', 'x' }, 'gca', vim.lsp.codelens.run, opts 'Run Codelens')
                    vim.keymap.set('n', 'gcr', vim.lsp.codelens.refresh, opts 'Refresh Codelens')
                    vim.keymap.set('n', 'rn', vim.lsp.buf.rename, opts 'Rename')
                    vim.keymap.set({ 'n', 'x' }, '<C-f>', function()
                        vim.lsp.buf.format { async = true }
                    end, opts 'Format Buffer')

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
                        -- ast-check only catches syntax/AST errors; build-on-save runs
                        -- `zig build` so Sema-level errors (calls to nonexistent funcs,
                        -- type mismatches) surface as diagnostics. Needs a build.zig.
                        enable_build_on_save = true,
                        build_on_save_step = 'install',
                    },
                },
            })

            -- Python uses two servers side by side: pyrefly for type checking /
            -- navigation / hover, and ruff for linting + formatting + code actions.
            -- Silence ruff's hover so pyrefly owns it and they don't double up.
            vim.lsp.config('ruff', {
                on_attach = function(client)
                    client.server_capabilities.hoverProvider = false
                end,
            })

            -- JS/TS: vtsls for LSP actions/hover/completion, eslint owns formatting.
            -- Settings mirror LazyVim's vtsls defaults.
            local vtsls_typescript_settings = {
                updateImportsOnFileMove = { enabled = 'always' },
                suggest = {
                    completeFunctionCalls = true,
                },
                inlayHints = {
                    enumMemberValues = { enabled = true },
                    functionLikeReturnTypes = { enabled = true },
                    parameterNames = { enabled = 'literals' },
                    parameterTypes = { enabled = true },
                    propertyDeclarationTypes = { enabled = true },
                    variableTypes = { enabled = false },
                },
            }

            vim.lsp.config('vtsls', {
                settings = {
                    complete_function_calls = true,
                    vtsls = {
                        enableMoveToFileCodeAction = true,
                        autoUseWorkspaceTsdk = true,
                        experimental = {
                            maxInlayHintLength = 30,
                            completion = {
                                enableServerSideFuzzyMatch = true,
                            },
                        },
                    },
                    typescript = vtsls_typescript_settings,
                    javascript = vtsls_typescript_settings,
                },
                -- eslint is the formatter (see below); vtsls shouldn't also offer to format.
                on_attach = function(client)
                    client.server_capabilities.documentFormattingProvider = false
                    client.server_capabilities.documentRangeFormattingProvider = false
                end,
            })

            -- eslint.format=true exposes textDocument/formatting so <C-f> formats via eslint.
            vim.lsp.config('eslint', {
                settings = {
                    workingDirectories = { mode = 'auto' },
                    format = true,
                },
            })
        end,
    },
}
