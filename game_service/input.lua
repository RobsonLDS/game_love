-- game_service/input.lua
local e = require("estado")
local utils = require("game_service.utils")

local M = {}

function M.wheelmoved(x, y)
  -- scroll só no menu e quando não tiver modal aberto
  if e.state ~= "menu" then return end
  if e.isAnyModalOpen() then return end

  local m = e.ui.menu
  local speed = 80
  m.scrollTarget = (m.scrollTarget or 0) - y * speed
  m.scrollTarget = utils.clamp(m.scrollTarget, 0, m.maxScroll or 0)

  -- se você tiver “suavização” com lerp em outro lugar, mantém.
  -- caso contrário, você pode fazer: m.scrollY = m.scrollTarget
  -- (vou manter como você já vinha usando)
end

return M
