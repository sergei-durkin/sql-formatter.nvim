# sql-formatter.nvim

### 📺 Demo

https://github.com/user-attachments/assets/0e0f3ad7-f92c-44e5-bfb7-508c91c90bee

### ⚙️ Installation

Install [sql-formatter](https://github.com/sql-formatter-org/sql-formatter)

```bash
npm install sql-formatter
```

> Note: Requires Neovim >= 0.10

[Lazy](https://github.com/folke/lazy.nvim):

```lua
  {
    "sergei-durkin/sql-formatter.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },
```

### 🚀 Setup

```lua
-- Default config
require("sql-formatter").setup({
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
})

vim.api.nvim_set_keymap("n", "<leader>fs", ":FormatSql<CR>", { noremap = true, silent = true })
```

### 🔥 Credits

- **TJ DeVries:** [Magically format embedded languages in Neovim](https://www.youtube.com/watch?v=v3o9YaHBM4Q)
