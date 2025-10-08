return {
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.8',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require('telescope.builtin')

            vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '[f]ind [h]elp' })
            vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = '[f]ind [k]eymaps' })
            vim.keymap.set('n', '<leader>fo', builtin.find_files, { desc = '[fo] find files' })
            vim.keymap.set('n', '<leader>fs', builtin.builtin, { desc = '[f]ind [s]elect Telescope' })
            vim.keymap.set('n', '<leader>fc', builtin.grep_string, { desc = '[f]ind [c]urrent word' })
            vim.keymap.set('n', '<leader>fw', builtin.live_grep, { desc = '[fw] find by grep' })
            vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = '[f]ind [d]iagnostics' })
            vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = '[f]ind [r]esume' })
            vim.keymap.set('n', '<leader>f.', builtin.oldfiles, { desc = '[f]ind Recent Files ("." for repeat)' })
            vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

            vim.keymap.set('n', '<leader>ff', function()
            builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
              winblend = 10,
              previewer = false,
            })
              end, { desc = '[f]uzzily [f]ind in current buffer' })

              vim.keymap.set('n', '<leader>f/', function()
            builtin.live_grep {
              grep_open_files = true,
              prompt_title = 'Live Grep in Open Files',
            }
              end, { desc = '[f]ind [/] in Open Files' })

              -- Shortcut for searching your Neovim configuration files
              vim.keymap.set('n', '<leader>fn', function()
            builtin.find_files { cwd = vim.fn.stdpath 'config' }
              end, { desc = '[f]ind [n]eovim files' })
        end
    },
    {
        'nvim-telescope/telescope-ui-select.nvim',
        config = function()
            local actions = require("telescope.actions")

            require("telescope").setup({
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown {}
                    }
                },
                mappings = {
                    i = {
                        ["<C-n>"] = actions.cycle_history_next,
                        ["<C-p>"] = actions.cycle_history_prev,
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                    }
                },

                require("telescope").load_extension("ui-select")
            })
        end
    }
}
