-- plugins.lua
return {
  {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate", opts = {
    ensure_installed = {
      "bash",
      "c",
      "go",
      "lua",
      "ocaml",
      "perl",
      "python",
      "scheme",
    },
    auto_install = true,
    highlight = {enable = true},
  }},

  {"nvim-telescope/telescope.nvim", dependencies = {"nvim-lua/plenary.nvim"}},

  "tpope/vim-commentary",
  "tpope/vim-surround",
  "jpalardy/vim-slime",
  {"folke/which-key.nvim", opts = {}},
  {"hrsh7th/nvim-cmp", opts = {}},

  {"dense-analysis/ale", config = function()
  vim.g.ale_fix_on_save = 1
  vim.g.ale_completion_enabled = 1
  vim.g.ale_linters = {
    bash = {'shellcheck'},
    c = {'clang'}, 
    go = {'gopls'}, 
    lua = {'luacheck'},
    ocaml = {'ocamlmerlin'}, 
    perl = {'perlcritic'},
    python = {'ruff', 'mypy'}, 
    scheme = {'guile'},
    sh = {'shellcheck'}, 
  }
  vim.g.ale_fixers = {
    bash = {'shfmt'}, 
    c = {'clang-format'}, 
    go = {'goimports'},
    lua = {'stylua'}, 
    ocaml = {'ocamlformat'},
    perl = {'perltidy'}, 
    python = {'ruff'}, 
    sh = {'shfmt'},
  }
end},
}
