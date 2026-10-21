--- Prevents neovim from scrolling past the bottom of the buffer and showing unnecessary `:h filler-lines`
--- @param win number
local function filler_begone(win)
  assert(type(win) == 'number', 'window is not a number: ' .. win)
  assert(vim.api.nvim_win_is_valid(win), 'invalid window: ' .. win)

  local buf = vim.api.nvim_win_get_buf(win)
  if vim.b[buf].filler_begone == false then return end

  -- filler lines can only be visible when the last line of the buffer is visible
  local line_count = vim.api.nvim_buf_line_count(buf)
  if vim.fn.line('w$', win) < line_count then return end

  local win_height = math.min(vim.fn.winheight(win), line_count)

  -- height of the lines from `line` to the end of the buffer, including wrapping, virtual lines, folds and
  -- concealed line
  local function height_from(line)
    return vim.api.nvim_win_text_height(win, { start_row = line - 1, max_height = win_height + 1 }).all
  end

  local top_line = vim.fn.line('w0', win)
  if height_from(top_line) >= win_height then return end

  -- the line above doesn't fit (i.e. a tall wrapped line), so we're already as close as we can get
  if top_line == 1 or height_from(top_line - 1) > win_height then return end

  -- binary search for the first line from which the rest of the buffer fits in the window
  local low, high = 1, top_line
  while low < high do
    local mid = math.floor((low + high) / 2)
    if height_from(mid) > win_height then
      low = mid + 1
    else
      high = mid
    end
  end

  -- scroll to the target line
  if low ~= top_line then vim.api.nvim_win_call(win, function() vim.fn.winrestview({ topline = low }) end) end
end

return filler_begone
