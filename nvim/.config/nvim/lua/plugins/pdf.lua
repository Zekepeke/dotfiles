-- PDFs render inline via snacks.image (needs ghostscript).
-- <leader>pt opens the whole document as searchable text (needs poppler's pdftotext).
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
          local out = vim.system({ "pdftotext", "-layout", file, "-" }, { text = true }):wait()
          if out.code ~= 0 then
            return vim.notify("pdftotext failed: " .. (out.stderr or ""), vim.log.levels.ERROR)
          end
          vim.cmd("vnew")
          vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(out.stdout, "\n"))
          vim.bo.buftype, vim.bo.bufhidden, vim.bo.swapfile = "nofile", "wipe", false
          vim.bo.modifiable = false
          vim.api.nvim_buf_set_name(0, vim.fn.fnamemodify(file, ":t") .. " (text)")
        end,
        desc = "PDF as text",
      },
    },
  },
}
