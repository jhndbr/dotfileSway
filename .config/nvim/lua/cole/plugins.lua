local fn = vim.fn

local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system {
        "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path,
    }
    print "Installing packer close and reopen Neovim..."
    vim.cmd [[packadd packer.nvim]]
end

local status_ok, packer = pcall(require, "packer")
if not status_ok then return end

packer.init {
    display = {
        open_fn = function()
            return require("packer.util").float { border = "rounded" }
        end,
    },
}

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
  autocmd!
  autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

return packer.startup(function(use)
    use "wbthomason/packer.nvim"
    use "nvim-lua/plenary.nvim"

    use {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig",
    }
    
    use {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
    }

    use "hrsh7th/nvim-cmp"
    use "hrsh7th/cmp-nvim-lsp"
    use "hrsh7th/cmp-buffer"
    use "hrsh7th/cmp-path"
    use "hrsh7th/cmp-cmdline"
    use "saadparwaiz1/cmp_luasnip"
    use "L3MON4D3/LuaSnip"
    use "rafamadriz/friendly-snippets"

    use {
        "nvim-telescope/telescope.nvim",
        requires = { {'nvim-lua/plenary.nvim'} }
    }
    use "nvim-telescope/telescope-live-grep-args.nvim"
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

    use { "akinsho/bufferline.nvim", tag = "*" }
    use { "nvim-lualine/lualine.nvim" }

    use "lewis6991/gitsigns.nvim"
    use "numToStr/Comment.nvim"
    use "windwp/nvim-autopairs"
    use "lukas-reineke/indent-blankline.nvim"
    use "folke/todo-comments.nvim"
    use "norcalli/nvim-colorizer.lua"
    use "farmergreg/vim-lastplace"

    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)
