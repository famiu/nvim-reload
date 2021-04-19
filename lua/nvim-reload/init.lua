local M = {}
local fn = vim.fn
local cmd = vim.cmd

local scan_dir = require('plenary.scandir').scan_dir

-- External modules outside the config to reload
M.modules_reload_external = {}

-- Unload all loaded modules
local function unload_modules()
    -- Lua config prefix
    local config_prefix = fn.stdpath('config') .. '/lua'

    -- Search for all .lua files in config prefix
    local modules = scan_dir(
        config_prefix,
        { search_pattern = '.*%.lua$', hidden = true }
    )

    for i, module in ipairs(modules) do
        -- Remove config prefix and extension from module path
        module = string.match(module, string.format('%s/(.*)%%.lua', config_prefix))

        -- Changes slash in path to dot to follow lua module format
        module = string.gsub(module, "/", ".")

        -- If module ends with '.init', remove it.
        module = string.gsub(module, "%.init$", "")

        -- Override previous value with new value
        modules[i] = module
    end

    for _, module in ipairs(M.modules_reload_external) do
        table.insert(modules, module)
    end

    -- Reload each module in the modules table
    for _, module in ipairs(modules) do
        package.loaded[module] = nil
    end
end

-- Reload all start plugins
local function reload_start_plugins()
    -- Find all start plugin files
    local loadfiles = scan_dir(
        fn.stdpath('config') .. '/plugin',
        { search_pattern = '.*%.n?vim$', hidden = true }
    )

    local loadfiles_data = scan_dir(
        fn.stdpath('data') .. '/site/pack',
        { search_pattern = '.*/start/.*/plugin/.*%.n?vim$', hidden = true }
    )

    for _, v in ipairs(loadfiles_data) do
        table.insert(loadfiles, v)
    end

    -- Source every file found
    for _, file in ipairs(loadfiles) do
        cmd('source ' .. file)
    end
end

-- Reload Vim configuration
function M.Reload()
    -- Clear highlights
    cmd('hi clear')

    -- Stop LSP if it's configured
    if fn.exists(':LspStop') ~= 0 then
        cmd('LspStop')
    end

    -- Unload all already loaded modules
    unload_modules()

    -- Source init file
    cmd('luafile $MYVIMRC')

    -- Reload start plugins
    reload_start_plugins()
end

-- Restart Vim without having to close and run again
function M.Restart()
    -- Reload config
    M.Reload()

    -- Manually run VimEnter autocmd to emulate a new run of Vim
    cmd('doautocmd VimEnter')
end

return M
