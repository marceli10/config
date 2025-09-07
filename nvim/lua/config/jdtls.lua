local function get_jdtls()
    local mason_registry = require 'mason-registry'
    local jdtls = mason_registry.get_package 'jdtls'
    local jdtls_path = jdtls:get_install_path()
    local launcher = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')

    local config = jdtls_path .. '/config_mac'

    local lombok = jdtls_path .. '/lombok.jar'

    return launcher, config, lombok
end

local function get_bundles()
    local mason_registry = require 'mason-registry'

    local java_debug = mason_registry.get_package 'java-debug-adapter'

    local java_debug_path = java_debug:get_install_path()

    local bundles = {
        vim.fn.glob(java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar', 1),
    }

    local java_test = mason_registry.get_package 'java-test'

    local java_test_path = java_test:get_install_path()

    vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. '/extension/server/*.jar', 1), '\n'))

    return bundles
end

local function get_workspace()
    -- Get the home directory of your operating system
    local home = os.getenv 'HOME'
    -- Declare a directory where you would like to store project information
    local workspace_path = home .. '/code/workspace/'
    -- Determine the project name
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    -- Create the workspace directory by concatenating the designated workspace path and the project name
    local workspace_dir = workspace_path .. project_name
    return workspace_dir
end

local function java_keymaps()
    -- Allow yourself to run JdtCompile as a Vim command
    vim.cmd "command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_compile JdtCompile lua require('jdtls').compile(<f-args>)"

    -- Allow yourself/register to run JdtUpdateConfig as a Vim command
    vim.cmd "command! -buffer JdtUpdateConfig lua require('jdtls').update_project_config()"

    -- Allow yourself/register to run JdtBytecode as a Vim command
    vim.cmd "command! -buffer JdtBytecode lua require('jdtls').javap()"

    -- Allow yourself/register to run JdtShell as a Vim command
    vim.cmd "command! -buffer JdtJshell lua require('jdtls').jshell()"

    -- TODO: remap all of this garbage shortcuts
    vim.keymap.set(
        'n',
        '<leader>o',
        "<Cmd> lua require('jdtls').organize_imports()<CR>",
        { desc = '[J]ava [O]rganize Imports' }
    )

    vim.keymap.set(
        'n',
        '<leader>ev',
        "<Cmd> lua require('jdtls').extract_variable()<CR>",
        { desc = '[J]ava Extract [V]ariable' }
    )

    vim.keymap.set(
        'v',
        '<leader>ev',
        "<Esc><Cmd> lua require('jdtls').extract_variable(true)<CR>",
        { desc = '[J]ava Extract [V]ariable' }
    )

    vim.keymap.set(
        'n',
        '<leader>ec',
        "<Cmd> lua require('jdtls').extract_constant()<CR>",
        { desc = '[J]ava Extract [C]onstant' }
    )

    vim.keymap.set(
        'v',
        '<leader>ec',
        "<Esc><Cmd> lua require('jdtls').extract_constant(true)<CR>",
        { desc = '[J]ava Extract [C]onstant' }
    )

    vim.keymap.set(
        'n',
        '<leader>t',
        "<Cmd> lua require('jdtls').test_nearest_method()<CR>",
        { desc = '[J]ava [T]est Method' }
    )

    vim.keymap.set(
        'v',
        '<leader>t',
        "<Esc><Cmd> lua require('jdtls').test_nearest_method(true)<CR>",
        { desc = '[J]ava [T]est Method' }
    )

    vim.keymap.set('n', '<leader>T', "<Cmd> lua require('jdtls').test_class()<CR>", { desc = '[J]ava [T]est Class' })

    vim.keymap.set('n', '<leader>ju', '<Cmd> JdtUpdateConfig<CR>', { desc = '[J]ava [U]pdate Config' })
end

local function setup_jdtls()
    local jdtls = require 'jdtls'
    local launcher, os_config, lombok = get_jdtls()

    local workspace_dir = get_workspace()

    local bundles = get_bundles()

    local root_dir = jdtls.setup.find_root { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle', 'build.gralde.kts' }

    local capabilities = {
        workspace = {
            configuration = true,
        },
        textDocument = {
            completion = {
                snippetSupport = false,
            },
        },
    }

    local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

    for k, v in pairs(lsp_capabilities) do
        capabilities[k] = v
    end

    -- Get the default extended client capablities of the JDTLS language server
    local extendedClientCapabilities = jdtls.extendedClientCapabilities
    -- Modify one property called resolveAdditionalTextEditsSupport and set it to true
    extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

    -- Set the command that starts the JDTLS language server jar
    local cmd = {
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
        '-javaagent:' .. lombok,
        '-jar',
        launcher,
        '-configuration',
        os_config,
        '-data',
        workspace_dir,
    }

    local settings = {
        java = {
            format = {
                enabled = true,
                -- Use the Google Style guide for code formatting
                settings = {
                    url = vim.fn.stdpath 'config' .. '/lang_servers/intellij-java-google-style.xml',
                    profile = 'GoogleStyle',
                },
            },

            eclipse = {
                downloadSource = true,
            },

            maven = {
                downloadSources = true,
            },

            signatureHelp = {
                enabled = true,
            },

            contentProvider = {
                preferred = 'fernflower',
            },

            saveActions = {
                organizeImports = true,
            },

            completion = {
                favoriteStaticMembers = {
                    'org.hamcrest.MatcherAssert.assertThat',
                    'org.hamcrest.Matchers.*',
                    'org.hamcrest.CoreMatchers.*',
                    'org.junit.jupiter.api.Assertions.*',
                    'java.util.Objects.requireNonNull',
                    'java.util.Objects.requireNonNullElse',
                    'org.mockito.Mockito.*',
                },

                filteredTypes = {
                    'com.sun.*',
                    'io.micrometer.shaded.*',
                    'java.awt.*',
                    'jdk.*',
                    'sun.*',
                },

                importOrder = {
                    'java',
                    'jakarta',
                    'javax',
                    'com',
                    'org',
                },
            },
            sources = {

                organizeImports = {
                    starThreshold = 9999,
                    staticThreshold = 9999,
                },
            },

            codeGeneration = {

                toString = {
                    template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
                },

                hashCodeEquals = {
                    useJava7Objects = true,
                },

                useBlocks = true,
            },

            configuration = {
                updateBuildConfiguration = 'interactive',
            },

            referencesCodeLens = {
                enabled = true,
            },

            inlayHints = {
                parameterNames = {
                    enabled = 'all',
                },
            },
        },
    }

    local init_options = {
        bundles = bundles,
        extendedClientCapabilities = extendedClientCapabilities,
    }

    local on_attach = function(_, bufnr)
        java_keymaps()

        require('jdtls.dap').setup_dap()

        -- Find the main method(s) of the application so the debug adapter can successfully start up the application
        -- Sometimes this will randomly fail if language server takes to long to startup for the project, if a ClassDefNotFoundException occurs when running
        -- the debug tool, attempt to run the debug tool while in the main class of the application, or restart the neovim instance
        -- Unfortunately I have not found an elegant way to ensure this works 100%
        require('jdtls.dap').setup_dap_main_class_configs()
        -- Enable jdtls commands to be used in Neovim
        require('jdtls.setup').add_commands()
        -- Refresh the codelens
        -- Code lens enables features such as code reference counts, implemenation counts, and more.
        vim.lsp.codelens.refresh()

        -- Setup a function that automatically runs every time a java file is saved to refresh the code lens
        vim.api.nvim_create_autocmd('BufWritePost', {
            pattern = { '*.java' },
            callback = function()
                local _, _ = pcall(vim.lsp.codelens.refresh)
            end,
        })
    end

    -- Create the configuration table for the start or attach function
    local config = {
        cmd = cmd,
        root_dir = root_dir,
        settings = settings,
        capabilities = capabilities,
        init_options = init_options,
        on_attach = on_attach,
    }

    -- Start the JDTLS server
    require('jdtls').start_or_attach(config)
end

return {
    setup_jdtls = setup_jdtls,
}
