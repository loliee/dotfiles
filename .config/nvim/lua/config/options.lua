-- Set <coma> as the leader key
-- See `:help mapleader`
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Explicitly activate editorconfig
vim.g.editorconfig = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 250

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = false
vim.opt.listchars = { tab = "▸ ", space = "␣", eol = "¬" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Configure cursor
vim.opt.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver25-Cursor,r-cr:hor20"

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Disable vim mouse mode, useless and mess with terminal yanking
vim.opt.mouse = ""

-- Vim files
local XDG_DATA_HOME = os.getenv("XDG_DATA_HOME")
vim.opt.swapfile = true
vim.opt.backup = true
vim.opt.undofile = true
vim.opt.directory = XDG_DATA_HOME .. "/nvim/swap//"
vim.opt.backupdir = XDG_DATA_HOME .. "/nvim/backup//"
vim.opt.undodir = XDG_DATA_HOME .. "/nvim/undo//"

-- Fancy
vim.g.have_nerd_font = true
vim.g.copilot_icon = ""
vim.g.copilot_disable = os.getenv("COPILOT_DISABLE") or false

-- For fish-lsp
vim.env.CC = "clang"
vim.env.CXX = "clang++"
vim.env.CXXFLAGS = "-std=c++20"
