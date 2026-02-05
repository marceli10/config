require 'remap'
require 'config.lazy'

-- theme setup
vim.opt.guicursor = 'n-v-c-sm:block-Cursor,i:ver25-Cursor,r-cr-o:hor20-Cursor'
vim.api.nvim_set_hl(0, 'Cursor', { bg = '#000000' })
