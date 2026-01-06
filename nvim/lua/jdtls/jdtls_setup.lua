local M = {}

local function on_attach(client, bufnr)
    vim.lsp.codelens.refresh()
    vim.api.nvim_create_autocmd('BufWritePost', {
        buffer = bufnr,
        callback = vim.lsp.codelens.refresh,
    })
end

function M:setup()
    local home = os.getenv 'HOME'
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    local workspace_dir = vim.fn.stdpath 'data'
        .. package.config:sub(1, 1)
        .. 'jdtls-workspace'
        .. package.config:sub(1, 1)
        .. project_name

    local jdtls_path = home .. '/.local/share/nvim/mason/packages/jdtls'
    local config_dir

    if vim.fn.has 'mac' == 1 then
        if vim.fn.has 'macunix' == 1 and vim.loop.os_uname().machine == 'arm64' then
            config_dir = jdtls_path .. '/config_mac_arm'
        else
            config_dir = jdtls_path .. '/config_mac'
        end
    elseif vim.fn.has 'unix' == 1 then
        config_dir = jdtls_path .. '/config_linux'
    else
        config_dir = jdtls_path .. '/config_win'
    end

    local bundles = {
        vim.fn.glob(home .. '/.local/share/nvim/mason/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar'),
    }
    vim.list_extend(bundles, vim.split(vim.fn.glob(home .. '/.local/share/nvim/mason/share/java-test/*.jar', 1), '\n'))

    local extendedClientCapabilities = require('jdtls').extendedClientCapabilities

    local config = {
        -- The command that starts the language server
        -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
        cmd = {
            'java',
            '-Declipse.application=org.eclipse.jdt.ls.core.id1',
            '-Dosgi.bundles.defaultStartLevel=4',
            '-Declipse.product=org.eclipse.jdt.ls.core.product',
            '-Dlog.protocol=true',
            '-Dlog.level=ALL',
            '-Xmx1g',
            '--add-modules=ALL-SYSTEM',
            '--add-opens',
            'java.base/java.util=ALL-UNNAMED',
            '--add-opens',
            'java.base/java.lang=ALL-UNNAMED',
            '-javaagent:' .. home .. '/.local/share/nvim/mason/packages/jdtls/lombok.jar',
            '-jar',
            vim.fn.glob(home .. '/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
            '-configuration',
            config_dir,
            '-data',
            workspace_dir,
        },

        root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew' },

        -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
        -- for a list of options
        settings = {
            java = {
                signatureHelp = { enabled = true },
                maven = {
                    downloadSources = true,
                },
                referencesCodeLens = {
                    enabled = true,
                },
                references = {
                    includeDecompiledSources = true,
                },
                implementationCodeLens = {
                    enabled = true,
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
            },
        },
        init_options = {
            bundles = bundles,
            extendedClientCapabilities = extendedClientCapabilities,
        },
        extendedClientCapabilities = extendedClientCapabilities,
        on_attach = on_attach,
    }

    vim.keymap.set('n', 'gt', require('jdtls.tests').goto_subjects, { desc = 'Go to test' })
    vim.keymap.set('n', '<leader>jb', ':JdtBytecode<CR>', { desc = 'Show [j]ava [b]ytecode' })

    require('jdtls').start_or_attach(config)
end

return M
