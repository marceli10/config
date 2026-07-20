return {
    'nvim-neotest/neotest',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',
        'nvim-neotest/nvim-nio',
        'lawrence-laz/neotest-zig',
        'nvim-neotest/neotest-python',
        'nvim-neotest/neotest-jest',
        'marilari88/neotest-vitest',
        'rcasia/neotest-java',
        'mfussenegger/nvim-jdtls',
    },
    keys = {
        {
            '<leader>tr',
            function()
                require('neotest').run.run()
            end,
            desc = 'Run nearest test',
        },
        {
            '<leader>tR',
            function()
                require('neotest').run.run(vim.fn.expand '%')
            end,
            desc = 'Run file tests',
        },
        {
            '<leader>tl',
            function()
                require('neotest').run.run_last()
            end,
            desc = 'Run last test',
        },
        {
            '<leader>tt',
            function()
                require('neotest').summary.toggle()
            end,
            desc = 'Toggle test summary',
        },
        {
            '<leader>to',
            function()
                require('neotest').output.open { enter = true }
            end,
            desc = 'Open test output',
        },
        {
            '<leader>tO',
            function()
                require('neotest').output_panel.toggle()
            end,
            desc = 'Toggle output panel',
        },
        {
            '<leader>ts',
            function()
                require('neotest').run.stop()
            end,
            desc = 'Stop test',
        },
        {
            '<leader>td',
            function()
                require('neotest').run.run { strategy = 'dap' }
            end,
            desc = 'Debug nearest test',
        },
    },
    config = function()
        require('neotest').setup {
            adapters = {
                require 'neotest-zig' {
                    dap = { adapter = 'codelldb' },
                },
                require 'neotest-python' {
                    runner = 'pytest',
                    -- debug with <leader>td; justMyCode=false steps into deps too
                    dap = { justMyCode = false },
                },
                require 'neotest-jest' {},
                require 'neotest-vitest' {},
                require 'neotest-java' {},
            },
            floating = {
                border = 'rounded',
            },
        }
    end,
}
