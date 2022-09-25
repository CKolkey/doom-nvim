local java = {}

java.settings = {
  --- Disables auto installing the treesitter
  --- @type boolean
  disable_treesitter = false,
  --- Treesitter grammars to install
  --- @type string|string[]
  treesitter_grammars = "java",

  --- Disables default LSP config
  --- @type boolean
  disable_lsp = false,
  --- Name of the language server
  --- @type string
  language_server_name = "jdtls",

  --- Disables null-ls formatting sources
  --- @type boolean
  disable_formatting = false,
  --- WARN: No package. Mason.nvim package to auto install the formatter from
  --- @type nil
  formatting_package = nil,
  --- String to access the null_ls diagnositcs provider
  --- @type string
  formatting_provider = "builtins.formatting.google_java_format",
  --- Function to configure null-ls formatter
  --- @type function|nil
  formatting_config = nil,
}

java.autocmds = {
  {
    "BufWinEnter",
    "*.java",
    function()
      local langs_utils = require("doom.modules.langs.utils")

      if not java.settings.disable_lsp then
        langs_utils.use_lsp_mason(java.settings.language_server_name)
      end

      if not java.settings.disable_treesitter then
        langs_utils.use_tree_sitter(java.settings.treesitter_grammars)
      end

      if not java.settings.disable_formatting then
        langs_utils.use_null_ls(
          java.settings.diagnostics_package,
          java.settings.formatting_provider,
          java.settings.formatting_config
        )
      end
    end,
    once = true,
  },
}

return java
