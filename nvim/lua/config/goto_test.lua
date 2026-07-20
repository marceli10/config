local M = {}

function M.candidates(path)
    local dir = vim.fn.fnamemodify(path, ':h')
    local name = vim.fn.fnamemodify(path, ':t:r')
    local ext = vim.fn.fnamemodify(path, ':e')
    local candidates = {}

    if ext == 'py' then
        local base = name:match '^test_(.+)$' or name:match '^(.+)_test$'
        if base then
            table.insert(candidates, dir .. '/' .. base .. '.py')
            table.insert(candidates, (dir:gsub('/tests$', '/src')) .. '/' .. base .. '.py')
        else
            table.insert(candidates, dir .. '/test_' .. name .. '.py')
            table.insert(candidates, dir .. '/' .. name .. '_test.py')
            table.insert(candidates, (dir:gsub('/src$', '/tests')) .. '/test_' .. name .. '.py')
        end
    elseif vim.tbl_contains({ 'js', 'jsx', 'ts', 'tsx' }, ext) then
        local base = name:match '^(.+)%.test$' or name:match '^(.+)%.spec$'
        if base then
            table.insert(candidates, dir .. '/' .. base .. '.' .. ext)
            table.insert(candidates, (dir:gsub('/__tests__$', '')) .. '/' .. base .. '.' .. ext)
        else
            table.insert(candidates, dir .. '/' .. name .. '.test.' .. ext)
            table.insert(candidates, dir .. '/' .. name .. '.spec.' .. ext)
            table.insert(candidates, dir .. '/__tests__/' .. name .. '.test.' .. ext)
            table.insert(candidates, dir .. '/__tests__/' .. name .. '.spec.' .. ext)
        end
    elseif ext == 'java' then
        local base = name:match '^(.+)Test$'
        if base then
            table.insert(candidates, (dir:gsub('/src/test/', '/src/main/')) .. '/' .. base .. '.java')
        else
            table.insert(candidates, (dir:gsub('/src/main/', '/src/test/')) .. '/' .. name .. 'Test.java')
        end
    end

    return candidates
end

function M.jump()
    local path = vim.api.nvim_buf_get_name(0)
    for _, candidate in ipairs(M.candidates(path)) do
        if vim.fn.filereadable(candidate) == 1 then
            vim.cmd.edit(candidate)
            return
        end
    end
    vim.notify('No corresponding test/source file found', vim.log.levels.WARN)
end

return M
