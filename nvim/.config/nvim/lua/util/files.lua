local M = {}

-- Images and PDFs open in macOS Preview (kitty graphics are unreliable under tmux + WezTerm).
local external = { "png", "jpg", "jpeg", "gif", "webp", "bmp", "tiff", "heic", "pdf" }

function M.is_external(path)
  local ext = (path or ""):match("%.(%w+)$")
  return ext ~= nil and vim.tbl_contains(external, ext:lower())
end

-- Whole PDF as readonly, searchable text (needs poppler's pdftotext).
function M.pdf_text(file)
  local out = vim.system({ "pdftotext", "-layout", file, "-" }, { text = true }):wait()
  if out.code ~= 0 then
    return vim.notify("pdftotext failed: " .. (out.stderr or ""), vim.log.levels.ERROR)
  end
  vim.cmd("vnew")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(out.stdout, "\n"))
  vim.bo.buftype, vim.bo.bufhidden, vim.bo.swapfile = "nofile", "wipe", false
  vim.bo.modifiable = false
  vim.api.nvim_buf_set_name(0, vim.fn.fnamemodify(file, ":t") .. " (text)")
end

-- Render the mermaid block under the cursor to a PNG and open it in Preview (needs mmdc).
function M.mermaid_preview()
  local buf = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local first, last
  for i = row, 1, -1 do
    if lines[i]:match("^%s*```mermaid") then first = i break end
    if i < row and lines[i]:match("^%s*```") then break end
  end
  if first then
    for i = first + 1, #lines do
      if lines[i]:match("^%s*```%s*$") then last = i break end
    end
  end
  if not (first and last) then
    return vim.notify("Cursor is not inside a mermaid block", vim.log.levels.WARN)
  end
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  local src, out = dir .. "/diagram.mmd", dir .. "/diagram.png"
  vim.fn.writefile(vim.list_slice(lines, first + 1, last - 1), src)
  vim.system({ "mmdc", "-i", src, "-o", out, "-s", "2" }, { text = true }, function(res)
    vim.schedule(function()
      if res.code ~= 0 then
        return vim.notify("mmdc failed: " .. (res.stderr or ""), vim.log.levels.ERROR)
      end
      vim.ui.open(out)
    end)
  end)
end

-- Wrap a picker confirm action so images/PDFs go to Preview and everything else is unchanged.
function M.confirm(orig)
  return function(picker, item, action)
    local path = item and item.file and Snacks.picker.util.path(item)
    if path and M.is_external(path) and vim.fn.isdirectory(path) == 0 then
      picker:close()
      vim.ui.open(path)
      return
    end
    return orig(picker, item, action)
  end
end

return M
