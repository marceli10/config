local map = function(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, { buffer = true, desc = desc })
end

map('<leader>rr', '<cmd>!zig run %<cr>', 'Zig: run file')
map('<leader>rb', '<cmd>!zig build run<cr>', 'Zig: build run')
map('<leader>rB', '<cmd>!zig build<cr>', 'Zig: build')
map('<leader>rt', '<cmd>!zig test %<cr>', 'Zig: test file (raw)')
map('<leader>rc', '<cmd>!zig build test<cr>', 'Zig: build test')
