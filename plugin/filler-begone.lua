vim.api.nvim_set_decoration_provider(vim.api.nvim_create_namespace('filler-begone'), {
  on_start = function()
    if vim.g.filler_begone == false then return end

    local filler_begone = require('filler-begone')
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      filler_begone(win)
    end
  end,
})
