return {
    {
        'ibhagwan/fzf-lua',
        -- "nvim-tree/nvim-web-devicons" is optional but recommended for icons
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            local fzf = require('fzf-lua')

            -- General Setup
            fzf.setup({
                'default-title', -- Use title format similar to Telescope
                winopts = {
                    preview = {
                        -- Default previewer layout
                        layout = 'flex',
                    },
                },
                -- Enable fzf-lua as the default UI select (replaces telescope-ui-select)
                ui_select = function(fzf_opts, items)
                    return vim.tbl_deep_extend('force', fzf_opts, {
                        prompt = 'Select > ',
                        winopts = {
                            height = 0.33,
                            width = 0.33,
                        },
                    })
                end
            })

            -- Register the UI select handler
            fzf.register_ui_select()

            -- Keymaps
            vim.keymap.set('n', '<leader>fh', fzf.help_tags, { desc = '[f]ind [h]elp' })
            vim.keymap.set('n', '<leader>fk', fzf.keymaps, { desc = '[f]ind [k]eymaps' })
            vim.keymap.set('n', '<leader>fo', fzf.files, { desc = '[fo] find files' })
            vim.keymap.set('n', '<leader>fs', fzf.builtin, { desc = '[f]ind [s]elect fzf' }) -- Maps to fzf builtins
            vim.keymap.set('n', '<leader>fc', fzf.grep_cword, { desc = '[f]ind [c]urrent word' })
            vim.keymap.set('n', '<leader>fw', fzf.live_grep, { desc = '[fw] find by grep' })
            vim.keymap.set('n', '<leader>fd', fzf.diagnostics_document, { desc = '[f]ind [d]iagnostics' }) -- or fzf.diagnostics_workspace
            vim.keymap.set('n', '<leader>fr', fzf.resume, { desc = '[f]ind [r]esume' })
            vim.keymap.set('n', '<leader>f.', fzf.oldfiles, { desc = '[f]ind Recent Files ("." for repeat)' })
            vim.keymap.set('n', '<leader><leader>', fzf.buffers, { desc = '[ ] Find existing buffers' })

            -- Fuzzily find in current buffer
            -- "blines" is the closest equivalent to current_buffer_fuzzy_find (fuzzy match on lines)
            -- You could also use "lgrep_curbuf" for regex search in current buffer
            vim.keymap.set('n', '<leader>ff', function()
                fzf.blines({
                    winopts = {
                        height = 0.5,
                        width = 0.5,
                        preview = { hidden = 'hidden' } -- Dropdown style usually hides preview
                    }
                })
            end, { desc = '[f]uzzily [f]ind in current buffer' })

            -- Find in Open Files
            -- fzf.lines searches content lines across all open buffers
            vim.keymap.set('n', '<leader>f/', fzf.lines, { desc = '[f]ind [/] in Open Files' })

            -- Shortcut for searching your Neovim configuration files
            vim.keymap.set('n', '<leader>fn', function()
                fzf.files({ cwd = vim.fn.stdpath('config') })
            end, { desc = '[f]ind [n]eovim files' })
        end,
    },
}
