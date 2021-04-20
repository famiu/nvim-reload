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

### Configuration
By default, nvim-reload reloads your start plugins (located in `stdpath('data')/site/pack/*/start/*`) and init file. It also unloads the Lua modules inside your Neovim config (located in `stdpath('config')/lua`) so they can be reloaded by your init file through `require()` instead of getting the cached version of the module. If you want, you can change the default behavior through the following configuration options.

* `vim_reload_dirs` - Table containing list of directories to load the Vim files from. The plugin will look into the `'compiler'`, `'doc'`, `'keymap'`, `'syntax'` and `'plugin'` subdirectories of each directory provided here for files to reload.<br>Default: `{ vim.fn.stdpath('config'), vim.fn.stdpath('data') .. '/site/pack/*/start/*' }`

* `lua_reload_dirs` - Table containing list of directories to load the Lua modules from. The plugin will look into the `lua` subdirectory of each directory provided here for modules to unload.<br>Default: `{ vim.fn.stdpath('config') }`

* `files_reload_external` - Paths to external VimL files outside the reload directories to reload.<br>Default: `{}`

* `modules_reload_external` - Names of external modules outside the reload directories to reload.<br>Default: `{}`

#### Example config:
```lua
local reload = require('nvim-reload')

-- If you use Neovim's built-in plugin system
-- Or a plugin manager that uses it (eg: packer.nvim)
local plugin_dirs = vim.fn.stdpath('data') .. '/site/pack/*/start/*'

-- If you use vim-plug
-- local plugin_dirs = vim.fn.stdpath('data') .. '/plugged/*'

reload.vim_reload_dirs = {
    vim.fn.stdpath('config'),
    plugin_dirs
}

reload.lua_reload_dirs = {
    vim.fn.stdpath('config')
    -- Note: the line below may cause issues reloading your config
    plugin_dirs
}

reload.files_reload_external = {
    vim.fn.stdpath('config') .. '/myfile.vim'
}

reload.modules_reload_external = { 'packer' }
```

**NOTE:** The directories provided in `lua_reload_dirs` and `vim_reload_dirs` can be globs, which will automatically be expanded by the plugin.

## Note
This plugin is still quite new and might have some bugs. And in case it does, feel free to make an issue here to report them.

## Self-plug
If you liked this plugin, also check out:
* [feline.nvim](https://github.com/famiu/feline.nvim) - A nice customizable statusline for Neovim written in Lua.
