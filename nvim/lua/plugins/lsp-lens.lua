return {
    'VidocqH/lsp-lens.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
        target_symbol_kinds = {
            vim.lsp.protocol.SymbolKind.Function,
            vim.lsp.protocol.SymbolKind.Method,
            vim.lsp.protocol.SymbolKind.Interface,
            vim.lsp.protocol.SymbolKind.Variable,
            vim.lsp.protocol.SymbolKind.Constant,
        },
        sections = {
            definition = false,
            references = true,
            implements = false,
            git_authors = false,
        },
    },
    config = function(_, opts)
        local lens = require 'lsp-lens.lens-util'
        local sweep = lens.procedure
        local timer = assert(vim.uv.new_timer())
        lens.procedure = function()
            timer:stop()
            timer:start(300, 0, vim.schedule_wrap(sweep))
        end

        require('lsp-lens').setup(opts)

        local ns = vim.api.nvim_create_namespace 'lsp-lens'
        local set_extmark = vim.api.nvim_buf_set_extmark
        vim.api.nvim_buf_set_extmark = function(bufnr, namespace, line, col, o)
            if namespace == ns and o and o.virt_lines then
                local chunks = { { '  ' } }
                for _, vline in ipairs(o.virt_lines) do
                    for _, chunk in ipairs(vline) do
                        table.insert(chunks, { vim.trim(chunk[1]), chunk[2] })
                    end
                end
                o = { virt_text = chunks, virt_text_pos = 'eol', hl_mode = 'combine' }
            end
            return set_extmark(bufnr, namespace, line, col, o)
        end
    end,
}
