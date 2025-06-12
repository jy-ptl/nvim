return {
  'nvim-tree/nvim-tree.lua',
  dependencies = {
    'nvim-tree/nvim-web-devicons', -- optional, for file icons
  },
  lazy = false,
  keys = {
    { '\\', ':NvimTreeToggle<CR>', desc = 'Toggle NvimTree', silent = true },
  },
  config = function()
    require('nvim-tree').setup {
      view = {
        width = 30,
        side = 'left',
        relativenumber = true,
      },
      renderer = {
        group_empty = true,
        highlight_git = true,
        icons = {
          show = {
            git = true,
            folder = true,
            file = true,
            folder_arrow = true,
          },
        },
      },
      filters = {
        dotfiles = false,
        git_clean = false,
      },
      git = {
        enable = true,
        ignore = false,
      },
    }
  end,
}
