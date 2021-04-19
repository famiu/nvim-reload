# nvim-reload
## About
Nvim-reload is a Neovim plugin that allows you to reload your entire Neovim config completely, including your start plugins. It also reloads all lua modules inside your Neovim config directory.

### Requires:
* Neovim >= 0.5
* [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

## How to install
* [packer.nvim](https://github.com/wbthomason/packer.nvim/):
```
use 'famiu/nvim-reload'
```

* [paq-nvim](https://github.com/savq/paq-nvim/)
```
paq 'famiu/nvim-reload'
```

* [vim-plug](https://github.com/junegunn/vim-plug/):
```
Plug 'famiu/nvim-reload'
```

## How to use
Just install the plugin and it'll define two commands for you, `:Reload` and `:Restart`, to reload and restart your Vim config, respectively. Note that 'restart' here just means reloading and manually triggering the `VimEnter` autocmd to emulate a new run of Vim, it will not actually restart Vim.

You can also use the following Lua functions `require('nvim-reload').Reload()` and `require('nvim-reload').Restart()` instead of the `:Reload` and `:Restart` commands.

## Configuration
By default, nvim-reload only unloads the Lua modules inside your Neovim config directory so they can be reloaded by your init file through `require()` instead of getting the cached version of the module. If you want, you can also make it unload some external modules through the `modules_reload_external` table. For example:
```lua
require('nvim-reload').modules_reload_external = { 'packer' }
```

## Note
This plugin is still quite new and might have some bugs. And in case it does, feel free to make an issue here to report them.

## Self-plug
If you liked this plugin, also check out:
* [feline.nvim](https://github.com/famiu/feline.nvim) - A nice customizable statusline for Neovim written in Lua.
