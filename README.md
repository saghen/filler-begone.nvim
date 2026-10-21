# filler-begone.nvim

Prevents neovim from scrolling past the bottom of the buffer and showing unnecessary `:h filler-lines`. Disable globally with `vim.g.filler_begone = false` or per-buffer with `vim.b.filler_begone = false`. Plugin initializes itself automatically, just add it to your package manager.

Special thanks to [zeertzjq](https://github.com/zeertzjq), [justinmk](https://github.com/justinmk), [seandewar](https://github.com/seandewar), and [echasnovski](https://github.com/echasnovski) for their help!

## Installation

```lua
-- lazy.nvim
{ 'saghen/filler-begone.nvim' }

-- vim.pack
vim.pack.add({ 'https://github.com/saghen/filler-begone.nvim' })

-- mini.deps
MiniDeps.add({ source = 'saghen/filler-begone.nvim' })
```
