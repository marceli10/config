return {
    {
        'rcasia/neotest-java',
        ft = 'java',
        dependencies = {
            'mfussenegger/nvim-jdtls',
            'mfussenegger/nvim-dap',
            'rcarriga/nvim-dap-ui',
            'theHamsta/nvim-dap-virtual-text',
        },
    },
    {
        'nvim-neotest/neotest',
        dependencies = {
            'nvim-neotest/nvim-nio',
            'nvim-lua/plenary.nvim',
            'antoinemadec/FixCursorHold.nvim',
            'nvim-treesitter/nvim-treesitter',
            'atm1020/neotest-jdtls',
            'mfussenegger/nvim-jdtls',
            'mfussenegger/nvim-dap',
            'rcarriga/nvim-dap-ui',
            'theHamsta/nvim-dap-virtual-text',
        },
        config = function()
            require('neotest').setup {
                log_level = vim.log.levels.TRACE,

                adapters = {
                    -- require 'neotest-java' {
                    --     ignore_wrapper = false,
                    --     junit_jar = nil,
                    -- },
                    require 'neotest-jdtls',
                },
            }
        end,
        keys = function()
            local neotest = require 'neotest'

            vim.keymap.set('n', '<leader>tr', function()
                neotest.run.run()
            end, { desc = 'Run nearest test' })

            vim.keymap.set('n', '<leader>tf', function()
                neotest.run.run(vim.fn.expand '%')
            end, { desc = 'Run current file tests' })

            vim.keymap.set('n', '<leader>ts', function()
                neotest.run.run(vim.fn.getcwd())
            end, { desc = 'Run test suite' })

            vim.keymap.set('n', '<leader>tl', function()
                neotest.run.run_last()
            end, { desc = 'Run last test' })

            vim.keymap.set('n', '<leader>td', function()
                neotest.run.run { strategy = 'dap' }
            end, { desc = 'Debug nearest test' })

            vim.keymap.set('n', '<leader>tD', function()
                neotest.run.run { vim.fn.expand '%', strategy = 'dap' }
            end, { desc = 'Debug current file tests' })

            vim.keymap.set('n', ']t', function()
                neotest.jump.next { status = 'failed' }
            end, { desc = 'Jump to next failed test' })

            vim.keymap.set('n', '[t', function()
                neotest.jump.prev { status = 'failed' }
            end, { desc = 'Jump to previous failed test' })

            vim.keymap.set('n', '<leader>to', function()
                neotest.output.open { enter = true, auto_close = true }
            end, { desc = 'Show test output' })

            vim.keymap.set('n', '<leader>tO', function()
                neotest.output_panel.toggle()
            end, { desc = 'Toggle output panel' })

            vim.keymap.set('n', '<leader>tt', function()
                neotest.summary.toggle()
            end, { desc = 'Toggle test summary' })

            vim.keymap.set('n', '<leader>tx', function()
                neotest.run.stop()
            end, { desc = 'Stop running tests' })

            vim.keymap.set('n', '<leader>ta', function()
                neotest.run.run { suite = true }
            end, { desc = 'Run all tests in project' })
        end,
    },
}
