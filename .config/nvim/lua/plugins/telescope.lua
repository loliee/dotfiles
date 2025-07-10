local custom = {}
custom.select_one_or_multi = function(prompt_bufnr)
  local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
  local multi = picker:get_multi_selection()
  if not vim.tbl_isempty(multi) then
    require("telescope.actions").close(prompt_bufnr)
    for _, j in pairs(multi) do
      if j.path ~= nil then
        vim.cmd(string.format("%s %s", "edit", j.path))
      end
    end
  else
    require("telescope.actions").select_default(prompt_bufnr)
  end
end

return { -- Fuzzy Finder (files, lsp, etc)
  "nvim-telescope/telescope.nvim",
  event = "VimEnter",
  lazy = false,
  branch = "0.1.x",
  priority = 900,
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
    { "Marskey/telescope-sg" },
    { "nvim-telescope/telescope-ui-select.nvim" },
    -- Useful for getting pretty icons, but requires a Nerd Font.
    { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
  },
  config = function()
    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    require("telescope").setup({
      defaults = {
        preview = {
          timeout = 500,
        },
        mappings = {
          i = {
            ["<C-n>"] = require("telescope.actions").cycle_history_next,
            ["<C-p>"] = require("telescope.actions").cycle_history_prev,
            ["<C-Space>"] = function(bufnr)
              require("telescope.actions").toggle_selection(bufnr)
              require("telescope.actions").move_selection_worse(bufnr)
            end,
            ["<CR>"] = custom.select_one_or_multi,
          },
        },
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "bottom",
            width = { padding = 0 },
            height = { padding = 0 },
            preview_width = 0.5,
          },
        },
        sorting_strategy = "ascending",
        vimgrep_arguments = {
          "rg",
          "--hidden",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "-u",
        },
      },
      pickers = {
        find_files = {
          find_command = {
            "fd",
            "--type",
            "file",
            "--hidden",
            "--exclude",
            ".git",
          },
        },
      },
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(),
        },
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
      ast_grep = {
        command = {
          "sg",
          "--json=stream",
        }, -- must have --json=stream
        grep_open_files = false, -- search in opened files
      },
    })

    -- Enable Telescope extensions if they are installed
    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "ui-select")

    -- See `:help telescope.builtin`
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
    vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "[S]earch [F]iles" })
    vim.keymap.set(
      "n",
      "<leader>fa",
      ":lua require('telescope.builtin').find_files({ no_ignore=true })<CR>",
      { noremap = true, silent = true }
    )
    vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
    vim.keymap.set("n", "<leader>fa", ":Telescope ast_grep<CR>", { desc = "[S]earch wiht ast-grep" })

    vim.keymap.set("n", "<leader>i", function()
      builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        winblend = 10,
        previewer = false,
      }))
    end, { desc = "[/] Fuzzily search in current buffer" })
    vim.keymap.set(
      "n",
      "<leader>r",
      ":lua require('telescope.builtin').live_grep({ additional_args = function() return {'--ignore'} end })<CR>",
      { noremap = true, silent = true }
    )
    vim.keymap.set(
      "n",
      "<leader>ra",
      ":lua require('telescope.builtin').live_grep({ additional_args = function() return {'--no-ignore'} end })<CR>",
      { noremap = true, silent = true }
    )

    vim.keymap.set("n", "<leader>;", function()
      builtin.live_grep({
        grep_open_files = true,
        prompt_title = "Live Grep in Open Files",
      })
    end, { desc = "[S]earch [/] in Open Files" })
  end,
}
