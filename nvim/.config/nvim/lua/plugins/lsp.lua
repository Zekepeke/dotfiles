-- ~/dotfiles/nvim/.config/nvim/lua/plugins/lsp.lua
-- LSP (smart features) + Treesitter (parsing) + completion + formatting.
-- Needs Neovim 0.11+.

-- Show errors inline as you type (0.11 hides them by default)
vim.diagnostic.config({ virtual_text = true, severity_sort = true })

-- Keymaps that only exist when a language server is attached.
-- Built-in 0.11 defaults you also get for free:
--   K   hover docs        grn rename symbol     grr find references
--   gra code action       gri go to implementation
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
    end
    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("<leader>r", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>d", vim.diagnostic.open_float, "Show error under cursor")
  end,
})

return {
  -- Mason: installs language servers / formatters (like an app store)
  { "mason-org/mason.nvim", opts = {} },

  -- Installs these servers and turns them on automatically
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = {
        "pyright", -- Python
        "clangd",  -- C / C++
        "lua_ls",  -- Lua (your nvim config itself)
      },
    },
  },

  -- Stops lua_ls from complaining "undefined global vim" in your config
  { "folke/lazydev.nvim", ft = "lua", opts = {} },

  -- Completion popup, fed by the LSP. <C-y> accepts, <C-n>/<C-p> move.
  -- (Tab stays Copilot's.)
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    opts = {
      keymap = { preset = "default" },
      sources = { default = { "lsp", "path", "buffer" } },
    },
  },

  -- Treesitter: real syntax tree -> accurate highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
        "python", "c", "cpp", "lua", "bash", "json", "yaml",
        "sql", "markdown", "markdown_inline", "javascript", "typescript",
      })
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args) pcall(vim.treesitter.start, args.buf) end,
      })
    end,
  },

  -- Formatter: fixes style on save
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        lua = { "stylua" },
      },
      format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
    },
  },
}
