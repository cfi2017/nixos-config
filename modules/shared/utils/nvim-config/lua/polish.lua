-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

require("lspconfig").clangd.setup {}
require("lspconfig").rust_analyzer.setup {}
require("lspconfig").yamlls.setup {
  filetypes = { "yaml", "yaml.kubernetes", "yaml.docker-compose" },
  settings = {
    yaml = {
      schemas = {
        -- "kubernetes" is a magic keyword yamlls understands natively
        kubernetes = "/*.yaml",
      },
      -- optionally, per-filetype schema override:
      schemaStore = { enable = true },
    },
  },
}
require("lspconfig").helm_ls.setup {}

vim.filetype.add {
  pattern = {
    [".*/templates/.*%.yaml"] = "helm",
    [".*/templates/.*%.tpl"] = "helm",
    ["helmfile%.yaml"] = "helm",
  },
}

vim.filetype.add {
  pattern = {
    [".*%.yaml"] = {
      function(path, bufnr)
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 20, false)
        for _, line in ipairs(lines) do
          if line:match "^apiVersion:" then return "yaml.kubernetes" end
        end
      end,
      { priority = 10 }, -- above default yaml, below helm
    },
  },
}

-- require("lint").linters_by_ft = {
--   ["yaml.kubernetes"] = { "kubeconform" },
-- }
--

vim.keymap.set("n", "<leader>xx", function()
  local line = vim.api.nvim_get_current_line()
  if line:match "%- %[x%]" then
    line = line:gsub("%- %[x%]", "- [ ]", 1)
  elseif line:match "%- %[ %]" then
    line = line:gsub("%- %[ %]", "- [x]", 1)
  end
  vim.api.nvim_set_current_line(line)
end, { desc = "Toggle markdown checkbox" })

vim.keymap.set("v", "<leader>xx", function()
  local start_line = vim.fn.line "'<"
  local end_line = vim.fn.line "'>"
  for i = start_line, end_line do
    local result = vim.api.nvim_buf_get_lines(0, i - 1, i, false)
    local line = result[1]
    if line then
      if line:match "%- %[x%]" then
        line = line:gsub("%- %[x%]", "- [ ]", 1)
      elseif line:match "%- %[ %]" then
        line = line:gsub("%- %[ %]", "- [x]", 1)
      end
      vim.api.nvim_buf_set_lines(0, i - 1, i, false, { line })
    end
  end
end, { desc = "Toggle markdown checkboxes in selection" })
