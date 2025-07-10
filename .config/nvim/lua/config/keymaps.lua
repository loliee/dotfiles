--  Clear search
vim.keymap.set("n", "<leader><Space>", "<cmd>nohlsearch<CR>", { desc = "Clear search.", noremap = true, silent = true })

-- Save and close
vim.keymap.set(
  { "n", "i", "c", "v" },
  "<leader>q",
  "<Esc><cmd>:q!<CR>",
  { desc = "Force close.", noremap = true, silent = true }
)
vim.keymap.set("n", "<leader>qw", "<cmd>wq!<CR>", { desc = "Save and close all files.", noremap = true, silent = true })

-- Search visual selection
vim.keymap.set("v", "//", 'y/\\V<C-R>"<CR>', { noremap = true })

-- Yank all lines
vim.keymap.set("n", "<leader>a", ":0,$y<CR>", { desc = "Yank all lines.", noremap = true, silent = true })

-- Display invisibles chars
vim.keymap.set(
  "n",
  "<leader>l",
  ":set list!<CR>",
  { desc = "Display invisibles chars.", noremap = true, silent = true }
)

-- Paste without register
vim.keymap.set("v", "<leader>p", '"_c<Esc>p', { desc = "Paste without register.", noremap = true, silent = true })

-- Move visual selection with Alt-j / Alt-k
vim.keymap.set("v", "Ï", ":m '>+1<CR>gv=gv", { desc = "Move up visual selection.", noremap = true, silent = true })
vim.keymap.set("v", "È", ":m '<-2<CR>gv=gv", { desc = "Move down visual selection.", noremap = true, silent = true })

-- Special Keybinds based on terminal remap and ASCII code 254 (þ letter)
--
--  Save with Cmd-s
vim.keymap.set("n", "<Char-0x254>s", "<cmd>:w<CR>", { desc = "Save with Cmd-s.", noremap = true, silent = true })
vim.keymap.set(
  { "i", "c", "v" },
  "<Char-0x254>s",
  "<Esc><cmd>:w<CR>l",
  { desc = "Save with Cmd-s.", noremap = true, silent = true }
)

-- Undo with Cmd-u
vim.keymap.set(
  { "n", "i", "c" },
  "<Char-0x254>u",
  "<Esc>u",
  { desc = "Undo with Cmd-u.", noremap = true, silent = true }
)

-- Split window
vim.keymap.set(
  { "n", "i", "v", "c" },
  "<Char-0x254>&",
  "<Esc><C-w>v<C-w>l",
  { desc = "Move to next tab.", noremap = true, silent = true }
)

-- Tabs management
vim.keymap.set(
  { "n", "i", "c", "v" },
  "<Char-0x254>@",
  "<Esc><cmd>tabnew<CR>",
  { desc = "Open new tab.", noremap = true, silent = true }
)
vim.keymap.set(
  { "n", "i", "v", "c" },
  "<Char-0x254>n",
  "<Esc><cmd>:tabnext<CR>",
  { desc = "Move to next tab.", noremap = true, silent = true }
)
vim.keymap.set(
  { "n", "i", "v", "c" },
  "<Char-0x254>p",
  "<Esc><cmd>:tabprevious<CR>",
  { desc = "Move to previous tab.", noremap = true, silent = true }
)

-- Window moves
vim.keymap.set("n", "<Left>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<Down>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<Up>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<Right>", "<C-w>l", { desc = "Move to right window" })

-- Manage indentation with tab
vim.keymap.set("n", "<S-Tab>", "<<", { desc = "Indent left", noremap = true, silent = true })
vim.keymap.set("n", "<Tab>", ">>", { desc = "Indent right", noremap = true, silent = true })
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Indent visual selection left", noremap = true, silent = true })
vim.keymap.set("v", "<Tab>", ">gv", { desc = "Indent visual selection right", noremap = true, silent = true })

-- Open tig
vim.keymap.set(
  "n",
  "<leader>t",
  ":terminal tig %<CR>",
  { desc = "Open tig on current file", noremap = true, silent = true }
)
