return {
  "neovim/nvim-lspconfig",
  lazy = false,
  dependencies = {
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
        -- Rename the variable under your cursor.
        --  Most Language Servers support renaming across files, etc.
        map("grn", vim.lsp.buf.rename, "[R]e[n]ame")

        -- Execute a code action, usually your cursor needs to be on top of an error
        -- or a suggestion from your LSP for this to activate.
        map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
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

    local gitlab_schema_url =
      "https://gitlab.com/gitlab-org/gitlab/-/raw/main/app/assets/javascripts/editor/schema/ci.json"
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
      helm_ls = {},
      lua_ls = {
        settings = {
          Lua = {},
        },
      },
      ruff = {},
      rust_analyzer = {},
      terraformls = {
        on_attach = function(client, _)
          -- semantic tokens on files with many errors = huge payload = freeze
          client.server_capabilities.semanticTokensProvider = nil
        end,
      },
      taplo = {},
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
                  url = gitlab_schema_url,
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

    -- These run the project's code: build.rs, proc-macros, .luarc.json plugins, ansible-lint rules, providers
    local security = require("security")
    for _, name in ipairs({ "ansiblels", "lua_ls", "rust_analyzer", "terraformls" }) do
      local config = vim.lsp.config[name]
      vim.lsp.config(name, {
        root_dir = function(bufnr, on_dir)
          if not security.trusted(bufnr) then
            return
          end
          -- The server's root too: a marker such as .luarc.json can put it above the file's project
          local function on_trusted_dir(dir)
            -- Scheduled: rust_analyzer answers from a vim.system callback, where the trust prompt cannot open
            vim.schedule(function()
              if not dir or security.trusted(dir) then
                on_dir(dir)
              end
            end)
          end
          if type(config.root_dir) == "function" then
            config.root_dir(bufnr, on_trusted_dir)
          else
            on_trusted_dir(config.root_markers and vim.fs.root(bufnr, config.root_markers))
          end
        end,
      })
    end

    -- The servers come from mise (~/.config/mise/config.toml), pinned and locked
    vim.lsp.enable(vim.tbl_keys(servers))
  end,
}
