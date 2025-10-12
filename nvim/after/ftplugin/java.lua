-- separate config to try 
--[[
local bundles = {
    vim.fn.expand '$HOME/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar',
}
vim.list_extend(bundles, vim.fn.glob(vim.fn.expand '$HOME/.local/share/nvim/mason/packages/java-test/extension/server/*.jar', true, true))

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = vim.fn.stdpath('cache') .. '/jdtls/' .. project_name  -- Persistent per-project workspace

local config = {
    cmd = {
        vim.fn.expand '$HOME/.local/share/nvim/mason/bin/jdtls',
        ('--jvm-arg=-javaagent:%s'):format(vim.fn.expand '$HOME/.local/share/nvim/mason/packages/jdtls/lombok.jar'),
        '-data', workspace_dir,
    },
    root_dir = require('jdtls.setup').find_root({ 'gradlew', 'settings.gradle', 'build.gradle', '.git' }),  -- Better multi-module detection
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    settings = {
        java = {
            configuration = {
                updateBuildConfiguration = 'automatic',  -- Auto-refresh on changes
            },
        },
    },
    init_options = {
        bundles = bundles,
    },
    on_attach = function(client, bufnr)
        -- Add build keymap
        vim.keymap.set('n', '<leader>jb', function() require('jdtls').compile('full') end, { buffer = bufnr, desc = 'JDTLS Full Build' })

        -- Auto-refresh config on attach
        require('jdtls').update_project_config()
    end,
}

require('jdtls').start_or_attach(config)
]]

local bundles = {
    vim.fn.expand '$HOME/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar',
}

vim.list_extend(
    bundles,
    vim.fn.glob(vim.fn.expand '$HOME/.local/share/nvim/mason/packages/java-test/extension/server/*.jar', true, true)
)

local extendedClientCapabilities = require('jdtls').extendedClientCapabilities

local java_settings = {
    signatureHelp = { enabled = true },
    extendedClientCapabilities = extendedClientCapabilities,
    maven = {
        downloadSources = true,
    },
    referencesCodeLens = {
        enabled = true,
    },
    references = {
        includeDecompiledSources = true,
    },
    inlayHints = {
        parameterNames = {
            enabled = 'all',
        },
    },
    format = {
        enabled = false,
    },
    completion = {
        favoriteStaticMembers = {
            'org.assertj.core.api.Assertions.*',
            'org.junit.jupiter.api.Assertions.*',
            'org.junit.Assert.*',
            'org.mockito.Mockito.*',
            'org.mockito.ArgumentMatchers.*',
            'org.mockito.Answers.*',
            'org.mockito.BDDMockito.*',
            'java.util.UUID.randomUUID',
            'java.util.Collections.*',
            'java.util.Arrays.*',
            'java.lang.Math.*',
            'java.time.LocalDateTime.*',
            'java.time.LocalDate.*',
        },
        filteredTypes = {
            'com.sun.*',
            'io.micrometer.shaded.*',
            'java.awt.*',
            'jdk.*',
            'sun.*',
        },
        guessMethodArguments = true,
        maxResults = 0,
        importOrder = {
            'java',
            'javax',
            'org',
            'com',
        },
    },
    sources = {
        organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
        },
    },
    contentProvider = { preferred = 'fernflower' },
    project = {
        referencedLibraries = {
            'lib/**/*.jar',
            '**/target/dependency/*.jar',
        },
    },
}

require('jdtls').start_or_attach {
    cmd = {
        vim.fn.expand '$HOME/.local/share/nvim/mason/bin/jdtls',
        ('--jvm-arg=-javaagent:%s'):format(vim.fn.expand '$HOME/.local/share/nvim/mason/packages/jdtls/lombok.jar'),
    },
    settings = java_settings,
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    bundles = bundles,
}
