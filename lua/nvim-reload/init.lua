local M = {}

local o = vim.o

local fn = vim.fn
local cmd = vim.cmd
local exec = vim.api.nvim_exec

local scan_dir = require('plenary.scandir').scan_dir

local utils = require('nvim-reload.utils')

-- Get all directories to reload by default
function M.default_reload_dirs()
    local reload_dirs = {}

    -- Add all start plugins found in a directory
    local function add_dir_plugins(dir)
        for _, plugin in ipairs(fn.glob(dir .. '/pack/*/start/*', 0, 1)) do
            reload_dirs[#reload_dirs+1] = plugin
        end
    end

    reload_dirs[#reload_dirs+1] = fn.stdpath('config')

    for _, dir in ipairs(fn.stdpath('config_dirs')) do
        reload_dirs[#reload_dirs+1] = dir
    end

    reload_dirs[#reload_dirs+1] = fn.stdpath('data') .. '/site'
    add_dir_plugins(fn.stdpath('data') .. '/site')

    for _, dir in ipairs(fn.stdpath('data_dirs')) do
        reload_dirs[#reload_dirs+1] = dir .. '/site'
        add_dir_plugins(dir .. '/site')
    end

    for _, dir in ipairs(fn.stdpath('data_dirs')) do
        reload_dirs[#reload_dirs+1] = dir .. '/site/after'
        add_dir_plugins(dir .. '/site/after')
    end

    reload_dirs[#reload_dirs+1] = fn.stdpath('data') .. '/site/after'
    add_dir_plugins(fn.stdpath('data') .. '/site/after')

    for _, dir in ipairs(fn.stdpath('config_dirs')) do
        reload_dirs[#reload_dirs+1] = dir .. '/after'
    end

    reload_dirs[#reload_dirs+1] = fn.stdpath('config') .. '/after'

    return reload_dirs
end

-- Paths to reload Vim files from
M.vim_reload_dirs = M.default_reload_dirs()

-- Paths to unload Lua modules from
-- M.lua_reload_dirs = { fn.stdpath('config') }
M.lua_reload_dirs = M.default_reload_dirs()

-- External files outside the runtimepaths to source
M.files_reload_external = {}

-- External Lua modules outside the runtimepaths to unload
M.modules_reload_external = {}

-- Modules to exclude from unloading due to incompatibility issues
M.modules_reload_excluded = { 'gitsigns' }

local viml_subdirs = {
    'compiler',
    'doc',
    'indent',
    'keymap',
    'lang',
    'plugin',
    'print',
    'spell',
    'syntax',
}

local function get_runtime_files_in_path(runtimepath)
    local runtime_files = {}

    -- Search each subdirectory listed listed in viml_subdirs of runtimepath for files
    for _, subdir in ipairs(viml_subdirs) do
        local viml_path = string.format("%s/%s", runtimepath, subdir)

        if utils.path_exists(viml_path) then
            local files = scan_dir(viml_path, { search_pattern = '%.n?vim$', hidden = true })

            for _, file in ipairs(files) do
                runtime_files[#runtime_files+1] = file
            end
        end
    end

    return runtime_files
end

local function is_module_excluded(module)
    for _, v in ipairs(M.modules_reload_excluded) do
        if v == module or string.match(module, string.format('^%s%%.', v)) then
            return true
        end
    end
end

local function get_lua_modules_in_path(runtimepath)
    local luapath = string.format("%s/lua", runtimepath)

    if not utils.path_exists(luapath) then
        return {}
    end

    -- Search lua directory of runtimepath for modules
    local modules = scan_dir(luapath, { search_pattern = '%.lua$', hidden = true })

    for i, module in ipairs(modules) do
        -- Remove runtimepath and file extension from module path
        module = string.match(
            module,
            string.format(
                '%s/(.*)%%.lua',
                utils.escape_str(luapath)
            )
        )

        -- Changes slash in path to dot to follow lua module format
        module = string.gsub(module, "/", ".")

        -- If module ends with '.init', remove it.
        module = string.gsub(module, "%.init$", "")

        -- Override previous value with new value
        modules[i] = module
    end

    return modules
end

-- Reload all start plugins
local function reload_runtime_files()
    -- Search each runtime path for files
    for _, runtimepath_suffix in ipairs(M.vim_reload_dirs) do
        -- Expand the globs and get the result as a list
        local paths = fn.glob(runtimepath_suffix, 0, 1)

        for _, path in ipairs(paths) do
            local runtime_files = get_runtime_files_in_path(path)

            for _, file in ipairs(runtime_files) do
                cmd('source ' .. file)
            end
        end
    end

    for _, file in ipairs(M.files_reload_external) do
        cmd('source ' .. file)
    end
end

-- Unload all loaded Lua modules
local function unload_lua_modules()
    -- Search each runtime path for modules
    for _, runtimepath_suffix in ipairs(M.lua_reload_dirs) do
        local paths = fn.glob(runtimepath_suffix, 0, 1)

        for _, path in ipairs(paths) do
            local modules = get_lua_modules_in_path(path)

            for _, module in ipairs(modules) do
                if not is_module_excluded(module) then
                    package.loaded[module] = nil
                end
            end
        end
    end

    for _, module in ipairs(M.modules_reload_external) do
        package.loaded[module] = nil
    end
end

-- Reset all Neovim configuration
local function reset_all()
    -- Clear autocmds
    cmd('autocmd!')
    local augroups = utils.split(exec("augroup", true), " ")

    for _, augroup in ipairs(augroups) do
        cmd('autocmd! ' .. augroup)
    end

    exec([[
    "" Stop LSP clients
    if exists(':LspStop')
        LspStop
    endif

    "" Clear highlights
    highlight clear

    "" Clear mappings
    mapclear
    mapclear <buffer>
    mapclear!
    mapclear! <buffer>

    "" Clear commands
    comclear

    "" Clear all global variables
    let gscope = g:

    for var in keys(gscope)
        unlet g:{var}
    endfor

    "" Unset all values
    set all&
    ]], false)

    -- Unload already loaded modules
    unload_lua_modules()
end

-- Reload Vim configuration
function M.Reload()
    -- Save path to init file
    local init_path = fn.expand('$MYVIMRC')

    -- Save runtimepath
    local runtimepath = o.runtimepath

    -- Reset everything
    reset_all()

    -- Source init file
    if string.match(init_path, '%.lua$') then
        cmd('luafile ' .. init_path)
    else
        cmd('source ' .. init_path)
    end

    -- Set runtimepath
    o.runtimepath = runtimepath

    -- Reload start plugins
    reload_runtime_files()

    -- Reload all buffers
    -- TODO: Add prompt
    cmd('bufdo edit!')
end

-- Restart Vim without having to close and run again
function M.Restart()
    -- Reload config
    M.Reload()

    -- Manually run VimEnter autocmd to emulate a new run of Vim
    cmd('doautocmd VimEnter')
end

return M
