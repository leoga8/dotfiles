-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

---@module 'lazy'
---@type LazySpec
-- return {}
return {
  -- lazygit
  {
    'kdheepak/lazygit.nvim',
    lazy = true,
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>lg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
    },
  },

  -- theme
  {
    'marko-cerovac/material.nvim',
    priority = 1000, -- load before other plugins
    config = function()
      vim.g.material_style = 'darker' -- or: deep ocean, oceanic, palenight, lighter
      require('material').setup()
      vim.cmd 'colorscheme material'
    end,
  },

  -- opencode
  {
    'nickjvandyke/opencode.nvim',
    version = '*',
    dependencies = {
      {
        'folke/snacks.nvim',
        optional = true,
        opts = {
          input = {},
          picker = {
            actions = {
              opencode_send = function(...) return require('opencode').snacks_picker_send(...) end,
            },
            win = {
              input = {
                keys = {
                  ['<a-a>'] = { 'opencode_send', mode = { 'n', 'i' } },
                },
              },
            },
          },
        },
      },
    },
    config = function()
      vim.g.opencode_opts = {}
      vim.o.autoread = true

      vim.keymap.set({ 'n', 'x' }, '<C-a>', function() require('opencode').ask('@this: ', { submit = true }) end, { desc = 'Ask opencode' })
      vim.keymap.set({ 'n', 'x' }, '<C-x>', function() require('opencode').select() end, { desc = 'opencode select' })
      vim.keymap.set({ 'n', 't' }, '<C-.>', function() require('opencode').toggle() end, { desc = 'opencode toggle' })
      vim.keymap.set({ 'n', 'x' }, 'go', function() return require('opencode').operator '@this: ' end, { desc = 'opencode operator' })
      vim.keymap.set('n', 'goo', function() return require('opencode').operator '@this: ' end, { desc = 'opencode operator (line)' })
      vim.keymap.set('n', '<S-C-u>', function() require('opencode').command 'session.half.page.up' end, { desc = 'opencode scroll up' })
      vim.keymap.set('n', '<S-C-d>', function() require('opencode').command 'session.half.page.down' end, { desc = 'opencode scroll down' })
      -- optional: prevent C-a/C-x from incrementing/decrementing numbers
      vim.keymap.set('n', '+', '<C-a>', { desc = 'Increment under cursor', noremap = true })
      vim.keymap.set('n', '-', '<C-x>', { desc = 'Decrement under cursor', noremap = true })
    end,
  },

  -- vim-sneak
  {
    'justinmk/vim-sneak',
    init = function()
      vim.g['sneak#label'] = 1 -- label-mode (EasyMotion-style jump labels)
    end,
    config = function()
      vim.keymap.set({ 'n', 'x', 'o' }, 'gs', '<Plug>Sneak_s', { desc = 'Sneak forward' })
      vim.keymap.set({ 'n', 'x', 'o' }, 'gS', '<Plug>Sneak_S', { desc = 'Sneak backward' })
    end,
  },

  -- snacks dashboard override
  {
    'folke/snacks.nvim',
    opts = {
      picker = {
        sources = {
          files = {
            cmd = 'fd',
            args = { '--type', 'f', '--type', 'l', '--color', 'never', '-E', '.git', '--hidden' },
          },
        },
      },
      dashboard = {
        sections = {
          {
            section = 'terminal',
            cmd = 'chafa ~/.config/nvim/mate-open.png --format symbols --symbols vhalf --size 60x17 --stretch; sleep .1',
            height = 17,
            padding = 1,
          },
          {
            pane = 2,
            { section = 'keys', gap = 1, padding = 1 },
            { section = 'startup' },
          },
        },
      },
    },
  },
}
