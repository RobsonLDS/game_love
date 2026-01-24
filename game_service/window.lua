-- game_service/window.lua
local e = require("estado")
local M = {}

function M.applyWindowMode()
  local opt = e.ui.options
  if opt.fullscreen then
    love.window.setMode(0, 0, { fullscreen = true, resizable = false, vsync = true })
  else
    local sz = opt.windowSizes[opt.sizeKey] or opt.windowSizes.medio
    love.window.setMode(sz.w, sz.h, { fullscreen = false, resizable = false, vsync = true })
  end

  -- ✅ pede foco de volta no próximo foco/next frame
  e.ui.pendingRefocus = true
end

function M.setFullscreen(on)
  local opt = e.ui.options
  opt.fullscreen = on and true or false
  if not opt.fullscreen then
    opt.sizeKey = opt.lastWindowedSizeKey or opt.sizeKey
  end
  M.applyWindowMode()
end

function M.setWindowSize(key)
  local opt = e.ui.options
  opt.sizeKey = key
  opt.lastWindowedSizeKey = key
  if not opt.fullscreen then
    M.applyWindowMode()
  end
end

return M
