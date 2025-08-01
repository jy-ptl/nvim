return {
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'
      local extensions = require 'harpoon.extensions'

      harpoon:setup()
      harpoon:extend(extensions.builtins.highlight_current_file())

      require('telescope').load_extension 'harpoon'

      -- harpoon:extend(extensions.builtins.command_on_nav 'foo bar')
      harpoon:extend(extensions.builtins.navigate_with_number())

      -- Keymaps
      vim.keymap.set('n', '<C-e>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = 'Harpoon Menu' })

      vim.keymap.set('n', '<leader>a', function()
        harpoon:list():add()
      end, { desc = '[A]dd File To Harpoon' })

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set('n', '<C-S-P>', function()
        harpoon:list():prev()
      end)

      vim.keymap.set('n', '<C-S-N>', function()
        harpoon:list():next()
      end)

      -- Telescope keymap
      vim.keymap.set('n', '<leader>hm', '<cmd>Telescope harpoon marks<CR>', { desc = 'Harpoon Marks (Telescope)' })
    end,
  },
}
