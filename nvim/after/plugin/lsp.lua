local function lsp_highlight_document(client)
    if client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_exec(
            [[
            augroup lsp_document_highlight
                autocmd! * <buffer>
                autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
            augroup END
            ]],
            false
        )
    end
end

local function goto_source_definition()
    local position_params = vim.lsp.util.make_position_params()
    vim.lsp.buf.execute_command {
        command = '_typescript.goToSourceDefinition',
        arguments = { vim.api.nvim_buf_get_name(0), position_params.position },
    }
end

local function on_attach(client, bufnr)
    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
    vim.opt.softtabstop = 2

    local opts = { buffer = bufnr }
    vim.keymap.set('n', 'gs', goto_source_definition, opts)

    if client.supports_method 'textDocument/codeLens' then
        vim.lsp.codelens.refresh()
        vim.api.nvim_create_autocmd('BufWritePost', {
            buffer = bufnr,
            callback = vim.lsp.codelens.refresh,
        })
    end
end

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client == nil then
            return
        end

        lsp_highlight_document(client)

        -- Disable semantic highlights
        client.server_capabilities.semanticTokensProvider = nil

        local opts = { buffer = event.buf }
        local builtin = require 'telescope.builtin'

        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gd', builtin.lsp_definitions, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', 'gr', builtin.lsp_references, opts)
        vim.keymap.set('n', 'gs', builtin.lsp_workspace_symbols, opts)
        vim.keymap.set('n', 'rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'x' }, '<C-f>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
        vim.keymap.set('n', '<A-Enter>', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gn', '<cmd>lua vim.diagnostic.jump({count=1, float=true})<cr>', opts)
        vim.keymap.set('n', 'gp', '<cmd>lua vim.diagnostic.jump({count=-1, float=true})<cr>', opts)

        if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
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

vim.lsp.config('basedpyright', {
    settings = {
        basedpyright = {
            analysis = {
                typeCheckingMode = 'strict', -- off | basic | standard | strict
                strictParameterChecks = true,
                strictPropertyInitialization = true,

                diagnosticMode = 'workspace', -- Analyze whole project, not only open files
                useLibraryCodeForTypes = true,
                autoSearchPaths = true,
                autoImportCompletions = true,

                reportMissingTypeStubs = 'warning',
                reportMissingImports = 'error',
                reportUnboundVariable = 'error',
                reportUnusedImport = 'warning',
                reportUnusedFunction = 'warning',
                reportUnusedVariable = 'warning',
                reportIncompatibleMethodOverride = 'error',
                reportIncompatibleVariableType = 'error',

                logLevel = 'warning', -- reduce noise
                indexing = true, -- faster global symbol search
                completeFunctionParens = true,
            },
        },
    },
})

vim.lsp.config('ruff', {})

vim.lsp.config('ts_ls', {
    settings = {
        javascript = {
            referencesCodeLens = { enabled = true },
            implementationsCodeLens = { enabled = true },
        },
        typescript = {
            referencesCodeLens = { enabled = true },
            implementationsCodeLens = { enabled = true },
        },
    },
    on_attach = on_attach,
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

vim.lsp.config('gradle_ls', {
    filetypes = { 'groovy', 'kotlin' },
    root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew' },
    settings = {
        gradle = {
            wrapper = {
                enabled = true,
            },
        },
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
    'basedpyright',
    'vimls',
    'cssls',
    'gradle_ls',
    'ruff',
}

vim.lsp.enable(servers)
