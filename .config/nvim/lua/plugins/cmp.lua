return { -- Autocompletion
  "hrsh7th/nvim-cmp",
  dependencies = {
    {
      "L3MON4D3/LuaSnip",
      build = (function()
        return "make install_jsregexp"
      end)(),
      dependencies = {},
    },
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "onsails/lspkind.nvim",
  },
  config = function()
    -- See `:help cmp`
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local lspkind = require("lspkind")
    require("luasnip.loaders.from_lua").lazy_load({
      paths = { "~/.config/nvim/snippets/lua" },
    })

    luasnip.config.setup({
      cut_selection_keys = "<C-Space>",
    })

    local cmp_init = {
      enabled = function()
        -- disable completion in comments
        local context = require("cmp.config.context")
        -- keep command mode completion enabled when cursor is in a comment
        if vim.api.nvim_get_mode().mode == "c" then
          return true
        else
          return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
        end
      end,
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      completion = { autocomplete = false, completeopt = "menu,menuone,noinsert" },

      formatting = {
        format = lspkind.cmp_format({
          mode = "symbol",
          max_width = 50,
          symbol_map = { Copilot = vim.g.copilot_icon },
        }),
      },

      mapping = cmp.mapping.preset.insert({
        ["<C-u>"] = cmp.mapping.scroll_docs(-4),
        ["<C-d>"] = cmp.mapping.scroll_docs(4),
        ["<C-f>"] = cmp.mapping.confirm({ select = true }),
        ["<C-e>"] = cmp.mapping(function()
          if luasnip.choice_active() then
            require("luasnip.extras.select_choice")()
          end
        end, { "i", "s", silent = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif require("copilot.suggestion").is_visible() then
            require("copilot.suggestion").accept()
          else
            fallback()
          end
        end, {
          "i",
          "s",
        }),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<C-Space>"] = cmp.mapping(function(fallback)
          if not cmp.visible() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<C-n>"] = function(fallback)
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          else
            local picker = action_state.get_current_picker(vim.api.nvim_get_current_buf())
            if picker and picker._state then
              actions.cycle_history_next(vim.api.nvim_get_current_buf())
            else
              fallback()
            end
          end
        end,
        ["<C-p>"] = function(fallback)
          if luasnip.expand_or_locally_jumpable() then
            luasnip.jump(-1)
          else
            local picker = action_state.get_current_picker(vim.api.nvim_get_current_buf())
            if picker and picker._state then
              actions.cycle_history_prev(vim.api.nvim_get_current_buf())
            else
              fallback()
            end
          end
        end,
      }),
      sources = {
        {
          name = "lazydev",
          group_index = 0,
        },
        { name = "luasnip", priority = 10 },
        { name = "nvim_lsp", priority = 5 },
        { name = "copilot", group_index = 2, priority = 5 },
        { name = "path", priority = 1 },
        { name = "path" },
        per_filetype = {
          codecompanion = { "codecompanion" },
        },
      },
      window = {
        completion = cmp.config.window.bordered({
          border = "none",
          side_padding = 0,
        }),
      },
    }
    ---@diagnostic disable-next-line
    cmp.setup(cmp_init)
    -- local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    -- cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    cmp.event:on("menu_opened", function()
      vim.b.copilot_suggestion_hidden = true
    end)

    cmp.event:on("menu_closed", function()
      vim.b.copilot_suggestion_hidden = false
    end)
  end,
}
