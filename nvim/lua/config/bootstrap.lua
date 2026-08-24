-- First-run helpers. Each one checks whether its job is already done and returns early,
-- so this file costs nothing on a normal startup.

-- clangd: give it CUDA flags system-wide, once, if this machine has a CUDA toolkit.
local function clangd_config()
  local dst = (vim.env.XDG_CONFIG_HOME or vim.fn.expand("~/.config")) .. "/clangd/config.yaml"
  if vim.uv.fs_stat(dst) then return end

  local cuda
  for _, p in ipairs({ "/opt/cuda", "/usr/local/cuda" }) do
    if vim.uv.fs_stat(p .. "/bin/nvcc") then cuda = p break end
  end
  if not cuda then return end

  local arch_line = ""
  if vim.fn.executable("nvidia-smi") == 1 then
    local ok, r = pcall(function()
      return vim.system({ "nvidia-smi", "--query-gpu=compute_cap", "--format=csv,noheader" }, { text = true, timeout = 3000 }):wait()
    end)
    local maj, min = ok and r.code == 0 and (r.stdout or ""):match("(%d+)%.(%d+)")
    if maj then arch_line = "    - --cuda-gpu-arch=sm_" .. maj .. min .. "\n" end
  end

  local template = vim.fn.stdpath("config") .. "/extras/clangd-config.yaml"
  local f = io.open(template, "r")
  if not f then return end
  local text = f:read("*a")
  f:close()
  text = text:gsub("@CUDA_PATH@", cuda):gsub("@GPU_ARCH_LINE@\n?", arch_line)

  vim.fn.mkdir(vim.fn.fnamemodify(dst, ":h"), "p")
  local out = io.open(dst, "w")
  if not out then return end
  out:write(text)
  out:close()
  vim.schedule(function()
    vim.notify("clangd: wrote CUDA config to " .. dst .. " (first run only)", vim.log.levels.INFO)
  end)
end

clangd_config()
