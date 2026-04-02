vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitbelow = true
opt.splitright = true
opt.clipboard = "unnamedplus"
opt.updatetime = 250
opt.swapfile = false
opt.mouse = "a"
opt.showmode = false
opt.cursorline = true
opt.laststatus = 3
opt.wrap = false

opt.fillchars = {
  eob = "~",
}
