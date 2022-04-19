local M = {}

local current_buf = 0

local function identify_import_lines(all_lines)
    local import_lines = {}
    for ind, line in ipairs(all_lines) do
        if string.match(line, '^import') then
            table.insert(import_lines, { ind - 1, line })
        end
    end

    return import_lines
end

local function remove_import_lines(line_numbers)
    for i = #(line_numbers), 1, -1 do
        local line_number = line_numbers[i]
        vim.api.nvim_buf_set_lines(current_buf, line_number, line_number + 1, false, {})
    end
end

local function replace_top(imports)
    local all_lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
    local start_ind = 0
    local num_lines = 0
    local package = nil

    -- increment until you find non-empty, non-package line
    -- if you find package, prepend it along with extra line
    for _, line in next, all_lines do
        if line == "" then
            num_lines = num_lines + 1
        elseif string.match(line, "^package") then
            package = { line, "" }
        else
            table.insert(imports, "")
            break
        end
    end

    if package then
        vim.api.nvim_buf_set_lines(current_buf, start_ind, start_ind + 1, false, package)
        start_ind = start_ind + 2
    end

    -- replace from start to end
    vim.api.nvim_buf_set_lines(current_buf, start_ind, start_ind + num_lines, false, imports)
end

local function split_path(decls)
    local typed_decls = {}
    for _, decl in next, decls do
        local segments = vim.split(decl, "%.", { trimempty = true })
        local import_decl = {}
        import_decl["identifier"] = segments[#segments]
        table.remove(segments)
        import_decl["path"] = table.concat(segments, '.') .. '.'
        table.insert(typed_decls, import_decl)
    end
    return typed_decls
end

local function merge_identifiers(pre, post)
    local merged = ""
    if (vim.startswith(pre["identifier"], "{")) then
        --replace the last char with
        merged = string.gsub(pre["identifier"], "}", ", " .. post["identifier"] .. "}")
    else
        merged = "{" .. pre["identifier"] .. ", " .. post["identifier"] .. "}"
    end

    return merged
end

local function merge_paths(import_decls)
    local removed_ind = {}
    for i, curr in pairs(import_decls) do
        local n_ind, n = next(import_decls, i)
        if n and (curr["path"] == n["path"]) then
            local merged_id = merge_identifiers(curr, n)
            import_decls[n_ind]["identifier"] = merged_id
            table.insert(removed_ind, i)
        end
    end

    table.sort(removed_ind, function (l, r) return l > r end)
    for _, ind in pairs(removed_ind) do
        table.remove(import_decls, ind)
    end

    return import_decls
end

local function group_imports(decls)
    -- split into path and value
    local typed_decls = split_path(decls)
    local result = {}

    merge_paths(typed_decls)
    for _, t_decl in pairs(typed_decls) do
        table.insert(result, t_decl["path"] .. t_decl["identifier"])
    end

    return result
end

M.organize_imports = function()
    local all_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local import_lines = identify_import_lines(all_lines)
    local line_vals = {}
    local line_nums = {}

    for _, line_info in pairs(import_lines) do
        table.insert(line_nums, line_info[1])
        table.insert(line_vals, line_info[2])
    end

    remove_import_lines(line_nums)
    table.sort(line_vals)
    local grouped_imports = group_imports(line_vals)
    replace_top(grouped_imports)
end

return M
