-- Effective autoformat state for a buffer.
--   vim.b.autoformat   explicit per-buffer override (true/false), set by the toggle
--   vim.g.autoformat   global master switch
--   vim.g.autoformat_c C/C++/CUDA opt-in, flipped on per repo via .nvim.lua
local M = {}

local c_family = { c = true, cpp = true, cuda = true }

function M.enabled(buf)
  buf = buf or 0
  local b = vim.b[buf].autoformat
  if b ~= nil then return b end
  if vim.g.autoformat == false then return false end
  if c_family[vim.bo[buf].filetype] then return vim.g.autoformat_c == true end
  return true
end

function M.toggle(buf)
  buf = buf or 0
  vim.b[buf].autoformat = not M.enabled(buf)
  return vim.b[buf].autoformat
end

return M
