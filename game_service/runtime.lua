-- game_service/runtime.lua
local e = require("estado")
local menuScene = require("game_service.ui.ui_scene_menu")
local modalsScene = require("game_service.ui.ui_scene_modals")
local shake = require("game_service.ui.shake")

local M = {}

function M.update(dt)
  -- click flash do menu
  if e.ui.menu and e.ui.menu.clickFlash and (e.ui.menu.clickFlash.t or 0) > 0 then
    e.ui.menu.clickFlash.t = e.ui.menu.clickFlash.t - dt
    if e.ui.menu.clickFlash.t < 0 then e.ui.menu.clickFlash.t = 0 end
  end

  -- atualiza layout (rects) e UI hover
  if e.state == "menu" then
    menuScene.layoutMenuUI()
    modalsScene.layoutModalsUI()
    e.ui.manager:update(dt)
  else
    -- se quiser UI global também no game (botões/modal):
    modalsScene.layoutModalsUI()
    if e.ui.manager then e.ui.manager:update(dt) end
  end

  -- timers do shake
  shake.updateShakes(dt)
end

return M
