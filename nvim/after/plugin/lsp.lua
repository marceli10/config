local function goto_source_definition()
    local position_params = vim.lsp.util.make_position_params()
    vim.lsp.buf.execute_command {
        command = '_typescript.goToSourceDefinition',
        arguments = { vim.api.nvim_buf_get_name(0), position_params.position },
    }
end

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client == nil then
            return
        end

        -- Disable semantic highlights
        client.server_capabilities.semanticTokensProvider = nil

        local opts = { buffer = event.buf }
        local builtin = require 'telescope.builtin'
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gd', builtin.lsp_definitions, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gi', builtin.lsp_implementations, opts)
        vim.keymap.set('n', 'gr', builtin.lsp_references, opts)
        vim.keymap.set('n', 'gs', builtin.lsp_workspace_symbols, opts)
        vim.keymap.set('n', 'rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'x' }, '<C-f>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
        vim.keymap.set('n', '<A-Enter>', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gn', '<cmd>lua vim.diagnostic.jump({count=1, float=true})<cr>', opts)
        vim.keymap.set('n', 'gp', '<cmd>lua vim.diagnostic.jump({count=-1, float=true})<cr>', opts)
    end,
})

vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            diagnostics = {
                disable = {
                    'undefined-global',
                    'undefined-field',
                },
            },
        },
    },
})

vim.lsp.config('ts_ls', {
    on_attach = function(client, bufnr)
        vim.opt.tabstop = 2
        vim.opt.shiftwidth = 2
        vim.opt.softtabstop = 2

        local opts = { buffer = bufnr }
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
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'java',
    callback = function(args)
        require('jdtls.jdtls_setup'):setup()
    end,
})

local servers = {
    'lua_ls',
    'ts_ls',
    'html',
    'postgres_lsp',
    'pyright',
    'vimls',
    'cssls',
}

vim.lsp.enable(servers)
