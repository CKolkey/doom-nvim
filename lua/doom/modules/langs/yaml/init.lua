local yaml = {}

yaml.settings = {
  --- Disables auto installing the treesitter
  --- @type boolean
  disable_treesitter = false,
  --- Treesitter grammars to install
  --- @type string|string[]
  treesitter_grammars = "yaml",

  --- Disables default LSP config
  --- @type boolean
  disable_lsp = false,
  --- Name of the language server
  --- @type string
  language_server_name = "tsserver",

  --- Disables null-ls formatting sources
  --- @type boolean
  disable_formatting = false,
  --- Mason.nvim package to auto install the formatter from
  --- @type string
  formatting_package = "yamlfmt",
  --- String to access the null_ls diagnositcs provider
  --- @type string
  formatting_provider = "builtins.formatting.yamlfmt",
  --- Function to configure null-ls formatter
  --- @type function|nil
  formatting_config = nil,

  --- Disables null-ls diagnostic sources
  --- @type boolean
  disable_diagnostics = false,
  --- Mason.nvim package to auto install the diagnostics provider from
  --- @type string
  diagnostics_package = "yamllint",
  --- String to access the null_ls diagnositcs provider
  --- @type string
  diagnostics_provider = "builtins.diagnostics.yamllint",
  --- Function to configure null-ls diagnostics
  --- @type function|nil
  diagnostics_config = nil,
}

yaml.packages = {
  ["SchemaStore.nvim"] = {
    "b0o/SchemaStore.nvim",
    commit = "f55842dc797faad8cf7b0d9ce75c59da654aa018",
    ft = { "yaml" },
  },
}

yaml.autocmds = {
  {
    "FileType",
    "yaml",
    function()
      local langs_utils = require("doom.modules.langs.utils")

      if not yaml.settings.disable_lsp then
        langs_utils.use_lsp_mason(yaml.settings.language_server_name, {
          config = {
            settings = {
              yaml = {
                schemas = require("schemastore").yaml.schemas()
              }
            }
          }
        })
      end

      if not yaml.settings.disable_treesitter then
        langs_utils.use_tree_sitter(yaml.settings.treesitter_grammars)
      end

      if not yaml.settings.disable_formatting then
        langs_utils.use_null_ls(
          yaml.settings.formatting_package,
          yaml.settings.formatting_provider,
          yaml.settings.formatting_config
        )
      end
      if not yaml.settings.disable_diagnostics then
        langs_utils.use_null_ls(
          yaml.settings.diagnostics_package,
          yaml.settings.diagnostics_provider,
          yaml.settings.diagnostics_config
        )
      end
    end,
    once = true,
  },
}

return yaml
