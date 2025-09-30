return {
  "neovim/nvim-lspconfig",
  lazy = false,
  dependencies = {
    { "williamboman/mason.nvim", opts = {} },
    { "williamboman/mason-lspconfig.nvim", opts = {} },
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "b0o/schemastore.nvim",
    {
      "j-hui/fidget.nvim",
      opts = {
        notification = { window = { winblend = 1 } },
      },
    },
    "saghen/blink.cmp",
  },
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or "n"
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end
      end,
    })

    if vim.g.have_nerd_font then
      local signs = { ERROR = "✗", WARN = "", INFO = "", HINT = "" }
      local diagnostic_signs = {}
      for type, icon in pairs(signs) do
        diagnostic_signs[vim.diagnostic.severity[type]] = icon
      end
      vim.diagnostic.config({
        virtual_text = { prefix = "●", spacing = 4 },
        signs = { text = diagnostic_signs },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = "always" },
      })
      vim.keymap.set("n", "<leader>z", function()
        vim.diagnostic.open_float({ border = "rounded" })
      end)
    end

    local servers = {
      ansiblels = {},
      ast_grep = {
        cmd = { "ast-grep", "lsp" },
        single_file_support = true,
      },
      bashls = {},
      dockerls = {},
      docker_compose_language_service = {
        settings = { telemetry = { telemetryLevel = "off" } },
      },
      fish_lsp = {},
      jinja_lsp = {},
      jsonls = {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      },
      just = {},
      helm_ls = {},
      lua_ls = {
        settings = {
          Lua = {},
        },
      },
      ruff = {},
      rust_analyzer = {},
      terraformls = {},
      yamlls = {
        settings = {
          yaml = {
            customTags = { "!reference sequence" },
            schemaStore = { enable = false, url = "" },
            schemas = require("schemastore").yaml.schemas({
              extra = {
                {
                  description = "GitLab override",
                  fileMatch = { "**/gitlab-ci/**/*.yml", "**/gitlab-components/**/*.yml" },
                  name = "gitlab.yml",
                  url = "https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json",
                },
              },
            }),
          },
        },
      },
    }

    local capabilities = require("blink.cmp").get_lsp_capabilities()
    for name, cfg in pairs(servers) do
      local merged = vim.tbl_deep_extend("force", { capabilities = capabilities }, cfg or {})
      vim.lsp.config(name, merged)
    end

    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, { "stylua" })
    require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

    require("mason-lspconfig").setup({
      ensure_installed = ensure_installed,
    })
  end,
}
