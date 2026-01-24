-- game_service/render.lua
local e = require("estado")

local layout = require("game_service.layout")
local menuScene = require("game_service.ui.ui_scene_menu")
local modalsScene = require("game_service.ui.ui_scene_modals")
local globalScene = require("game_service.ui.ui_scene_global")

local M = {}

function M.render(i18n)
  layout.layoutUI()

  -- ✅ posiciona botões globais sempre
  globalScene.layoutGlobalUI()

  if e.state == "menu" then
    menuScene.layoutMenuUI()
    modalsScene.layoutModalsUI()
    e.ui.manager:draw()

  elseif e.state == "game" and e.activeMode then
    e.activeMode:draw(i18n)

    -- ✅ modais e botões globais por cima do jogo
    modalsScene.layoutModalsUI()
    e.ui.manager:draw()
  end
end

return M
