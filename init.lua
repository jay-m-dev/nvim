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
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<CR>", desc = "Open LazyGit" },
    },
  },
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {}
    end,
  },
  {
    "echasnovski/mini.icons",
    version = false,
    config = function()
      require("mini.icons").setup()
    end,
  },
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    opts = {},
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
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = {
          "lua", "python", "typescript", "tsx", "json", "markdown"
        },
        highlight = { enable = true },
      }
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
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      show_help = "yes",
      -- model = "claude-sonnet-4"
    },
  },
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require"octo".setup()
    end,
    cmd = "Octo",
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup()
    end,
  },
})

-- WSL Clipboard Fix
if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = 0,
  }
end


-- Paste from system clipboard with \r stripped
vim.keymap.set("n", "<leader>p", function()
  local ok, text = pcall(vim.fn.getreg, "+")
  if ok and type(text) == "string" then
    vim.fn.setreg("+", text:gsub("\r", ""))
    vim.cmd('normal! "+p')
  else
    vim.notify("Clipboard read failed", vim.log.levels.WARN)
  end
end, { desc = "Paste + register with \\r stripped" })

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
map('n', '<leader>Q', ':qa<CR>', opts)
map('n', '<leader>h', '<C-w>h', opts)
map('n', '<leader>j', '<C-w>j', opts)
map('n', '<leader>k', '<C-w>k', opts)
map('n', '<leader>l', '<C-w>l', opts)
map('n', '<leader>v', ':vs<CR>', opts)
map('n', '<leader>s', ':sp<CR>', opts)
map('i', 'jk', '<ESC>', opts)
vim.keymap.set("n", "<leader>r", function()
  vim.cmd("%delete _")        -- delete all lines, avoid polluting registers
  vim.cmd("normal! ggP")   -- paste from + (system clipboard) at top
end, { desc = "Replace file with + register" })
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

vim.keymap.set('n', '<Leader>gw', function()
  vim.fn.feedkeys(':GptWrap ', 'n')
end, { desc = 'Prompt :GptWrap' })

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

-- -- Which-Key descriptions
-- local wk = require("which-key")
-- wk.register({
--   { "<leader>cc", desc = "Copilot Chat toggle" },
--   { "<leader>ce", desc = "Copilot Chat explain code" },
--   { "<leader>dd", desc = "Diagnostics" },
--   { "<leader>fb", desc = "Buffers" },
--   { "<leader>ff", desc = "Find files" },
--   { "<leader>fg", desc = "Live grep" },
--   { "<leader>fh", desc = "Help tags" },
--   { "<leader>h", desc = "Window left" },
--   { "<leader>j", desc = "Window down" },
--   { "<leader>k", desc = "Window up" },
--   { "<leader>l", desc = "Window right" },
--   { "<leader>mp", desc = "Markdown preview start" },
--   { "<leader>ms", desc = "Markdown preview stop" },
--   { "<leader>mt", desc = "Markview toggle" },
--   { "<leader>p", desc = "Paste from + (strip \\r)" },
--   { "<leader>q", desc = "Quit" },
--   { "<leader>r", desc = "Run python file" },
--   { "<leader>s", desc = "Horizontal split" },
--   { "<leader>ts", desc = "Terminal horizontal split" },
--   { "<leader>tv", desc = "Terminal vertical split" },
--   { "<leader>v", desc = "Vertical split" },
--   { "<leader>w", desc = "Save file" },
-- })

vim.keymap.set('t', 'jk', '<C-\\><C-n>', { noremap = true })

vim.g.python3_host_prog = vim.fn.expand("~/.venvs/nvim/bin/python")

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "octo", "octo_issue", "octo_pr" },
  callback = function()
    local opts = { buffer = true, noremap = true, silent = true }
    vim.keymap.set("n", "e", "<cmd>OctoEdit<CR>", opts)
  end,
})

vim.api.nvim_create_user_command("GptWrap", function(opts)
  local args = opts.fargs
  if #args == 0 then
    args = { vim.fn.expand("%:p") }
  end
  vim.fn.jobstart(vim.list_extend({ "gptwrap" }, args), { detach = true })
end, {
  nargs = "*",
  complete = "file",
  desc = "Wrap file(s) in triple backticks and open ChatGPT"
})

vim.keymap.set("n", "<leader>cc", ":CopilotChatToggle<CR>", { desc = "Toggle Copilot Chat" })
vim.keymap.set("v", "<leader>ce", ":CopilotChatExplain<CR>", { desc = "Explain selection" })
vim.keymap.set("v", "<leader>cf", ":CopilotChatFix<CR>", { desc = "Fix selection" })
vim.keymap.set("v", "<leader>ct", ":CopilotChatTests<CR>", { desc = "Generate tests" })

vim.keymap.set("n", "<leader>e", ":Vex<CR>", { desc = "Vertical Explorer" })
vim.keymap.set('n', '<CR>', 'o<Esc>k', { noremap = true, silent = true })     -- line below
vim.keymap.set('n', '<leader><CR>', 'O<Esc>j', { noremap = true, silent = true })   -- line above

