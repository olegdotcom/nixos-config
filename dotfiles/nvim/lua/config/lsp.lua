local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Global configuration for all LSP servers
vim.lsp.config("*", {
  capabilities = capabilities,
})

-- Global LspAttach autocommand for buffer-local settings and on_attach logic
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr = args.buf

    -- Optional: format on save
    if client and client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false, bufnr = bufnr })
        end,
      })
    end
  end,
})

-- Lua
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})

-- Enable servers: Lua, Go, C/C++, Nix
vim.lsp.enable({ "lua_ls", "gopls", "clangd", "nil_ls" })

