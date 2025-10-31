  return { 
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
        register = {
            ['<leader>/'] = {name = "Comments", _ = 'which_key_ignore'},
            ['<leader>g'] = { name = '[G]ode', _ = 'which_key_ignore' },
            ['<leader>d'] = {name = '[D]ebug' , _ = 'which_key_ignore' },
            ['<leader>f'] = { name = '[F]ind', _ = 'which_key_ignore' },
            ['<leader>w'] = {name = '[W]indow', _ = 'which_key_ignore'}
        }
    }
  }
