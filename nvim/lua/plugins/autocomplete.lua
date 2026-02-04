return {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = '1.*',
    opts = {
        keymap = {
            preset = 'default',
            ['<C-p>'] = { 'select_prev', 'fallback' },
            ['<C-n>'] = { 'select_next', 'fallback' },
            ['<C-e>'] = { 'hide', 'fallback' },
            ['<Tab>'] = { 'accept', 'fallback' },
        },

        appearance = {
            nerd_font_variant = 'mono',
        },

        completion = {
            documentation = { auto_show = true, auto_show_delay_ms = 500 },
            ghost_text = { enabled = true },
        },

        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },

            providers = {
                buffer = {
                    opts = {
                        max_total_buffer_size = 100 * 1024 * 1024, -- 100 MB
                    },
                },
            },
        },
        signature = { enabled = true },
    },
    opts_extend = { 'sources.default' },
}
