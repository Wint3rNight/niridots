vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- Escape also clears search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr><Esc>", { desc = "Clear search highlight" })

-- Keep the cursor centred when jumping half-pages and between search hits
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Join lines without moving the cursor
map("n", "J", "mzJ`z")

-- Paste over a selection without losing what you copied
map("x", "<leader>p", [["_dP]], { desc = "Paste (keep register)" })

-- Move lines up/down
map("n", "<A-Down>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-Up>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("v", "<A-Down>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-Up>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Stay in visual mode when indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Save / quit
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to last buffer" })

-- Splits
map("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
map("n", "<leader>sx", "<cmd>close<cr>", { desc = "Close current split" })
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Taller window" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Shorter window" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Narrower window" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Wider window" })

-- Window navigation that works from ANYWHERE, including inside terminals (Claude, Ctrl-\):
-- Alt + h/j/k/l. In terminal mode it first drops to normal mode, then jumps.
for _, k in ipairs({ "h", "j", "k", "l" }) do
  map("n", "<A-" .. k .. ">", "<C-w>" .. k, { desc = "Window: go " .. k })
  map("t", "<A-" .. k .. ">", [[<C-\><C-n><C-w>]] .. k, { desc = "Window: go " .. k })
end

-- Location list
map("n", "[l", "<cmd>lprev<cr>", { desc = "Previous location-list item" })
map("n", "]l", "<cmd>lnext<cr>", { desc = "Next location-list item" })

-- Plugin managers
map("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy (plugins)" })
map("n", "<leader>M", "<cmd>Mason<cr>", { desc = "Mason (LSP/tools)" })
