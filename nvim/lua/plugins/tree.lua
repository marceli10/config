return {
    {
        'nvim-neo-tree/neo-tree.nvim',
        branch = 'v3.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'MunifTanjim/nui.nvim',
            'nvim-tree/nvim-web-devicons',
        },
        keys = {
            {
                '<C-1>',
                function()
                    require('neo-tree.command').execute { toggle = true }
                end,
                desc = 'Toggle Neo-tree',
            },
        },
        opts = {
            filesystem = {
                follow_current_file = true,
                filtered_items = {
                    visible = true,
                    hide_dotfiles = false,
                    hide_gitignored = false,
                },
            },
            window = {
                mappings = {
                    ['P'] = {
                        'toggle_preview',
                        config = {
                            use_float = false,
                            use_image_nvim = true,
                            use_snacks_image = true,
                            title = 'Neo-tree Preview',
                        },
                    },
                    ['F'] = {
                        function()
                            require('neo-tree.command').execute { source = 'filesystem', action = 'focus' }
                        end,
                        desc = 'Neo-tree: filesystem',
                    },
                    ['G'] = {
                        function()
                            require('neo-tree.command').execute { source = 'git_status', action = 'focus' }
                        end,
                        desc = 'Neo-tree: git status',
                    },
                    ['B'] = {
                        function()
                            require('neo-tree.command').execute { source = 'buffers', action = 'focus' }
                        end,
                        desc = 'Neo-tree: buffers',
                    },
                },
            },
        },
        config = function(_, opts)
            require('neo-tree').setup(opts)

            -- Keep the tree itself fully transparent, like everything else, but
            -- give the cursor row its own solid highlight -- otherwise CursorLine
            -- loses its bg along with Normal and there's no way to tell which
            -- line/file is selected. Pulled from PmenuSel, a group transparent.nvim
            -- never touches.
            local function highlight_cursor_line()
                local text = vim.api.nvim_get_hl(0, { name = 'Normal', link = false }).fg
                local cursor = vim.api.nvim_get_hl(0, { name = 'PmenuSel', link = false }).bg

                vim.api.nvim_set_hl(0, 'NeoTreeCursorLine', { fg = text, bg = cursor, bold = true })
            end

            highlight_cursor_line()
            vim.api.nvim_create_autocmd('ColorScheme', {
                group = vim.api.nvim_create_augroup('neo-tree-solid-bg', { clear = true }),
                callback = highlight_cursor_line,
            })
        end,
        lazy = false,
    },
}
