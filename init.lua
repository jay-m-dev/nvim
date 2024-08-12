-- init.lua

-- Load packer.nvim
vim.cmd [[packadd packer.nvim]]

-- Set leader key
vim.g.mapleader = ' '

-- Key mappings
vim.api.nvim_set_keymap('n', '<leader>w', ':w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>q', ':q<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><S-Q>', ':qa<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>h', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>j', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>k', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>l', '<C-w>l', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>v', ':vs<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>s', ':sp<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', 'jk', '<ESC>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>r', ':!python3 %<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ts', ':sp<CR>:term<CR>A', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>tv', ':vs<CR>:term<CR>A', { noremap = true, silent = true })

-- Set options
vim.o.number = true         -- Show line numbers
vim.o.relativenumber = true -- Show relative numbers
vim.o.expandtab = true      -- Use spaces instead of tabs
vim.o.shiftwidth = 4        -- Number of spaces for indentation
vim.o.tabstop = 4           -- Number of spaces per tab
vim.o.softtabstop = 4       -- Number of spaces per tab in insert mode
vim.o.ignorecase = true     -- Ignore case when searching
vim.o.clipboard = "unnamedplus"
vim.o.cursorline = true
vim.o.colorcolumn = "80"
vim.cmd([[highlight ColorColumn ctermbg=234 guibg=#2e3436]])
vim.cmd([[highlight CursorLine cterm=NONE ctermbg=236 guibg=#444444]])

-- Function to set options for specific file types
local function set_tab_width(filetype, shiftwidth, tabstop, softtabstop)
    vim.api.nvim_create_autocmd("FileType", {
        pattern = filetype,
        callback = function()
            vim.bo.shiftwidth = shiftwidth
            vim.bo.tabstop = tabstop
            vim.bo.softtabstop = softtabstop
        end
    })
end

-- Set tab width for JavaScript and ReactJS files
set_tab_width("javascript", 2, 2, 2)
set_tab_width("javascriptreact", 2, 2, 2)
set_tab_width("typescript", 2, 2, 2)
set_tab_width("typescriptreact", 2, 2, 2)

-- Set tab width for JavaScript and ReactJS files
set_tab_width("python", 4, 4, 4)

-- Key mappings for navigating and displaying diagnostics
vim.api.nvim_set_keymap('n', '<Leader>cd', '<cmd>Lspsaga show_line_diagnostics<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '[e', '<cmd>Lspsaga diagnostic_jump_prev<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ']e', '<cmd>Lspsaga diagnostic_jump_next<CR>', { noremap = true, silent = true })

-- Show diagnostics in a floating window on hover
vim.cmd [[
  autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]]

-- Initialize packer
require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use 'neovim/nvim-lspconfig'
  use 'glepnir/lspsaga.nvim'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/vim-vsnip'
  use 'hrsh7th/cmp-vsnip'
  use {
      'nvim-telescope/telescope.nvim',
      requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- Add Comment.nvim plugin
  use {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end
  }

  -- use {
  --   'iamcco/markdown-preview.nvim',
  --   run = 'cd app && npm install',
  --   setup = function() vim.g.mkdp_filetypes = { "markdown" } end,
  --   ft = { "markdown" },
  -- }

  use {
      'iamcco/markdown-preview.nvim',
      run = function() vim.fn["mkdp#util#install"]() end,
      setup = function()
          vim.g.mkdp_filetypes = { "markdown" }
          vim.g.mkdp_auto_start = 0
          vim.g.mkdp_auto_close = 1
          vim.g.mkdp_browser = ''  -- Leave empty for default browser or specify your preferred browser
      end,
      ft = { "markdown" },
  }

  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

end)

-- nvim-cmp setup
local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
  }
})

-- lspconfig
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()
lspconfig.pyright.setup {
  capabilities = capabilities,
}

-- Keybinding for hover documentation
vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })

require('lspsaga').setup({})

-- Example of customizing diagnostic display
vim.diagnostic.config({
  virtual_text = {
    prefix = '●', -- Could be '■', '▎', 'x'
    source = 'always', -- Or 'if_many'
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

require('telescope').setup{
  extensions = {
    lsp_handlers = {
      -- disable telescope diagnostics handler
      disable = { "diagnostics" }
    }
  }
}

vim.api.nvim_set_keymap('n', '<Leader>dd', '<cmd>Telescope diagnostics<CR>', { noremap = true, silent = true })
-- Key mappings for Markdown preview
vim.api.nvim_set_keymap('n', '<Leader>mp', ':MarkdownPreview<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>ms', ':MarkdownPreviewStop<CR>', { noremap = true, silent = true })

-- Disable the Perl provider
vim.g.loaded_perl_provider = 0

-- Custom colors for nvimdiff with Solarized Dark theme
-- vim.cmd [[
--   highlight DiffAdd    ctermbg=22 guibg=#073642
--   highlight DiffChange ctermbg=24 guibg=#002b36
--   highlight DiffDelete ctermbg=52 guibg=#073642
--   highlight DiffText   ctermbg=94 guibg=#586e75
-- ]]
-- Colors for nvimdiff with Tango Dark
vim.cmd [[
  highlight DiffAdd    ctermbg=28 guibg=#346604
  highlight DiffChange ctermbg=39 guibg=#204a87
  highlight DiffDelete ctermbg=52 guibg=#a40000
  highlight DiffText   ctermbg=58 guibg=#5c3566
]]


vim.g.mkdp_browser = 'firefox'

-- Key mappings for Telescope file finder
vim.api.nvim_set_keymap('n', '<Leader>ff', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>fg', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>fb', '<cmd>Telescope buffers<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>fh', '<cmd>Telescope help_tags<CR>', { noremap = true, silent = true })
