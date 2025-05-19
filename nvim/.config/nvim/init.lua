-- bootstrap lazy

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
	"git", "clone", "--filter=blob:none",
	"https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

	{
		"folke/lazy.nvim",
	},
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			local lang_servers = { "bashls", "clangd", "gopls", "lua_ls", "pyright" }
			require("mason-lspconfig").setup({
				ensure_installed = lang_servers,
				automatic_installation = true,
			})

			local lspconfig = require("lspconfig")
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local servers = lang_servers

			for _, s in ipairs(servers) do
				if s == "lua_ls" then
					lspconfig.lua_ls.setup({
						capabilities = capabilities,
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
				else
					lspconfig[s].setup({
						capabilities = capabilities,
						on_attach = on_attach,
					})
				end
			end
		end
	},

	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/Luasnip",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),

				}),
				sources = { { name = "nvim_lsp" } },
			})
		end
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "c", "cpp", "lua", "make", "go", "python"},
				highlight = { enable = true },
			})
		end
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup()
		end,
	},
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		config = function()
			require("lsp_signature").setup({
				bind = true,
				floating_window = true,
				hint_enable = false,
				handler_opts = {
					border = "rounded"
				},
				floating_window_cur_line = true, -- shows above the line
			})
		end
	},
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("toggleterm").setup({
				direction = "float",
				float_opts = {
					border = "double",
					width = 150,
					height = 40,
					winblend = 0,
				},
			})
		end,
	},
})

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.termguicolors = false
vim.opt.updatetime = 250
vim.cmd [[colorscheme ron]]

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<CR>", { noremap = true, silent = true })
vim.keymap.set("n", ";", ";", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-k>", ":tabnext<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<C-j>", ":tabprevious<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<C-t>', ':tabnew | :Ex<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<C-w>', ':tabclose<CR>', {noremap = true, silent = true})
	
