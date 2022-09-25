local lua = {}

lua.settings = {
  --- Disables auto installing the treesitter
  --- @type boolean
  disable_treesitter = false,
  --- Treesitter grammars to install
  --- @type string|string[]
  treesitter_grammars = "lua",

  --- Disables default LSP config
  --- @type boolean
  disable_lsp = false,
  --- Name of the language server
  --- @type string
  language_server_name = "sumneko_lua",

  --- Disables null-ls formatting sources
  --- @type boolean
  disable_formatting = false,
  --- Mason.nvim package to auto install the formatter from
  --- @type string
  formatting_package = "stylua",
  --- String to access the null_ls diagnositcs provider
  --- @type string
  formatting_provider = "builtins.formatting.stylua",
  --- Function to configure null-ls formatter
  --- @type function|nil
  formatting_config = nil,

  --- Disables null-ls diagnostic sources
  --- @type boolean
  disable_diagnostics = false,
  --- Mason.nvim package to auto install the diagnostics provider from
  --- @type string
  diagnostics_package = "luacheck",
  --- String to access the null_ls diagnositcs provider
  --- @type string
  diagnostics_provider = "builtins.diagnostics.luacheck",
  --- Function to configure null-ls diagnostics
  --- @type function|nil
  diagnostics_config = nil,

  --- Options passed to language server
  lsp_config = {
    formatter = {
      enabled = true,
    },
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
        },
        diagnostics = {
          globals = { "vim", "doom" },
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          maxPreload = 1000,
          preloadFileSize = 150,
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  },
  --- Config for the lua-dev plugin
  lua_dev = {
    library = {
      vimruntime = true,
      types = true,
      plugins = true,
    },
  },
}

lua.packages = {
  ["lua-dev.nvim"] = {
    "folke/lua-dev.nvim",
    commit = "f5c31936fe06fcbeb59b98f69f74f9c2f91abaec",
    ft = "lua",
  },
}

lua.autocmds = {
  {
    "FileType",
    "lua",
    function()
      local langs_utils = require("doom.modules.langs.utils")

      local runtime_path = vim.split(package.path, ";")
      table.insert(runtime_path, "lua/?.lua")
      table.insert(runtime_path, "lua/?/init.lua")

      local config = vim.tbl_deep_extend(
        "force",
        doom.langs.lua.settings.lsp_config,
        require("lua-dev").setup(doom.langs.lua.settings.dev),
        {
          settings = {
            Lua = {
              runtime = {
                path = runtime_path,
              },
            },
          },
        }
      )

      if not lua.settings.disable_lsp then
        langs_utils.use_lsp_mason(lua.settings.language_server_name, {
          config = config,
        })
      end

      if not lua.settings.disable_treesitter then
        langs_utils.use_tree_sitter(lua.settings.treesitter_grammars)
      end

      if not lua.settings.disable_formatting then
        langs_utils.use_null_ls(
          lua.settings.formatting_package,
          lua.settings.formatting_provider,
          lua.settings.formatting_config
        )
      end
      if not lua.settings.disable_diagnostics then
        langs_utils.use_null_ls(
          lua.settings.diagnostics_package,
          lua.settings.diagnostics_provider,
          lua.settings.diagnostics_config
        )
      end
    end,
    once = true,
  },
}

return lua
