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
