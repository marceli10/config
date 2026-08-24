local inlay_hints = {
    includeInlayEnumMemberValueHints = true,
    includeInlayFunctionLikeReturnTypeHints = true,
    includeInlayParameterNameHints = 'literals',
    includeInlayFunctionParameterTypeHints = true,
    includeInlayPropertyDeclarationTypeHints = true,
    includeInlayVariableTypeHints = false,
}

return {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    opts = {
        on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
        end,
        settings = {
            complete_function_calls = true,
            tsserver_file_preferences = inlay_hints,
        },
    },
}
