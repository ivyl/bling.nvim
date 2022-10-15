# bling.nvim

This plugin blinks the current search result after jumping to it after using \*,
\#, n or N.

![Preview](https://i.imgur.com/BV2jJoS.gif)


## Install

[packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use { 'ivyl/bling.nvim', config = function()
  require'bling'.setup({})
end }
```

## Docs

[`:help bling.txt`](doc/bling.txt)
