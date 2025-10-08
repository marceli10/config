return {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        require('nvim-tree').setup {
            hijack_netrw = true,
            auto_reload_on_write = true,
            view = {
                adaptive_size = true,
            },
            git = {
                enable = true,
            },
            filters = {
                dotfiles = false,
            },
            renderer = {
                icons = {
                    webdev_colors = true, -- enable filetype icon colors
                    git_placement = 'after', -- or "before"
                    show = {
                        file = true,
                        folder = true,
                        folder_arrow = true,
                        git = true,
                        dotfiles = true
                    },
                    glyphs = {
                        default = '', -- fallback icon
                        symlink = '',
                        bookmark = '',
                        folder = {
                            arrow_closed = '',
                            arrow_open = '',
                            default = '',
                            open = '',
                            empty = '',
                            empty_open = '',
                            symlink = '',
                        },
                        git = {
                            unstaged = '✗',
                            staged = '✓',
                            unmerged = '',
                            renamed = '➜',
                            deleted = '',
                            untracked = '★',
                            ignored = '◌',
                        },
                    },
                },
            },
        }

        vim.api.nvim_create_autocmd("BufEnter", {
            nested = true,
            callback = function()
                if (vim.fn.bufname() == "NvimTree_1") then return end

                require("nvim-tree.api").tree.find_file({ buf = vim.fn.bufnr() })
            end,
        })

        vim.keymap.set('n', '<C-1>', ':NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })
    end,
}
