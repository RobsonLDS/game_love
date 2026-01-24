-- game_service/render.lua
local e = require("estado")
local layout = require("game_service.layout")
local menuScene = require("game_service.ui.ui_scene_menu")
local modalsScene = require("game_service.ui.ui_scene_modals")

local M = {}

function M.render(i18n)
  layout.layoutUI()

  if e.state == "menu" then
    local ui = menuScene.layoutMenuUI()
    modalsScene.layoutModalsUI()  -- ✅ posiciona/mostra modais se abertos
    ui:draw()
  elseif e.state == "game" and e.activeMode then
    e.activeMode:draw(i18n)
    modalsScene.layoutModalsUI()
    e.ui.manager:draw()
  end
end

return M
