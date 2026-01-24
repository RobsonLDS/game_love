-- game_service/modes.lua
local i18n = require("idiomas.i18n")
local modes = require("modos")
local e = require("estado")

local M = {}

function M.applyLocaleAllModes()
  for _, m in ipairs(modes) do
    if m.applyLocale then m:applyLocale(i18n) end
  end
end

function M.goToMenu()
  e.state = "menu"
  e.activeMode = nil
end

function M.startMode(mode)
  e.activeMode = mode
  if e.activeMode.loadAssets then e.activeMode:loadAssets() end
  if e.activeMode.reset then e.activeMode:reset(i18n) end
  e.state = "game"
end

return M
