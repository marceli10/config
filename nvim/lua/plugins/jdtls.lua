return {
    'mfussenegger/nvim-jdtls',
    ft = { 'java' },
    dependencies = { 'neovim/nvim-lspconfig' },
    config = function()
        local mason_path = vim.fn.stdpath 'data' .. '/mason'
        local function java_runtimes()
            local environments = {
                [8] = 'JavaSE-1.8',
                [11] = 'JavaSE-11',
                [17] = 'JavaSE-17',
                [21] = 'JavaSE-21',
                [25] = 'JavaSE-25',
            }

            local newest = {}
            for _, root in ipairs {
                '/Library/Java/JavaVirtualMachines',
                vim.fn.expand '~/Library/Java/JavaVirtualMachines',
            } do
                for entry in vim.fs.dir(root) do
                    local home = ('%s/%s/Contents/Home'):format(root, entry)
                    local release = io.open(home .. '/release')
                    local version
                    if release then
                        version = release:read('*a'):match 'JAVA_VERSION="([%d%._]+)"'
                        release:close()
                    elseif vim.uv.fs_stat(home .. '/bin/java') then
                        version = entry:match '(%d[%d%._]*)'
                    end
                    local major = tonumber(version and (version:match '^1%.(%d+)' or version:match '^(%d+)'))
                    if major and environments[major] and (not newest[major] or newest[major].version < version) then
                        newest[major] = { name = environments[major], path = home, version = version }
                    end
                end
            end

            local runtimes = {}
            for _, runtime in pairs(newest) do
                table.insert(runtimes, { name = runtime.name, path = runtime.path })
            end
            return runtimes
        end

        local runtimes = java_runtimes()

        local function gradle_java_home()
            local by_environment = {}
            for _, runtime in ipairs(runtimes) do
                by_environment[runtime.name] = runtime.path
            end
            return by_environment['JavaSE-21'] or by_environment['JavaSE-17']
        end

        local function jdtls_opts()
            local cmd = { vim.fn.exepath 'jdtls' }
            local lombok_jar = mason_path .. '/share/jdtls/lombok.jar'
            table.insert(cmd, string.format('--jvm-arg=-javaagent:%s', lombok_jar))
            for _, arg in ipairs {
                '-XX:+UseParallelGC',
                '-XX:GCTimeRatio=4',
                '-XX:AdaptiveSizePolicyWeight=90',
                '-Dsun.zip.disableMemoryMapping=true',
                '-Xmx2G',
            } do
                table.insert(cmd, '--jvm-arg=' .. arg)
            end

            return {
                root_dir = function(path)
                    return vim.fs.root(path, vim.lsp.config.jdtls.root_markers)
                end,
                project_name = function(root_dir)
                    return root_dir and (vim.fs.basename(root_dir) .. '-' .. vim.fn.sha256(root_dir):sub(1, 8))
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
                dap = { hotcodereplace = 'auto', config_overrides = {} },
                dap_main = {},
                settings = {
                    java = {
                        format = { enabled = true },
                        inlayHints = {
                            parameterNames = { enabled = 'all' },
                        },
                        completion = {
                            importOrder = { 'java', 'javax', 'jakarta', 'org', 'com', '' },
                        },
                        configuration = {
                            updateBuildConfiguration = 'automatic',
                            runtimes = runtimes,
                        },
                        import = {
                            gradle = { java = { home = gradle_java_home() } },
                        },
                        autobuild = { enabled = true },
                        saveActions = { organizeImports = true },
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
            local fname = vim.api.nvim_buf_get_name(0)
            local root_dir = opts.root_dir(fname)
            local settings = vim.deepcopy(opts.settings)
            settings.java.completion.favoriteStaticMembers = favorites_for(root_dir)

            local config = {
                cmd = opts.full_cmd(opts),
                root_dir = root_dir,
                init_options = {
                    bundles = bundles(),
                    extendedClientCapabilities = require('jdtls').extendedClientCapabilities,
                },
                settings = settings,
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

                jdtls.setup_dap(opts.dap)

                local jdtls_dap = require 'jdtls.dap'
                map('n', '<leader>dm', function()
                    jdtls_dap.setup_dap_main_class_configs(vim.tbl_extend('force', opts.dap_main, {
                        verbose = true,
                        on_ready = function()
                            require('dap').continue()
                        end,
                    }))
                end, 'Debug main class')
                map('n', '<leader>dn', jdtls_dap.test_nearest_method, 'Debug nearest test')
                map('n', '<leader>dT', jdtls_dap.test_class, 'Debug test class')
            end,
        })

        attach_jdtls()
    end,
}
