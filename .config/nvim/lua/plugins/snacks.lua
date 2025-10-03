return {
  "folke/snacks.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = false },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    indent = { enabled = false },
    input = { enabled = false },
    picker = {
      enabled = true,
      matcher = {
        fuzzy = true,
        smartcase = true,
      },
      win = {
        input = {
          keys = {
            ["<space>"] = { "select_and_next", mode = { "n", "x" } },
            ["<C-x>"] = { "<c-s-w>", mode = { "i", "n" }, expr = true },
            ["<C-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
            ["<C-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
            ["<C-n>"] = { "history_forward", mode = { "i", "n" } },
            ["<C-p>"] = { "history_back", mode = { "i", "n" } },
          },
        },
      },
      layout = {
        preset = "horizontal",
        layout = {
          box = "horizontal",
          backdrop = false,
          width = 0.999,
          height = 0.999,
          border = "none",
          {
            box = "vertical",
            { win = "list", title = " Results ", title_pos = "center", border = "rounded" },
            { win = "input", height = 1, border = "rounded", title = "{title} {live} {flags}", title_pos = "center" },
          },
          {
            win = "preview",
            title = "{preview:Preview}",
            width = 0.55,
            border = "rounded",
            title_pos = "center",
          },
        },
      },
      icons = {
        files = {
          enabled = true,
        },
      },
    },
    notifier = { enabled = false },
    quickfile = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
  },
  keys = {
    {
      "<leader>,",
      function()
        Snacks.picker.buffers()
      end,
      desc = "Buffers",
    },
    {
      "<leader>f",
      function()
        Snacks.picker.files({
          hidden = true,
        })
      end,
      desc = "File Explorer / Hidden",
    },
    {
      "<leader>fa",
      function()
        Snacks.picker.files({
          hidden = true,
          ignored = true,
        })
      end,
      desc = "File Explorer / Hidden & Ignored",
    },
    {
      "<leader>fg",
      function()
        Snacks.picker.git_files()
      end,
      desc = "Git File Explorer",
    },
    {
      "<leader>fr",
      function()
        Snacks.picker.recent()
      end,
      desc = "Recent File Explorer",
    },
    {
      "<leader>r",
      function()
        Snacks.picker.grep({ hidden = true })
      end,
      desc = "Grep / Hidden",
    },
    {
      "<leader>ra",
      function()
        Snacks.picker.grep({ hidden = true, ignored = true })
      end,
      desc = "Grep / Hidden & Ignored",
    },
    {
      "<leader>fh",
      function()
        Snacks.picker.command_history({
          layout = "select",
        })
      end,
      desc = "History",
    },
    {
      "<leader>i",
      function()
        Snacks.picker.lines({ layout = "select" })
      end,
      desc = "Current Buffer",
    },
    {
      "<leader>fc",
      function()
        Snacks.picker.highlights()
      end,
      desc = "List highlights",
    },
    {
      "<leader>fk",
      function()
        Snacks.picker.keymaps()
      end,
      desc = "List keymaps",
    },
  },
}
