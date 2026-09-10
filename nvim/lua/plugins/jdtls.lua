return {
    'mfussenegger/nvim-jdtls',
    ft = { 'java' },
    dependencies = { 'neovim/nvim-lspconfig' },
    config = function()
        local library_favorites = {
            'org.junit.Assert.*',
            'org.junit.Assume.*',
            'org.junit.jupiter.api.Assertions.*',
            'org.junit.jupiter.api.Assumptions.*',
            'org.junit.jupiter.api.DynamicTest.*',
            'org.junit.jupiter.api.DynamicContainer.*',
            'org.mockito.Mockito.*',
            'org.mockito.ArgumentMatchers.*',
            'org.assertj.core.api.Assertions.*',
        }

        local max_project_favorites = 300

        local function project_static_favorites(root_dir)
            if not root_dir or vim.fn.executable 'rg' == 0 then
                return {}
            end

            local grep = vim.system({
                'rg',
                '--files-with-matches',
                '--type',
                'java',
                '--glob',
                '!**/target/**',
                '--glob',
                '!**/build/**',
                'public static',
                root_dir,
            }, { text = true }):wait(5000)
            local files = vim.split(grep.stdout or '', '\n', { trimempty = true })
            if #files == 0 then
                return {}
            end
            if #files > max_project_favorites then
                files = vim.list_slice(files, 1, max_project_favorites)
            end

            local args = { 'rg', '--max-count', '1', '--no-heading', '--with-filename', '^\\s*package\\s' }
            vim.list_extend(args, files)
            local packages = vim.system(args, { text = true }):wait(5000)

            local favorites = {}
            for _, line in ipairs(vim.split(packages.stdout or '', '\n', { trimempty = true })) do
                local path, package = line:match '^(.*%.java):%s*package%s+([%w_.]+)%s*;'
                if path and package then
                    favorites[#favorites + 1] = package .. '.' .. vim.fn.fnamemodify(path, ':t:r') .. '.*'
                end
            end
            return favorites
        end

        local function favorites_for(root_dir)
            return vim.list_extend(vim.list_extend({}, library_favorites), project_static_favorites(root_dir))
        end

        local function attach_jdtls()
            local config = vim.deepcopy(vim.lsp.config.jdtls)
            local root_dir = vim.fs.root(vim.api.nvim_buf_get_name(0), config.root_markers)

            if root_dir then
                local project = vim.fs.basename(root_dir) .. '-' .. vim.fn.sha256(root_dir):sub(1, 8)
                local cache = vim.fn.stdpath 'cache' .. '/jdtls/' .. project
                vim.list_extend(config.cmd, { '-configuration', cache .. '/config', '-data', cache .. '/workspace' })
            end

            config.root_dir = root_dir
            config.settings.java.completion.favoriteStaticMembers = favorites_for(root_dir)
            -- classFileContentsSupport is what makes the server hand out jdt:// URIs
            -- for compiled types; nvim-jdtls resolves those via its BufReadCmd, and
            -- without the flag gd into a JDK/library type dead-ends. The prompt flags
            -- enable the override/constructor/toString/extract code actions.
            -- resolveAdditionalTextEditsSupport keeps the auto-import edit attached to
            -- a completion item when blink.cmp accepts it.
            config.init_options.extendedClientCapabilities =
                vim.tbl_extend('force', require('jdtls').extendedClientCapabilities, {
                    resolveAdditionalTextEditsSupport = true,
                })
            config.capabilities = require('blink.cmp').get_lsp_capabilities()
            require('jdtls').start_or_attach(config)
        end

        -- Has to run before nvim-jdtls' own LspAttach hook, which calls
        -- setup_dap({}); setup_dap early-returns once dap.adapters.java is set,
        -- so calling it from an LspAttach callback silently drops these opts.
        require('jdtls.dap').setup_dap { hotcodereplace = 'auto' }

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

                vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
                    buffer = args.buf,
                    callback = function()
                        vim.lsp.codelens.refresh { bufnr = args.buf }
                    end,
                })
                vim.lsp.codelens.refresh { bufnr = args.buf }

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

                map('n', '<leader>jr', '<cmd>JdtRestart<cr>', 'Restart jdtls')
                map('n', '<leader>jw', '<cmd>JdtWipeDataAndRestart<cr>', 'Wipe workspace and restart jdtls')
                map('n', '<leader>ju', '<cmd>JdtUpdateConfig<cr>', 'Reload build config')
                map('n', '<leader>jc', '<cmd>JdtCompile full<cr>', 'Full rebuild')
                map('n', '<leader>jf', function()
                    local favorites = favorites_for(client.root_dir)
                    client.settings.java.completion.favoriteStaticMembers = favorites
                    client:notify('workspace/didChangeConfiguration', { settings = client.settings })
                    vim.notify(('jdtls: %d static import favorites'):format(#favorites))
                end, 'Rescan static import favorites')

                local jdtls_dap = require 'jdtls.dap'
                map('n', '<leader>dm', function()
                    jdtls_dap.setup_dap_main_class_configs {
                        verbose = true,
                        on_ready = function()
                            require('dap').continue()
                        end,
                    }
                end, 'Debug main class')
                map('n', '<leader>dn', jdtls_dap.test_nearest_method, 'Debug nearest test')
                map('n', '<leader>dT', jdtls_dap.test_class, 'Debug test class')
            end,
        })

        attach_jdtls()
    end,
}
