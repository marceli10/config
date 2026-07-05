return {
    'mfussenegger/nvim-dap',
    dependencies = {
        'rcarriga/nvim-dap-ui',
        'nvim-neotest/nvim-nio',
        'jay-babu/mason-nvim-dap.nvim',
        'mfussenegger/nvim-dap-python',
    },
    keys = {
        {
            '<leader>db',
            function()
                require('dap').toggle_breakpoint()
            end,
            desc = 'Toggle breakpoint',
        },
        {
            '<leader>dB',
            function()
                require('dap').set_breakpoint(vim.fn.input 'Condition: ')
            end,
            desc = 'Conditional breakpoint',
        },
        {
            '<leader>dc',
            function()
                require('dap').continue()
            end,
            desc = 'Continue',
        },
        {
            '<leader>di',
            function()
                require('dap').step_into()
            end,
            desc = 'Step into',
        },
        {
            '<leader>do',
            function()
                require('dap').step_over()
            end,
            desc = 'Step over',
        },
        {
            '<leader>dO',
            function()
                require('dap').step_out()
            end,
            desc = 'Step out',
        },
        {
            '<leader>dr',
            function()
                require('dap').repl.toggle()
            end,
            desc = 'Toggle REPL',
        },
        {
            '<leader>dl',
            function()
                require('dap').run_last()
            end,
            desc = 'Run last',
        },
        {
            '<leader>du',
            function()
                require('dapui').toggle()
            end,
            desc = 'Toggle DAP UI',
        },
        {
            '<leader>dt',
            function()
                require('dap').terminate()
            end,
            desc = 'Terminate',
        },
    },
    config = function()
        local dap = require 'dap'
        local dapui = require 'dapui'

        require('mason-nvim-dap').setup {
            -- javadbg -> java-debug-adapter, javatest -> java-test, python -> debugpy (Mason packages)
            ensure_installed = { 'codelldb', 'javadbg', 'javatest', 'python', 'js-debug-adapter' },
            automatic_installation = { exclude = { 'chrome' } }, -- chrome adapter is deprecated in favor of js-debug-adapter
            handlers = {},
        }

        -- nvim-dap-python wires debugpy's adapter + the python launch/test
        -- configurations; neotest-python's dap strategy reuses this adapter.
        require('dap-python').setup(vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/bin/python')

        dapui.setup()

        -- IntelliJ-style gutter: a solid red dot for breakpoints, and the
        -- current execution line marked with an arrow + highlighted line.
        vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#db5860' })
        vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef' })
        vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#ffcc00' })
        vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#2d3343' })

        vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint' })
        vim.fn.sign_define('DapBreakpointCondition', { text = '●', texthl = 'DapBreakpoint' })
        vim.fn.sign_define('DapBreakpointRejected', { text = '○', texthl = 'DapBreakpoint' })
        vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DapLogPoint' })
        vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DapStopped', linehl = 'DapStoppedLine', numhl = 'DapStopped' })

        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end

        local mason_path = vim.fn.stdpath 'data' .. '/mason'
        dap.adapters.codelldb = {
            type = 'server',
            port = '${port}',
            executable = {
                command = mason_path .. '/bin/codelldb',
                args = { '--port', '${port}' },
            },
        }

        dap.configurations.zig = {
            {
                name = 'Launch zig-out binary',
                type = 'codelldb',
                request = 'launch',
                program = function()
                    return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/zig-out/bin/', 'file')
                end,
                cwd = '${workspaceFolder}',
                stopOnEntry = false,
            },
        }

        -- JS/TS: one js-debug-adapter server backs node/chrome/msedge, each under
        -- its "pwa-" prefixed type; unprefixed aliases exist for VSCode launch.json compat.
        for _, adapter_type in ipairs { 'node', 'chrome', 'msedge' } do
            local pwa_type = 'pwa-' .. adapter_type

            dap.adapters[pwa_type] = {
                type = 'server',
                host = 'localhost',
                port = '${port}',
                executable = {
                    command = mason_path .. '/bin/js-debug-adapter',
                    args = { '${port}' },
                },
            }

            dap.adapters[adapter_type] = function(cb, config)
                local native_adapter = dap.adapters[pwa_type]
                config.type = pwa_type
                if type(native_adapter) == 'function' then
                    native_adapter(cb, config)
                else
                    cb(native_adapter)
                end
            end
        end

        local js_filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }

        local vscode = require 'dap.ext.vscode'
        vscode.type_to_filetypes['node'] = js_filetypes
        vscode.type_to_filetypes['pwa-node'] = js_filetypes

        for _, language in ipairs(js_filetypes) do
            local runtime_executable = nil
            if language:find 'typescript' then
                runtime_executable = vim.fn.executable 'tsx' == 1 and 'tsx' or 'ts-node'
            end

            dap.configurations[language] = {
                {
                    type = 'pwa-node',
                    request = 'launch',
                    name = 'Launch file',
                    program = '${file}',
                    cwd = '${workspaceFolder}',
                    sourceMaps = true,
                    runtimeExecutable = runtime_executable,
                    skipFiles = { '<node_internals>/**', 'node_modules/**' },
                    resolveSourceMapLocations = { '${workspaceFolder}/**', '!**/node_modules/**' },
                },
                {
                    type = 'pwa-node',
                    request = 'attach',
                    name = 'Attach',
                    processId = require('dap.utils').pick_process,
                    cwd = '${workspaceFolder}',
                    sourceMaps = true,
                    runtimeExecutable = runtime_executable,
                    skipFiles = { '<node_internals>/**', 'node_modules/**' },
                    resolveSourceMapLocations = { '${workspaceFolder}/**', '!**/node_modules/**' },
                },
            }
        end

        -- Java: jdtls's own setup_dap (lua/plugins/jdtls.lua) generates per-main-class
        -- launch configs; this remote-attach config is a fallback for attaching to an
        -- already-running JVM started with -agentlib:jdwp.
        dap.configurations.java = {
            {
                type = 'java',
                request = 'attach',
                name = 'Debug (Attach) - Remote',
                hostName = '127.0.0.1',
                port = 5005,
            },
        }
    end,
}
