local M = {
    _namespace = vim.api.nvim_create_namespace('bling.nvim'),
    _opts = {
        during_macros = false,
        count         = 3,
        delay         = 75,

        map = {
            asterisk = true,
            hash     = true,
            n        = true,
            N        = true,
            cmd      = false,
        }
    }
}

local function bling(cursor_start, cursor_end, count, match)
    if cursor_start[0] ~= cursor_end[0] then return end

    local line = cursor_start[1]
    local column = cursor_start[2]+1
    local len = cursor_end[2]-cursor_start[2]+1

    if count == 0 then return end

    -- we can't use nvim_buf_add_highlight as incsearch obscures it
    if match then
        vim.fn.matchdelete(match)
        match = nil
        count = count - 1
    else
        match = vim.fn.matchaddpos('Bling', { { line, column, len } })
    end

    vim.defer_fn(function()
        bling(cursor_start, cursor_end, count, match)
    end, M._opts.delay)
end

local function in_a_macro()
    return vim.fn.reg_executing() ~= ''
end

local function execute_mapping(mapping)
    return function()
        if mapping then
            local success, error = pcall(vim.cmd.normal, { mapping, bang = true })
            if not success then
                vim.notify(error, vim.log.levels.ERROR)
                return
            end
        end

        if in_a_macro() and not M._opts.during_macros then return end
        local pattern = vim.fn.getreg('/')

        local cursor_start = vim.api.nvim_win_get_cursor(0)
        vim.fn.search(pattern, 'ce')
        local cursor_end = vim.api.nvim_win_get_cursor(0)
        vim.api.nvim_win_set_cursor(0, cursor_start)

        bling(cursor_start, cursor_end, M._opts.count)
    end
end

local function execute_expr()
    if vim.fn.mode():lower() == 'v' then
        -- one of the visual modes
        return "<CR>"
    end
    if vim.fn.getcmdtype() ~= '/' and vim.fn.getcmdtype() ~= '?' then
        -- not a search
        return "<CR>"
    end

    return '<CR>:lua require"bling"._cmd_hook()<CR>'
end

M._cmd_hook = execute_mapping(nil)

function M.setup(opts)
    vim.api.nvim_set_hl(0, "Bling", {link = "IncSearch", default = true } )

    if type(opts) == "table" then
        M._opts = vim.tbl_deep_extend('force', M._opts, opts)
    end

    if M._opts.map.n then
        vim.keymap.set('n', 'n', execute_mapping('n'))
    end
    if M._opts.map.N then
        vim.keymap.set('n', 'N', execute_mapping('N'))
    end
    if M._opts.map.asterisk then
        vim.keymap.set('n', '*', execute_mapping('*'))
    end
    if M._opts.map.hash then
        vim.keymap.set('n', '#', execute_mapping('#'))
    end

    if M._opts.map.cmd then
        vim.keymap.set('c', '<CR>', execute_expr, { expr = true, silent = true })
    end
end

return M
