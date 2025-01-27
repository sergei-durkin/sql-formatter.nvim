local formatter = {
  config = {
    go = {
      dialect = "postgresql",
      tabWidth = 1,
      useTabs = true,
      keywordCase = "upper",
    },
    php = {
      dialect = "postgresql",
      tabWidth = 4,
      useTabs = false,
      keywordCase = "upper",
    },
  },
}

formatter.config.go.parser = vim.treesitter.query.parse(
  "go",
  [[
    ([
       (raw_string_literal)
     ] @sql
     (#match? @sql "(SELECT|select|INSERT|insert|UPDATE|update|DELETE|delete).+(FROM|from|INTO|into|VALUES|values|SET|set).*(WHERE|where|GROUP BY|group by)?")
     (#offset! @sql 0 1 0 -1))
  ]]
)

formatter.config.php.parser = vim.treesitter.query.parse(
  "php",
  [[
    ([
      (shell_command_expression)
     ] @sql
     (#match? @sql "(SELECT|select|INSERT|insert|UPDATE|update|DELETE|delete).+(FROM|from|INTO|into|VALUES|values|SET|set).*(WHERE|where|GROUP BY|group by)?")
     (#offset! @sql 0 1 0 -1))
  ]]
)

local function get_root(bufnr, ftype)
  local parser = vim.treesitter.get_parser(bufnr, ftype, {})
  local tree = parser:parse()[1]
  return tree:root()
end

local function run_formatter(line, ftype)
  local cmd = "sql-formatter"
  local c = {
    dialect = formatter.config[ftype].dialect,
    tabWidth = formatter.config[ftype].tabWidth,
    useTabs = formatter.config[ftype].useTabs,
    keywordCase = formatter.config[ftype].keywordCase,
  }

  local args = { "-l", "postgresql", "-c", "'" .. vim.json.encode(c) .. "'" }
  line = line:sub(2, -2)
  line = "echo '" .. line .. "' | " .. cmd .. " " .. table.concat(args, " ")

  local result = vim.fn.system(line)

  return vim.split(result, "\n")
end

local function format(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ftype = vim.bo[bufnr].filetype

  if ftype ~= "go" and ftype ~= "php" then
    print("Formatter not supported for this filetype")
    return
  end

  local root = get_root(bufnr, ftype)

  for _, node in formatter.config[ftype].parser:iter_captures(root, bufnr, 0, -1) do
    local range = { node:range() }
    local indentation = string.rep(formatter.config[ftype].separator, formatter.config[ftype].tabWidth)

    local from = range[1]
    local to = range[3]
    local row, _ = unpack(vim.api.nvim_win_get_cursor(0))

    if row >= from+1 and row <= to+1 then
      local formatted = run_formatter(vim.treesitter.get_node_text(node, bufnr), ftype)
      local prefix = vim.split(vim.api.nvim_buf_get_lines(0, from, from+1, false)[1], "`")[1] .. "`"
      local res = {}

      res[1] = prefix
      for idx, line in ipairs(formatted) do
        res[idx+1] = indentation .. line
      end

      res[#res] = "`"

      vim.api.nvim_buf_set_lines(bufnr, from, to+1, false, res)

      print("Formatted ".. #formatted .. " lines")
      break
    end
  end
end


formatter.setup = function(cfg)
  cfg = cfg or {}
  formatter.config = vim.tbl_deep_extend("force", formatter.config, cfg)
  vim.api.nvim_create_user_command("FormatSql", function() format() end, {})

  for key, _ in pairs(formatter.config) do
    formatter.config[key].separator = " "
    if formatter.config[key].useTabs then
      formatter.config[key].tabWidth = 1
      formatter.config[key].separator = "\t"
    end
  end

end

return formatter
