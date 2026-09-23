vim.env.SNACKS_WEZTERM = "true"
vim.g.mapleader = " "

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"
vim.opt.scrolloff = 8
vim.opt.termguicolors = true
vim.opt.path:append("**")                 -- makes :find recursive
vim.opt.grepprg = "rg --vimgrep"          -- :grep uses ripgrep

require("lazy").setup({
  { import = "plugins" },
  
    {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    cmd = "Copilot",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept      = "<Tab>",
          accept_word = "<M-Right>",
          accept_line = "<M-Down>",
          dismiss     = "<C-]>",
          next        = "<M-]>",
          prev        = "<M-[>",
        },
      },
      panel = { enabled = false },
    },
  },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      picker = { enabled = true },
      explorer = { enabled = true },
      input = { enabled = true },
      bigfile = { enabled = true },
      image = { enabled = true },
    },
      keys = {
      { "<C-f>",      function() Snacks.picker.files() end,   desc = "Find files" },
      { "<leader>s",  function() Snacks.picker.grep() end,    desc = "Grep codebase" },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Open buffers" },
      { "<leader>fr", function() Snacks.picker.recent() end,  desc = "Recent files" },
      { "<leader>fh", function() Snacks.picker.help() end,    desc = "Help pages" },
      { "<leader>e",  function() Snacks.explorer() end,       desc = "File explorer" },
    },
  },
})

-- Over SSH: copy to the local (Mac) clipboard via OSC 52
if os.getenv("SSH_TTY") then
  local osc52 = require("vim.ui.clipboard.osc52")
  local function paste()
    return { vim.fn.getreg('"', 1, true), vim.fn.getregtype('"') }
  end
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end
