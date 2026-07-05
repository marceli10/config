return {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
        presets = {
            -- Rounded border around K hover docs + signature help (uses theme FloatBorder color).
            lsp_doc_border = true,
        },
    },
    -- C-d / C-u scroll the K hover (and signature) popup when one is open; otherwise fall
    -- back to the normal half-page scroll. blink owns C-d/C-u in insert mode, so this is normal mode only.
    keys = {
        {
            "<C-d>",
            function()
                if not require("noice.lsp").scroll(4) then
                    return "<C-d>"
                end
            end,
            mode = "n",
            silent = true,
            expr = true,
            desc = "Scroll hover docs down",
        },
        {
            "<C-u>",
            function()
                if not require("noice.lsp").scroll(-4) then
                    return "<C-u>"
                end
            end,
            mode = "n",
            silent = true,
            expr = true,
            desc = "Scroll hover docs up",
        },
    },
    dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
    }
}
