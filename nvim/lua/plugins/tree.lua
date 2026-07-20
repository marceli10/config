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
                auto_expand_width = true,
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
                    ['Z'] = {
                        function(state)
                            local root = state.path
                            local ignored_dirs = {}
                            local git_root = vim.fn.systemlist({ 'git', '-C', root, 'rev-parse', '--show-toplevel' })[1]
                            if vim.v.shell_error == 0 and git_root then
                                local lines = vim.fn.systemlist {
                                    'git',
                                    '-C',
                                    git_root,
                                    'ls-files',
                                    '--others',
                                    '--ignored',
                                    '--exclude-standard',
                                    '--directory',
                                }
                                for _, line in ipairs(lines) do
                                    if line:sub(-1) == '/' then
                                        table.insert(ignored_dirs, git_root .. '/' .. line:sub(1, -2))
                                    end
                                end
                            end

                            local function is_ignored(path)
                                for _, dir in ipairs(ignored_dirs) do
                                    if path == dir or path:sub(1, #dir + 1) == dir .. '/' then
                                        return true
                                    end
                                end
                                return false
                            end

                            local fs = require 'neo-tree.sources.filesystem'
                            local renderer = require 'neo-tree.ui.renderer'
                            local async = require 'plenary.async'

                            state.explicitly_opened_nodes = state.explicitly_opened_nodes or {}

                            local function expand(node)
                                if is_ignored(node:get_id()) then
                                    return
                                end
                                if fs.prefetcher.should_prefetch(node) then
                                    fs.prefetcher.prefetch(state, node)
                                end
                                if not node:is_expanded() then
                                    node:expand()
                                    state.explicitly_opened_nodes[node:get_id()] = true
                                end
                                for _, child in ipairs(state.tree:get_nodes(node:get_id())) do
                                    if child.type == 'directory' then
                                        expand(child)
                                    end
                                end
                            end

                            async.run(function()
                                for _, root_node in pairs(state.tree:get_nodes()) do
                                    expand(root_node)
                                end
                            end, function()
                                renderer.redraw(state)
                            end)
                        end,
                        desc = 'Expand all (except gitignored)',
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
