return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    opts = {
        focus = true,      -- jump straight into the list; you opened it to navigate
        auto_close = true, -- close once the last item is fixed
    },
    keys = {
        {
            "<leader>xx",
            "<cmd>Trouble diagnostics toggle<cr>",
            desc = "Diagnostics (Trouble)",
        },
        {
            "<leader>xX",
            "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
            desc = "Buffer Diagnostics (Trouble)",
        },
        {
            "<leader>xs",
            "<cmd>Trouble symbols toggle focus=false<cr>",
            desc = "Symbols (Trouble)",
        },
        {
            "<leader>xl",
            "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
            desc = "LSP Definitions / references / ... (Trouble)",
        },
        {
            "<leader>xL",
            "<cmd>Trouble loclist toggle<cr>",
            desc = "Location List (Trouble)",
        },
        {
            "<leader>xQ",
            "<cmd>Trouble qflist toggle<cr>",
            desc = "Quickfix List (Trouble)",
        },
        {
            "N",
            function()
                if require("trouble").is_open() then
                    require("trouble").prev { skip_groups = true, jump = true }
                else
                    local ok, err = pcall(vim.cmd.cprev)
                    if not ok then
                        vim.notify(err, vim.log.levels.ERROR)
                    end
                end
            end,
            desc = "Previous Trouble/Quickfix Item",
        },
        {
            "P",
            function()
                if require("trouble").is_open() then
                    require("trouble").next { skip_groups = true, jump = true }
                else
                    local ok, err = pcall(vim.cmd.cnext)
                    if not ok then
                        vim.notify(err, vim.log.levels.ERROR)
                    end
                end
            end,
            desc = "Next Trouble/Quickfix Item",
        },
    },
    config = function(_, opts)
        require("trouble").setup(opts)

        -- jb.nvim's colorscheme script ships its own solid TroubleNormal/
        -- TroubleNormalNC (independent of transparent.nvim, which never heard of
        -- Trouble's own highlight groups), so the window stays opaque even with
        -- transparency on. Re-link back to NormalFloat -- trouble.nvim's own
        -- documented default -- so it tracks the rest of the transparent floats.
        local function keep_trouble_transparent()
            vim.api.nvim_set_hl(0, "TroubleNormal", { link = "NormalFloat" })
            vim.api.nvim_set_hl(0, "TroubleNormalNC", { link = "NormalFloat" })
        end

        keep_trouble_transparent()
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("trouble-transparent-bg", { clear = true }),
            callback = keep_trouble_transparent,
        })
    end,
}
