return {
    'mfussenegger/nvim-jdtls',
    ft = { 'java' },
    -- needed for vim.lsp.config.jdtls.root_markers (nvim-lspconfig's built-in jdtls defaults)
    dependencies = { 'neovim/nvim-lspconfig' },
    config = function()
        local mason_path = vim.fn.stdpath 'data' .. '/mason'

        local function jdtls_opts()
            local cmd = { vim.fn.exepath 'jdtls' }
            local lombok_jar = mason_path .. '/share/jdtls/lombok.jar'
            table.insert(cmd, string.format('--jvm-arg=-javaagent:%s', lombok_jar))

            return {
                root_dir = function(path)
                    return vim.fs.root(path, vim.lsp.config.jdtls.root_markers)
                end,
                project_name = function(root_dir)
                    return root_dir and vim.fs.basename(root_dir)
                end,
                jdtls_config_dir = function(project_name)
                    return vim.fn.stdpath 'cache' .. '/jdtls/' .. project_name .. '/config'
                end,
                jdtls_workspace_dir = function(project_name)
                    return vim.fn.stdpath 'cache' .. '/jdtls/' .. project_name .. '/workspace'
                end,
                cmd = cmd,
                full_cmd = function(opts)
                    local fname = vim.api.nvim_buf_get_name(0)
                    local root_dir = opts.root_dir(fname)
                    local project_name = opts.project_name(root_dir)
                    local full = vim.deepcopy(opts.cmd)
                    if project_name then
                        vim.list_extend(full, {
                            '-configuration',
                            opts.jdtls_config_dir(project_name),
                            '-data',
                            opts.jdtls_workspace_dir(project_name),
                        })
                    end
                    return full
                end,
                -- Debugger/test-runner bundles are wired via setup_dap below;
                -- java-debug-adapter/java-test are installed through mason-nvim-dap (see dap.lua).
                dap = { hotcodereplace = 'auto', config_overrides = {} },
                dap_main = {},
                settings = {
                    java = {
                        format = { enabled = true },
                        inlayHints = {
                            parameterNames = { enabled = 'all' },
                        },
                    },
                },
            }
        end

        local opts = jdtls_opts()

        local function bundles()
            local list = {}
            local debug_jar =
                vim.fn.glob(mason_path .. '/share/java-debug-adapter/com.microsoft.java.debug.plugin-*.jar')
            if debug_jar ~= '' then
                vim.list_extend(list, vim.split(debug_jar, '\n'))
            end
            local test_jars = vim.fn.glob(mason_path .. '/share/java-test/*.jar', false, true)
            vim.list_extend(list, test_jars)
            return list
        end

        local function attach_jdtls()
            local fname = vim.api.nvim_buf_get_name(0)
            local config = {
                cmd = opts.full_cmd(opts),
                root_dir = opts.root_dir(fname),
                init_options = {
                    bundles = bundles(),
                },
                settings = opts.settings,
                capabilities = require('blink.cmp').get_lsp_capabilities(),
            }
            require('jdtls').start_or_attach(config)
        end

        vim.api.nvim_create_autocmd('FileType', {
            pattern = 'java',
            callback = attach_jdtls,
        })

        vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if not client or client.name ~= 'jdtls' then
                    return
                end

                local jdtls = require 'jdtls'
                local map = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
                end

                map('n', '<leader>co', jdtls.organize_imports, 'Organize Imports')
                map('n', '<leader>cxv', jdtls.extract_variable_all, 'Extract Variable')
                map('n', '<leader>cxc', jdtls.extract_constant, 'Extract Constant')
                map('n', '<leader>cgs', jdtls.super_implementation, 'Goto Super')
                map('x', '<leader>cxv', function()
                    jdtls.extract_variable_all(true)
                end, 'Extract Variable')
                map('x', '<leader>cxc', function()
                    jdtls.extract_constant(true)
                end, 'Extract Constant')

                jdtls.setup_dap(opts.dap)
                require('jdtls.dap').setup_dap_main_class_configs(opts.dap_main)
            end,
        })

        -- The FileType autocmd above won't fire for the buffer that's already open
        -- when this plugin loads, so attach directly for it.
        attach_jdtls()
    end,
}
