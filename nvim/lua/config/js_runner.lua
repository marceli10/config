local M = {}

function M.setup()
    local map = function(lhs, rhs, desc)
        vim.keymap.set('n', lhs, rhs, { buffer = true, desc = desc })
    end

    map('<leader>rr', function()
        local ft = vim.bo.filetype
        if ft == 'typescript' or ft == 'typescriptreact' then
            local runner = vim.fn.executable 'tsx' == 1 and 'tsx' or 'ts-node'
            vim.cmd('!npx ' .. runner .. ' %')
        else
            vim.cmd '!node %'
        end
    end, 'JS/TS: run file')

    map('<leader>rp', '<cmd>!npm run dev<cr>', 'JS/TS: npm run dev')
    map('<leader>rt', '<cmd>!npm test<cr>', 'JS/TS: npm test (raw)')
end

return M
