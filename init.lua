vim.o.number = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.wrap = false
vim.o.winborder = "rounded"
vim.g.mapleader = " "
vim.cmd("set completeopt+=noselect")
vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
	{ src = "https://github.com/saghen/blink.cmp",                         version = vim.version.range("1.*") },
	{ src = "https://github.com/nvim-mini/mini.pick" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/catppuccin/nvim" , priority = 1000},
	{ src = "https://github.com/nvim-lualine/lualine.nvim"},
	{ src = "https://github.com/lewis6991/gitsigns.nvim"},
	{ src = "https://github.com/tpope/vim-fugitive"}
})
---@diagnostic disable-next-line: undefined-field
require("lualine").setup({ options = {theme = 'dracula'}})
require("mason").setup()
require("oil").setup()
require("mini.pick").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
	ensure_installed = {
		"lua_ls",
		"stylua",
		"pyright",
	},
})
require("gitsigns").setup()
vim.lsp.enable({ "lua_ls", "pyright" })

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = {
					"vim",
					"require",
				},
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
			telemetry = {
				enable = false,
			},
		},
	},
})

require("blink.cmp").setup({
	signature = { enabled = true },
	completion = {
		documentation = { auto_show = true, auto_show_delay_ms = 500 },
		menu = {
			auto_show = true,
			draw = {
				treesitter = { "lsp" },
				columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } },
			},
		},
	},
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("my.lsp", {}),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		if not client then
			return
		end
		-- Auto-format ("lint") on save.
		-- Usually not needed if server supports "textDocument/willSaveWaitUntil".
		if
			not client:supports_method("textDocument/willSaveWaitUntil")
			and client:supports_method("textDocument/formatting")
		then
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = vim.api.nvim_create_augroup("my.lsp", { clear = false }),
				buffer = args.buf,
				callback = function()
					vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
				end,
			})
		end
	end,
})
vim.cmd.colorscheme "catppuccin"
vim.keymap.set({ "n", "v", "x" }, "<leader>ca", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>f", ":Pick files<CR>")
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n" , '<leader>gp' , ':Gitsigns preview_hunk<CR>')
