return {
    'saghen/blink.cmp',
    version = '*',
    event = { 'InsertEnter', 'CmdlineEnter' },
    opts = {
        keymap = {
            preset = 'super-tab',
            ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
            ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        },
        appearance = { nerd_font_variant = 'mono' },
        completion = {
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 0,
                window = { border = 'rounded' },
            },
            ghost_text = { enabled = true },
            menu = {
                border = 'rounded',
                draw = {
                    columns = {
                        { 'kind_icon' },
                        { 'label',      'label_description', gap = 1 },
                        { 'kind' },
                        { 'source_name' },
                    },
                },
            },
            list = { selection = { preselect = true, auto_insert = false } },
        },
        signature = {
            enabled = true,
            window = { border = 'rounded', show_documentation = true },
        },
        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
        },
        snippets = { preset = 'default' },
        fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
}
