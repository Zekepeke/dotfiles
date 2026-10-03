-- PDFs open in Preview from the explorer/pickers (see util/files.lua).
-- <leader>pt on a PDF buffer, or `T` on a PDF in the explorer, opens the whole document as text.
return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>pt",
        function()
          local file = vim.api.nvim_buf_get_name(0)
          if not file:lower():match("%.pdf$") then
            return vim.notify("Not a PDF buffer", vim.log.levels.WARN)
          end
          require("util.files").pdf_text(file)
        end,
        desc = "PDF as text",
      },
    },
  },
}
