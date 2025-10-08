local bundles = {
    vim.fn.expand '$HOME/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar',
}

vim.list_extend(bundles, vim.fn.glob(vim.fn.expand '$HOME/.local/share/nvim/mason/packages/java-test/extension/server/*.jar', true, true))

require('jdtls').start_or_attach {
    cmd = {
        vim.fn.expand '$HOME/.local/share/nvim/mason/bin/jdtls',
        ('--jvm-arg=-javaagent:%s'):format(vim.fn.expand '$HOME/.local/share/nvim/mason/packages/jdtls/lombok.jar'),
    },
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    bundles = bundles
}
