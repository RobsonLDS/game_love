-- game_service/layout.lua
local e = require("estado")
local M = {}

function M.layoutUI()
  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
  local pad, gap = 16, 10
  local bh = 36
  local bwOpt = 130
  local bwLang = 150

  e.ui.options.btn.w, e.ui.options.btn.h = bwOpt, bh
  e.ui.options.btn.x = sw - bwOpt - pad
  e.ui.options.btn.y = sh - bh - pad

  e.ui.language.btn.w, e.ui.language.btn.h = bwLang, bh
  e.ui.language.btn.x = e.ui.options.btn.x - bwLang - gap
  e.ui.language.btn.y = e.ui.options.btn.y

  e.ui.options.panel.w, e.ui.options.panel.h = 420, 260
  e.ui.options.panel.x = math.floor((sw - e.ui.options.panel.w) / 2)
  e.ui.options.panel.y = math.floor((sh - e.ui.options.panel.h) / 2)

  e.ui.language.panel.w, e.ui.language.panel.h = 360, 190
  e.ui.language.panel.x = math.floor((sw - e.ui.language.panel.w) / 2)
  e.ui.language.panel.y = math.floor((sh - e.ui.language.panel.h) / 2)
end

return M
