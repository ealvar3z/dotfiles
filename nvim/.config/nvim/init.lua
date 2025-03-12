-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.opt.shell = "/bin/sh"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true

-- netrw defaults
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 3

vim.keymap.set('n', ';', ':')

-- Quickfix shortcuts
vim.keymap.set('n', '<leader>n', ':cnext<CR>')
vim.keymap.set('n', '<leader>p', ':cprev<CR>')

-- Enhanced Completion (Tab)
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}
vim.keymap.set('i', '<Tab>', 'pumvisible() ? "<C-n>" : "<Tab>"', {expr=true})

-- Load plugins
require("lazy").setup("plugins")

-- Doc command
vim.api.nvim_create_user_command('Doc', function(opts)
  local doc_cmd = {
    python = 'pydoc', perl = 'perldoc', go = 'godoc', c = 'man 3',
    sh = 'man', bash = 'man', lua = 'man lua', ocaml = 'ocamldoc',
    scheme = 'info guile'
  }
  local cmd = doc_cmd[vim.bo.filetype] or 'man'
  vim.cmd('split | term '..cmd..' '..opts.args)
end, { nargs = 1 })

vim.keymap.set('n', 'K', ':Doc <cword><CR>')

-- Filetype-specific makeprg
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"python", "perl", "sh", "bash", "c", "go", "lua", "ocaml", "scheme"},
  callback = function()
    local makeprgs = {
      python = 'python3 %',
      perl = 'perl %',
      sh = 'sh %',
      bash = 'bash %',
      c = 'make',
      go = 'go build',
      lua = 'lua %',
      ocaml = 'ocaml %',
      scheme = 'guile %'
    }
    vim.opt_local.makeprg = makeprgs[vim.bo.filetype]
  end
})

