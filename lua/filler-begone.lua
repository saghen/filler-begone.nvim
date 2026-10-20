local function should_ignore_line(buf, win, line)
  -- line is folded
  local fold_closed_line = vim.fn.foldclosed(line)
  if fold_closed_line ~= -1 and fold_closed_line ~= line then return true end

  -- line is concealed
  local conceal_level = vim.wo[win].conceallevel or vim.o.conceallevel or 0
  if conceal_level < 2 then return false end

  local extmarks = vim.api.nvim_buf_get_extmarks(buf, -1, { line - 1, 0 }, { line - 1, -1 }, { details = true })
  for _, extmark in ipairs(extmarks) do
    if extmark[4].conceal_lines ~= nil then return true end
  end

  -- TODO: consider if line is not concealed due to cursor being on it
  -- local conceal_cursor = vim.wo[win].concealcursor or vim.o.concealcursor or 'niv'

  return false
end

--- Prevents neovim from scrolling past the bottom of the buffer and showing unnecessary `:h filler-lines`
--- @param win number
local function filler_begone(win)
  assert(type(win) == 'number', 'window is not a number: ' .. win)
  assert(vim.api.nvim_win_is_valid(win), 'invalid window: ' .. win)

  local buf = vim.api.nvim_win_get_buf(win)
  if vim.b[buf].filler_begone == false then return end

  vim.api.nvim_win_call(win, function()
    local line_count = vim.api.nvim_buf_line_count(buf)
    local win_height = math.min(vim.fn.winheight(win), line_count)

    -- check how many lines are visible from the buffer, starting from the line currently at the top of the window
    local top_line = vim.fn.line('w0', win)
    local lines_below = 0
    for i = top_line, line_count do
      if not should_ignore_line(buf, win, i) then
        local line_height = vim.api.nvim_win_text_height(win, { start_row = i - 1, end_row = i - 1 }).all
        lines_below = lines_below + line_height
        if lines_below >= win_height then break end
      end
    end

    if lines_below < win_height then
      -- start from the last line, calculate the height of each line, including virtual text and wrapping
      -- until we reach the height of the window
      local accumulated_line_height = 0
      local target_line = line_count
      while target_line > 0 do
        if not should_ignore_line(buf, win, target_line) then
          local line_height = vim.api.nvim_win_text_height(win, {
            start_row = target_line - 1,
            end_row = target_line - 1,
          }).all
          accumulated_line_height = accumulated_line_height + line_height

          -- current line would go beyond win height, go back down one line
          if accumulated_line_height > win_height then target_line = target_line + 1 end
          if accumulated_line_height >= win_height then break end
        end
        target_line = target_line - 1
      end
      target_line = math.min(target_line, line_count)

      -- scroll to the target line
      vim.fn.winrestview({ topline = target_line })

      -- force another event loop iteration, with updated topline
      -- https://github.com/neovim/neovim/issues/35633#issuecomment-3256274806
      vim.schedule(function() vim.fn.winrestview({ topline = target_line }) end)
      vim.api.nvim_feedkeys(vim.keycode('<Ignore>'), 'ni', false)
    end
  end)
end

return filler_begone
