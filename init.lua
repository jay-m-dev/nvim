-- Set leader key early
vim.g.mapleader = ' '

-- Load lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin setup
require("lazy").setup({
  "neovim/nvim-lspconfig",
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/vim-vsnip",
  "hrsh7th/cmp-vsnip",
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {}
    end,
  },
  {
    "glepnir/lspsaga.nvim",
    event = "LspAttach",
    config = function() require("lspsaga").setup({}) end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  {
    "numToStr/Comment.nvim",
    config = function() require("Comment").setup() end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = true,
    event = { "BufRead", "BufNewFile" },
    build = ":TSUpdate"
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = true,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "markdown" },
    config = function()
      require("markview").setup({ markdown = { enable = true } })
      vim.keymap.set("n", "<leader>mt", "<cmd>Markview toggle<CR>")
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = true },
        panel = { enabled = false },
        filetypes = {
          markdown = true,
          help = true,
          gitcommit = true,
        },
      })
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary", -- use 'main' if you want stable
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- required
      { "nvim-lua/plenary.nvim" },  -- required
    },
    opts = {
      show_help = "yes",
    },
    keys = {
      { "<leader>cc", function() require("CopilotChat").toggle() end, desc = "Toggle Copilot Chat" },
      { "<leader>ce", function() require("CopilotChat").ask("Explain this code") end, desc = "Explain Code" },
    },
  }
})

-- Editor Options
vim.o.number = true
vim.o.relativenumber = true
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.ignorecase = true
vim.o.clipboard = "unnamedplus"
vim.o.cursorline = true
vim.o.colorcolumn = "80"

vim.cmd [[
  highlight ColorColumn ctermbg=234 guibg=#2e3436
  highlight CursorLine cterm=NONE ctermbg=236 guibg=#444444
]]

-- Tab settings by filetype
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

set_tab_width("javascript", 2, 2, 2)
set_tab_width("javascriptreact", 2, 2, 2)
set_tab_width("typescript", 2, 2, 2)
set_tab_width("typescriptreact", 2, 2, 2)
set_tab_width("python", 4, 4, 4)

-- Keymaps
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map('n', '<leader>w', ':w<CR>', opts)
map('n', '<leader>q', ':q<CR>', opts)
map('n', '<leader><S-Q>', ':qa<CR>', opts)
map('n', '<leader>h', '<C-w>h', opts)
map('n', '<leader>j', '<C-w>j', opts)
map('n', '<leader>k', '<C-w>k', opts)
map('n', '<leader>l', '<C-w>l', opts)
map('n', '<leader>v', ':vs<CR>', opts)
map('n', '<leader>s', ':sp<CR>', opts)
map('i', 'jk', '<ESC>', opts)
map('n', '<leader>r', ':!python3 %<CR>', opts)
map('n', '<leader>ts', ':sp<CR>:term<CR>A', opts)
map('n', '<leader>tv', ':vs<CR>:term<CR>A', opts)

map('n', '<Leader>cd', '<cmd>Lspsaga show_line_diagnostics<CR>', opts)
map('n', '[e', '<cmd>Lspsaga diagnostic_jump_prev<CR>', opts)
map('n', ']e', '<cmd>Lspsaga diagnostic_jump_next<CR>', opts)
map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)

map('n', '<Leader>mp', ':MarkdownPreview<CR>', opts)
map('n', '<Leader>ms', ':MarkdownPreviewStop<CR>', opts)

map('n', '<Leader>ff', '<cmd>Telescope find_files<CR>', opts)
map('n', '<Leader>fg', '<cmd>Telescope live_grep<CR>', opts)
map('n', '<Leader>fb', '<cmd>Telescope buffers<CR>', opts)
map('n', '<Leader>fh', '<cmd>Telescope help_tags<CR>', opts)
map('n', '<Leader>dd', '<cmd>Telescope diagnostics<CR>', opts)

-- Diagnostic float on hover
vim.cmd [[
  autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]]

-- Diagnostic config
vim.diagnostic.config({
  virtual_text = { prefix = '●', source = 'always' },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- nvim-cmp
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
lspconfig.pyright.setup { capabilities = capabilities }

-- Disable Perl provider
vim.g.loaded_perl_provider = 0

-- Diff colors (Tango)
vim.cmd [[
  highlight DiffAdd    ctermbg=28 guibg=#346604
  highlight DiffChange ctermbg=39 guibg=#204a87
  highlight DiffDelete ctermbg=52 guibg=#a40000
  highlight DiffText   ctermbg=58 guibg=#5c3566
]]

local wk = require("which-key")

wk.register({
  ["<leader>"] = {
    w = "Save file",
    q = "Quit",
    ["<S-Q>"] = "Quit all",
    h = "Window left",
    j = "Window down",
    k = "Window up",
    l = "Window right",
    v = "Vertical split",
    s = "Horizontal split",
    r = "Run python file",
    ts = "Terminal horizontal split",
    tv = "Terminal vertical split",
    mp = "Markdown preview start",
    ms = "Markdown preview stop",
    ff = "Find files",
    fg = "Live grep",
    fb = "Buffers",
    fh = "Help tags",
    dd = "Diagnostics",
    cc = "Copilot Chat toggle",
    cq = "Copilot Chat explain code",
    mt = "Markview toggle",
  }
})

vim.keymap.set('t', 'jk', '<C-\\><C-n>', { noremap = true })

