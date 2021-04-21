local M = {}

local Path = require('plenary.path')

-- Check if path exists
function M.path_exists(path)
    return Path:new(path):exists()
end

-- Split string containing elements separated by delimiter into table
function M.split(str, delim)
    local elems = {}

    for elem in string.gmatch(str, string.format('[^%s]+', delim)) do
        elems[#elems+1] = elem
    end

    return elems
end

-- Run function on each element of table and return table containing the results
function M.map(tbl, func)
    local res = {}

    for k, v in pairs(tbl) do
        local new_k, new_v = func(k, v)
        res[new_k] = new_v
    end

    return res
end

-- Escape lua string for pattern-matching
function M.escape_str(str)
    local patterns_to_escape = {
        '%^',
        '%$',
        '%(',
        '%)',
        '%%',
        '%.',
        '%[',
        '%]',
        '%*',
        '%+',
        '%-',
        '%?'
    }

    return string.gsub(
        str,
        string.format("([%s])", table.concat(patterns_to_escape)),
        '%%%1'
    )
end

return M
