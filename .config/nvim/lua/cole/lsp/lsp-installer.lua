local mason_ok, mason = pcall(require, "mason")
local mason_lsp_ok, mason_lspconfig = pcall(require, "mason-lspconfig")

if not mason_ok or not mason_lsp_ok then
    return
end

mason.setup({
    ui = { border = "rounded" }
})

local servers = {
    "clangd",
    "pyright",
}

mason_lspconfig.setup({
    ensure_installed = servers,
})

-- This runs once whenever an LSP attaches to a buffer.
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        local opts = { buffer = ev.buf, noremap = true, silent = true }
        
        -- Essential Keymaps
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gl', vim.diagnostic.open_float, opts)
        
        -- Setup formatting command
        vim.api.nvim_buf_create_user_command(ev.buf, 'Format', function(_)
            vim.lsp.buf.format({ async = true })
        end, { desc = 'Format current buffer with LSP' })
    end,
})

for _, server in ipairs(servers) do
    vim.lsp.enable(server)
end

vim.diagnostic.config({
    virtual_text = false, -- Keeps the line clean; use 'gl' to see errors
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = { border = "rounded", source = "always" },
})
