local function has(file)
    return vim.uv.fs_stat(vim.fs.joinpath(vim.fn.getcwd(), file)) ~= nil
end

local map = function(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, { buffer = true, desc = desc })
end

map('<leader>rr', function()
    if has 'gradlew' then
        vim.cmd '!./gradlew run'
    elseif has 'mvnw' then
        vim.cmd '!./mvnw compile exec:java'
    elseif has 'pom.xml' then
        vim.cmd '!mvn compile exec:java'
    else
        vim.cmd '!gradle run'
    end
end, 'Java: run')

map('<leader>rb', function()
    if has 'gradlew' then
        vim.cmd '!./gradlew build'
    elseif has 'mvnw' then
        vim.cmd '!./mvnw package'
    else
        vim.cmd '!mvn package'
    end
end, 'Java: build')
