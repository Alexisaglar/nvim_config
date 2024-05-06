-- telescope 
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fp", ":Telescope git_files<cr>")
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>fo", ":Telescope oldfiles<cr>")

-- tree
vim.keymap.set("n", "<leader>t", ":NvimTreeFindFileToggle<cr>")

-- toggle comments
vim.keymap.set({"n", "v"}, "<leader>/", ":CommentToggle<cr>")

