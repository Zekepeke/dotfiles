return {
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = "BufReadPre",
    opts = { default_mappings = false },
    keys = {
      { "<leader>gco", "<cmd>GitConflictChooseOurs<cr>",   desc = "Conflict: choose ours" },
      { "<leader>gct", "<cmd>GitConflictChooseTheirs<cr>", desc = "Conflict: choose theirs" },
      { "<leader>gcb", "<cmd>GitConflictChooseBoth<cr>",   desc = "Conflict: choose both" },
      { "<leader>gc0", "<cmd>GitConflictChooseNone<cr>",   desc = "Conflict: choose none" },
      { "]x", "<cmd>GitConflictNextConflict<cr>", desc = "Next conflict" },
      { "[x", "<cmd>GitConflictPrevConflict<cr>", desc = "Previous conflict" },
      { "<leader>gcl", "<cmd>GitConflictListQf<cr>", desc = "List conflicts" },
    },
  },
}
