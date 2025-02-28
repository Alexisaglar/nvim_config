local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
	--catppuccin theme for colors
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000, 
	  config = function() 
		vim.cmd.colorscheme("catppuccin") 
	  end,
	},

	-- telescope for finding files and grep
	{
	  'nvim-telescope/telescope.nvim', tag = '0.1.6',
	   dependencies = { 'nvim-lua/plenary.nvim' }
	},
	
	-- file tree
	{
	  "nvim-tree/nvim-tree.lua",
	  version = "*",
	  lazy = false,
	  requires = {
		  "nvim-tree/nvim-web-devicons",
	  },
	  config = function()
		  require("nvim-tree").setup{}
	  end,
	},
	
	-- visualize buffer as tabs
	{'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons'},
	
	--nvim comments
	{
	  'terrortylor/nvim-comment',
	  config = function()
		  require("nvim_comment").setup({create_mappings = false})
	  end
	},

	-- save and load buffers (sessions) automatically
	{
	  'rmagatti/auto-session',
	  config = function()
		  require("auto-session").setup{
			  log_level = "error",
			  auto_session_suppress_dirs = {"~/", "~/Downloads"},
		  }
	  end
	},
	-- {
	--   	  "rcarriga/nvim-dap-ui",
	-- },
	-- {
	--   "nvim-neotest/nvim-nio"
	-- },
	-- { "rcarriga/nvim-dap-ui", dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"} },
	{ 
	  'mfussenegger/nvim-dap',
	  dependencies = {
	   	"rcarriga/nvim-dap-ui",
		'mfussenegger/nvim-dap-python',
		"nvim-neotest/nvim-nio"
	  },
	   config = function()
		local dap = require("dap")
		local dapui = require("dapui")
	
		require("dapui").setup()
		require("dap-python").setup('python')
	
		dap.listeners.before.attach.dapui_config = function()
		  dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
		  dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
		  dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
		  dapui.close()
		end
	
		vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, {})
		vim.keymap.set("n", "<leader>dc", dap.continue, {})
	    end,
	},

	
	-- LSP zero
	  {
	    'VonHeikemen/lsp-zero.nvim',
	    branch = 'v3.x',
	    lazy = true,
	    config = false,
	    init = function()
	      -- Disable automatic setup, we are doing it manually
	      vim.g.lsp_zero_extend_cmp = 0
	      vim.g.lsp_zero_extend_lspconfig = 0
	    end,
	  },
	  {
	    'williamboman/mason.nvim',
	    lazy = false,
	    config = true,
	  },

	  -- Autocompletion
	  {
	    'hrsh7th/nvim-cmp',
	    event = 'InsertEnter',
	    dependencies = {
	      {'L3MON4D3/LuaSnip'},
	    },
	    config = function()
	      -- Here is where you configure the autocompletion settings.
	      local lsp_zero = require('lsp-zero')
	      lsp_zero.extend_cmp()

	      -- And you can configure cmp even more, if you want to.
	      local cmp = require('cmp')
	      local cmp_action = lsp_zero.cmp_action()

	      cmp.setup({
		formatting = lsp_zero.cmp_format({details = true}),
		mapping = cmp.mapping.preset.insert({
		  ['<C-Space>'] = cmp.mapping.complete(),
		  ['<C-u>'] = cmp.mapping.scroll_docs(-4),
		  ['<C-d>'] = cmp.mapping.scroll_docs(4),
		  ['<C-f>'] = cmp_action.luasnip_jump_forward(),
		  ['<C-b>'] = cmp_action.luasnip_jump_backward(),
		})
	      })
	    end
	  },

	  -- LSP
	  {
	    'neovim/nvim-lspconfig',
	    cmd = {'LspInfo', 'LspInstall', 'LspStart'},
	    event = {'BufReadPre', 'BufNewFile'},
	    dependencies = {
	      {'hrsh7th/cmp-nvim-lsp'},
	      {'williamboman/mason-lspconfig.nvim'},
	    },
	    config = function()
	      -- This is where all the LSP shenanigans will live
	      local lsp_zero = require('lsp-zero')
	      lsp_zero.extend_lspconfig()

	      --- if you want to know more about lsp-zero and mason.nvim
	      --- read this: https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/integrate-with-mason-nvim.md
	      lsp_zero.on_attach(function(client, bufnr)
		-- see :help lsp-zero-keybindings
		-- to learn the available actions
		lsp_zero.default_keymaps({buffer = bufnr})
	      end)

	      require('mason-lspconfig').setup({
		ensure_installed = {
		  'pyright',  -- python
		  'tsserver', -- js, ts
		},
		handlers = {
		  lsp_zero.default_setup,
		  lua_ls = function()
		    -- (Optional) Configure lua language server for neovim
		    local lua_opts = lsp_zero.nvim_lua_ls()
		    require('lspconfig').lua_ls.setup(lua_opts)
		  end,
		}
	      })

	      -- Python environment
	      local util = require("lspconfig/util")
	      local path = util.path
	      require('lspconfig').pyright.setup {
		on_attach = on_attach,
		capabilities = capabilities,
		before_init = function(_, config)
		  default_venv_path = path.join(vim.env.HOME, "PV_location", "env", "bin", "python")
		  config.settings.python.pythonPath = default_venv_path
		end,
	      }
	    end
	  }

})

 
