local utils = require("game_service.utils")
local shake = require("game_service.ui.shake")

local M = {}

function M.drawButton(rect, label, id, duration, strength)
  local mx, my = love.mouse.getPosition()
  local hover = utils.pointInRect(mx, my, rect)

  id = id or ("btn_" .. tostring(rect.x) .. "_" .. tostring(rect.y))

  shake.hoverPulse(id, hover, duration or 0.10, strength or 4)
  local dx, dy = shake.getShakeOffset(id)

  local x, y = rect.x + dx, rect.y + dy

  love.graphics.rectangle("line", x, y, rect.w, rect.h)
  love.graphics.printf(label, x, y + 8, rect.w, "center")
end

return M