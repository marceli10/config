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

            vim.lsp.enable { 'zls', 'pyrefly', 'ruff', 'clangd', 'eslint', 'lua_ls' }

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

            local ok, capability = pcall(require, 'vim.lsp._capability')
            local codelens = ok and pcall(require, 'vim.lsp.codelens') and capability.all.codelens
            if codelens then
                codelens.on_win = function(self, toprow, botrow)
                    for row = toprow, botrow do
                        if self.row_version[row] ~= self.version then
                            for client_id, state in pairs(self.client_state) do
                                vim.api.nvim_buf_clear_namespace(self.bufnr, state.namespace, row, row + 1)

                                local lenses = state.row_lenses[row]
                                if lenses then
                                    table.sort(lenses, function(a, b)
                                        return a.range.start.character < b.range.start.character
                                    end)

                                    local client = assert(vim.lsp.get_client_by_id(client_id))
                                    local virt_text = {}
                                    for _, lens in ipairs(lenses) do
                                        if not lens.command then
                                            self:resolve(client, lens)
                                        else
                                            vim.list_extend(virt_text, {
                                                { lens.command.title, 'LspCodeLens' },
                                                { ' | ', 'LspCodeLensSeparator' },
                                            })
                                        end
                                    end
                                    table.remove(virt_text)

                                    if #virt_text > 0 then
                                        vim.api.nvim_buf_set_extmark(self.bufnr, state.namespace, row, 0, {
                                            virt_text = virt_text,
                                            virt_text_pos = 'eol',
                                            hl_mode = 'combine',
                                        })
                                    end
                                end
                            end
                            self.row_version[row] = self.version
                        end
                    end

                    if botrow == vim.api.nvim_buf_line_count(self.bufnr) - 1 then
                        for _, state in pairs(self.client_state) do
                            vim.api.nvim_buf_clear_namespace(self.bufnr, state.namespace, botrow + 1, -1)
                        end
                    end
                end
            end

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
        end,
    },
}
