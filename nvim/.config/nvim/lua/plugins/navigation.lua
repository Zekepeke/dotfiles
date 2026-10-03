return {
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false, -- must load at startup so tmux sees @pane-is-vim
    keys = {
      { "<M-h>", function() require("smart-splits").move_cursor_left() end,  desc = "Move to left split/pane" },
      { "<M-j>", function() require("smart-splits").move_cursor_down() end,  desc = "Move to lower split/pane" },
      { "<M-k>", function() require("smart-splits").move_cursor_up() end,    desc = "Move to upper split/pane" },
      { "<M-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move to right split/pane" },
      { "<M-H>", function() require("smart-splits").resize_left() end,  desc = "Resize left" },
      { "<M-J>", function() require("smart-splits").resize_down() end,  desc = "Resize down" },
      { "<M-K>", function() require("smart-splits").resize_up() end,    desc = "Resize up" },
      { "<M-L>", function() require("smart-splits").resize_right() end, desc = "Resize right" },
    },
  },
}
