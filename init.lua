
-- File: /home/moranj3/.config/nvim/init.lua

-- Leader and colors
vim.g.mapleader = ' '
vim.o.termguicolors = true
-- vim.o.smartindent
vim.o.cindent = true

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git","clone","--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  -- Completion
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/vim-vsnip",
  "hrsh7th/cmp-vsnip",

  -- Theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        integrations = {
          cmp = true, gitsigns = true, treesitter = true,
          telescope = true, which_key = true, markdown = true,
          indent_blankline = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Git / UI / Utils
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = { { "<leader>gg", "<cmd>LazyGit<CR>" } },
  },
  { "folke/which-key.nvim",
    config = function() require("which-key").setup({}) end },
  { "echasnovski/mini.icons", version = false,
    config = function() require("mini.icons").setup() end },
  { "nvim-tree/nvim-web-devicons", lazy = true, opts = {} },
  {
    "glepnir/lspsaga.nvim",
    event = "LspAttach",
    config = function() require("lspsaga").setup({}) end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  { "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" } },
  { "numToStr/Comment.nvim",
    config = function() require("Comment").setup() end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua","python","typescript","tsx","json","markdown"
        },
        highlight = { enable = true },
      })
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
          markdown = true, help = true, gitcommit = true,
        },
      })
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, { "nvim-lua/plenary.nvim" },
    },
    opts = { show_help = "yes" },
  },
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim","nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function() require("octo").setup() end,
    cmd = "Octo",
  },
  { "lewis6991/gitsigns.nvim",
    config = function() require("gitsigns").setup() end },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({ options = { theme = "catppuccin" } })
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({
        "*", css = { rgb_fn = true }, html = { names = true }
      })
    end,
  },

  -- LSP (0.11 API usage + installers)
  "neovim/nvim-lspconfig",
  "williamboman/mason.nvim",
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright","ts_ls","html","cssls","jsonls" },
        automatic_installation = true,
      })
    end,
  },

  -- DAP core + UI + deps
  "mfussenegger/nvim-dap",
  { "nvim-neotest/nvim-nio" },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap","nvim-neotest/nvim-nio" },
  },
  { "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" } },

  -- DAP adapters via mason
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim","mfussenegger/nvim-dap" },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "debugpy","js-debug-adapter" },
        automatic_installation = true,
      })
    end,
  },

  -- Python DAP helper
  { "mfussenegger/nvim-dap-python" },

  -- JS/TS/React via vscode-js-debug
  {
    "mxsdev/nvim-dap-vscode-js",
    dependencies = { "mfussenegger/nvim-dap" },
  },
})

-- WSL clipboard
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

-- Paste + strip \r
vim.keymap.set("n","<leader>p",function()
  local ok,text = pcall(vim.fn.getreg,"+")
  if ok and type(text)=="string" then
    vim.fn.setreg("+", text:gsub("\r",""))
    vim.cmd('normal! "+p')
  else
    vim.notify("Clipboard read failed", vim.log.levels.WARN)
  end
end,{ desc = "Paste + (strip \\r)" })

-- Editor opts
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.ignorecase = true
vim.o.clipboard = "unnamedplus"
vim.o.cursorline = true
vim.o.colorcolumn = "80"
vim.cmd([[
  highlight ColorColumn ctermbg=234 guibg=#2e3436
  highlight CursorLine cterm=NONE ctermbg=236 guibg=#444444
]])

-- Tabs by filetype
local function set_tab_width(ft,s,t,st)
  vim.api.nvim_create_autocmd("FileType",{
    pattern = ft,
    callback = function()
      vim.bo.shiftwidth = s
      vim.bo.tabstop = t
      vim.bo.softtabstop = st
    end
  })
end
set_tab_width("javascript",2,2,2)
set_tab_width("javascriptreact",2,2,2)
set_tab_width("typescript",2,2,2)
set_tab_width("typescriptreact",2,2,2)
set_tab_width("python",4,4,4)

-- Keymaps
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
map('n','<leader>w',':w<CR>',opts)
map('n','<leader>q',':q<CR>',opts)
map('n','<leader>Q',':qa<CR>',opts)
map('n','<leader>h','<C-w>h',opts)
map('n','<leader>j','<C-w>j',opts)
map('n','<leader>k','<C-w>k',opts)
map('n','<leader>l','<C-w>l',opts)
map('n','<leader>v',':vs<CR>',opts)
map('n','<leader>s',':sp<CR>',opts)
map('i','jk','<ESC>',opts)
vim.keymap.set("n","<leader>r",function()
  vim.cmd("%delete _"); vim.cmd("normal! ggP")
end,{ desc = "Replace file with + register" })
map('n','<leader>ts',':sp<CR>:term<CR>A',opts)
map('n','<leader>tv',':vs<CR>:term<CR>A',opts)
map('n','<Leader>cd','<cmd>Lspsaga show_line_diagnostics<CR>',opts)
map('n','[e','<cmd>Lspsaga diagnostic_jump_prev<CR>',opts)
map('n',']e','<cmd>Lspsaga diagnostic_jump_next<CR>',opts)
map('n','K','<cmd>lua vim.lsp.buf.hover()<CR>',opts)
map('n','<Leader>ff','<cmd>Telescope find_files<CR>',opts)
map('n','<Leader>fg','<cmd>Telescope live_grep<CR>',opts)
map('n','<Leader>fs','<cmd>Telescope grep_string<CR>',opts)
map('n','<Leader>fq','<cmd>Telescope quickfix<CR>',opts)
map('n','<Leader>fr','<cmd>Telescope resume<CR>',opts)
map('n','<Leader>fb','<cmd>Telescope buffers<CR>',opts)
map('n','<Leader>fh','<cmd>Telescope help_tags<CR>',opts)
map('n','<Leader>dd','<cmd>Telescope diagnostics<CR>',opts)
vim.keymap.set('n','<Leader>gw',function()
  vim.fn.feedkeys(':GptWrap ','n')
end,{ desc = 'Prompt :GptWrap' })

-- Diagnostic float
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil,{ focusable=false })
  end,
})

-- Diagnostic config
vim.diagnostic.config({
  virtual_text = { prefix = '', source = 'always' },
  signs = true, underline = true, update_in_insert = false,
  severity_sort = true,
})

-- nvim-cmp
local cmp = require("cmp")
cmp.setup({
  snippet = { expand = function(a) vim.fn["vsnip#anonymous"](a.body) end },
  mapping = {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = { { name = 'nvim_lsp' }, { name = 'vsnip' } }
})

-- LSP (Neovim 0.11+ API)
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local function roots()
  return vim.fs.root(0, {
    "pyproject.toml","setup.py","package.json",".git"
  })
end
vim.lsp.config("pyright", { capabilities = capabilities, root_dir = roots })
vim.lsp.config("ts_ls",   { capabilities = capabilities, root_dir = roots })
vim.lsp.config("html",    { capabilities = capabilities, root_dir = roots })
vim.lsp.config("cssls",   { capabilities = capabilities, root_dir = roots })
vim.lsp.config("jsonls",  { capabilities = capabilities, root_dir = roots })
vim.lsp.enable("pyright")
vim.lsp.enable("ts_ls")
vim.lsp.enable("html")
vim.lsp.enable("cssls")
vim.lsp.enable("jsonls")

-- Providers
vim.g.loaded_perl_provider = 0

-- Diff colors
vim.cmd([[
  highlight DiffAdd ctermbg=28 guibg=#346604
  highlight DiffChange ctermbg=39 guibg=#204a87
  highlight DiffDelete ctermbg=52 guibg=#a40000
  highlight DiffText ctermbg=58 guibg=#5c3566
]])

-- Terminal esc
vim.keymap.set('t','jk','<C-\\><C-n>',{ noremap = true })

-- Python host
vim.g.python3_host_prog = vim.fn.expand("~/.venvs/nvim/bin/python")

-- Octo tweak
vim.api.nvim_create_autocmd("FileType",{
  pattern = { "octo","octo_issue","octo_pr" },
  callback = function()
    local b = { buffer = true, noremap = true, silent = true }
    vim.keymap.set("n","e","<cmd>OctoEdit<CR>",b)
  end,
})

-- GptWrap
vim.api.nvim_create_user_command("GptWrap",function(o)
  local a = o.fargs; if #a==0 then a={vim.fn.expand("%:p")} end
  vim.fn.jobstart(vim.list_extend({ "gptwrap" }, a), { detach = true })
end,{ nargs="*", complete="file",
     desc="Wrap file(s) and open ChatGPT" })

-- CopilotChat maps
vim.keymap.set("n","<leader>cc",":CopilotChatToggle<CR>",
  { desc="Toggle Copilot Chat" })
vim.keymap.set("v","<leader>ce",":CopilotChatExplain<CR>",
  { desc="Explain selection" })
vim.keymap.set("v","<leader>cf",":CopilotChatFix<CR>",
  { desc="Fix selection" })
vim.keymap.set("v","<leader>ct",":CopilotChatTests<CR>",
  { desc="Generate tests" })

vim.keymap.set("n","<leader>e",":Vex<CR>",{ desc="Vertical Explorer" })
vim.keymap.set('n','<CR>','o<Esc>k',{ noremap=true, silent=true })
vim.keymap.set('n','<leader><CR>','O<Esc>j',
  { noremap=true, silent=true })

-- Quickfix
vim.api.nvim_create_autocmd("FileType",{
  pattern="qf",
  callback=function(a)
    local b={ buffer=a.buf, noremap=true, silent=true }
    vim.keymap.set("n","<CR>","<CR>",b)
  end,
})
vim.keymap.set("n","<leader>n",":cnext<CR>",
  { noremap=true, silent=true })
vim.keymap.set("n","<leader>p",":cprev<CR>",
  { noremap=true, silent=true })
vim.keymap.set("n","<leader>co",":copen<CR>",
  { noremap=true, silent=true })

-- ================
-- DAP configuration
-- ================
local dap = require("dap")
local dapui = require("dapui")
require("nvim-dap-virtual-text").setup()
dapui.setup({
  layouts = {
    { elements = { "scopes","breakpoints","stacks" },
      size = 40, position="left" },
    { elements = { "repl","console" },
      size = 10, position="bottom" },
  },
})
dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui"] =
  function() dapui.close() end
dap.listeners.before.event_exited["dapui"] =
  function() dapui.close() end

-- DAP keymaps
local dm = { noremap = true, silent = true }
vim.keymap.set("n","<F5>",function() dap.continue() end,dm)
vim.keymap.set("n","<F10>",function() dap.step_over() end,dm)
vim.keymap.set("n","<F11>",function() dap.step_into() end,dm)
vim.keymap.set("n","<F12>",function() dap.step_out() end,dm)
vim.keymap.set("n","<leader>db",function() dap.toggle_breakpoint() end,dm)
vim.keymap.set("n","<leader>dB",function()
  dap.set_breakpoint(vim.fn.input("Breakpoint cond: "))
end,dm)
vim.keymap.set("n","<leader>dr",function() dap.repl.toggle() end,dm)
vim.keymap.set("n","<leader>du",function() dapui.toggle() end,dm)
vim.keymap.set("n","<leader>dl",function() dap.run_last() end,dm)

-- Python DAP (debugpy via Mason)
local ok_py, dappy = pcall(require,"dap-python")
if ok_py then
  local mason = vim.fn.stdpath("data")..
    "/mason/packages/debugpy/venv/bin/python"
  dappy.setup(mason)
end

-- Python attach preset (debugpy 5678)
dap.configurations.python = dap.configurations.python or {}
table.insert(dap.configurations.python, {
  type = "python",
  request = "attach",
  name = "Attach (debugpy 5678)",
  connect = { host = "127.0.0.1", port = 5678 },
  justMyCode = false,
})

-- JS/TS/React: vscode-js-debug via Mason
local ok_js, js = pcall(require,"dap-vscode-js")
if ok_js then
  local js_path = vim.fn.stdpath("data").."/mason/packages/js-debug-adapter"
  js.setup({
    node_path = "node",
    debugger_path = js_path,
    adapters = { "pwa-node","pwa-chrome","pwa-firefox","node-terminal" },
  })
  for _,lang in ipairs({
    "typescript","javascript","typescriptreact","javascriptreact"
  }) do
    dap.configurations[lang] = {
      {
        type = "pwa-node",
        request = "attach",
        name = "Attach (node)",
        processId = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
      },
      {
        type = "pwa-chrome",
        request = "launch",
        name = "Chrome Vite (5173)",
        url = "http://localhost:5173",
        webRoot = "${workspaceFolder}",
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Node file",
        program = "${file}",
        cwd = "${workspaceFolder}",
        runtimeExecutable = "node",
        sourceMaps = true,
        skipFiles = { "<node_internals>/**" },
      },
    }
  end
end
