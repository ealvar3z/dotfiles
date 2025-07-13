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
			local lang_servers = { "bashls", "clangd", "gopls", "lua_ls", "pyright", "denols"}
			require("mason-lspconfig").setup({
				ensure_installed = lang_servers,
				automatic_installation = true,
			})

			local lspconfig = require("lspconfig")
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.publishDiagnostics = {
				relatedInformation = true,
			}
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
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "LspAttach",
		priority = 1000,
		config = function ()
			require('tiny-inline-diagnostic').setup({
				preset = "minimal",
				transparent_bg = false,
				transparent_cursorline = false,

				hi = {
					error = "DiagnosticError", -- Highlight group for error messages
					warn = "DiagnosticWarn", -- Highlight group for warning messages
					info = "DiagnosticInfo", -- Highlight group for informational messages
					hint = "DiagnosticHint", -- Highlight group for hint or suggestion messages
					arrow = "NonText", -- Highlight group for diagnostic arrows

					-- Background color for diagnostics
					-- Can be a highlight group or a hexadecimal color (#RRGGBB)
					background = "CursorLine",

					-- Color blending option for the diagnostic background
					-- Use "None" or a hexadecimal color (#RRGGBB) to blend with another color
					mixing_color = "None",
				},

				options = {
					show_source = {
						enabled = false,
						if_many = false,
					},

					-- Use icons defined in the diagnostic configuration
					use_icons_from_diagnostic = false,

					-- Set the arrow icon to the same color as the first diagnostic severity
					set_arrow_to_diag_color = false,

					-- Add messages to diagnostics when multiline diagnostics are enabled
					-- If set to false, only signs will be displayed
					add_messages = true,

					-- Time (in milliseconds) to throttle updates while moving the cursor
					-- Increase this value for better performance if your computer is slow
					-- or set to 0 for immediate updates and better visual
					throttle = 20,

					-- Minimum message length before wrapping to a new line
					softwrap = 30,

					multilines = {
						-- Enable multiline diagnostic messages
						enabled = false,

						-- Always show messages on all lines for multiline diagnostics
						always_show = false,

						-- Trim whitespaces from the start/end of each line
						trim_whitespaces = false,

						-- Replace tabs with spaces in multiline diagnostics
						tabstop = 4,
					},

					-- Display all diagnostic messages on the cursor line
					show_all_diags_on_cursorline = false,
					enable_on_insert = false,

					-- Enable diagnostics in Select mode (e.g when auto inserting with Blink)
					enable_on_select = false,

					overflow = {
						-- Manage how diagnostic messages handle overflow
						-- Options:
						-- "wrap" - Split long messages into multiple lines
						-- "none" - Do not truncate messages
						-- "oneline" - Keep the message on a single line, even if it's long
						mode = "wrap",
						padding = 0,
					},

					-- Configuration for breaking long messages into separate lines
					break_line = {
						-- Enable the feature to break messages after a specific length
						enabled = false,

						-- Number of characters after which to break the line
						after = 30,
					},

					-- Custom format function for diagnostic messages
					-- Example:
					-- format = function(diagnostic)
					--     return diagnostic.message .. " [" .. diagnostic.source .. "]"
					-- end
					format = nil,

					virt_texts = {
						-- Priority for virtual text display
						priority = 2048,
					},

					-- Filter diagnostics by severity
					-- Available severities:
					-- vim.diagnostic.severity.ERROR
					-- vim.diagnostic.severity.WARN
					-- vim.diagnostic.severity.INFO
					-- vim.diagnostic.severity.HINT
					severity = {
						vim.diagnostic.severity.ERROR,
						vim.diagnostic.severity.WARN,
						vim.diagnostic.severity.INFO,
						vim.diagnostic.severity.HINT,
					},
					overwrite_events = nil,
				},
				disabled_ft = {} -- List of filetypes to disable the plugin
			})
			vim.diagnostic.config({ virtual_text = false })
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
vim.cmd [[colorscheme default]]
vim.cmd [[map ; :]]
vim.cmd [[inoremap jk <Esc>]]
vim.cmd [[digraph  XR 8891    " ⊻  XOR]]
vim.cmd [[digraph  NA 8892    " ⊼  NAND]]
vim.cmd [[digraph  NR 8893    " ⊽  NOR]]

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader><leader>", ":nohl<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>c", ":cnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>p", ":cprevious<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>q", ":cwindow<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<C-k>", ":tabnext<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<C-j>", ":tabprevious<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<C-t>', ':tabnew | :Ex<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<C-w>', ':tabclose<CR>', {noremap = true, silent = true})

-- Filetype specific settings

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.opt_local.expandtab = true  -- Use spaces instead of tabs
    vim.opt_local.shiftwidth = 2    -- Indentation amount
    vim.opt_local.softtabstop = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.expandtab = true  -- Use spaces instead of tabs
    vim.opt_local.shiftwidth = 4    -- Indentation amount
    vim.opt_local.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = {"c", "cpp"},
  callback = function()
    vim.opt_local.expandtab = false  -- Use tabs instead of spaces
    vim.opt_local.shiftwidth = 4     -- Indentation amount
    vim.opt_local.softtabstop = 8
	vim.opt_local.expandtab = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "bash",
  callback = function()
    vim.opt_local.expandtab = true  -- Use spaces instead of tabs
    vim.opt_local.shiftwidth = 2    -- Indentation amount
    vim.opt_local.softtabstop = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "perl",
  callback = function()
    vim.opt_local.expandtab = true  -- Use spaces instead of tabs
    vim.opt_local.shiftwidth = 2    -- Indentation amount
    vim.opt_local.softtabstop = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.expandtab = false  -- Use tabs instead of spaces
    vim.opt_local.shiftwidth = 4     -- Indentation amount
    vim.opt_local.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript",
  			  "javascriptreact",
			  "javascript.jsx",
			  "typescript",
			  "typescriptreact",
			  "typescript.tsx"
		  },
  callback = function()
    vim.opt_local.expandtab = true  -- Use spaces instead of tabs
    vim.opt_local.shiftwidth = 4     -- Indentation amount
    vim.opt_local.softtabstop = 4
  end,
})

vim.g.markdown_fenced_languages = {
	"ts=typescript"
}
