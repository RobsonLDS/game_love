-- game_service/runtime.lua
local e = require("estado")
local menuScene = require("game_service.ui.ui_scene_menu")
local modalsScene = require("game_service.ui.ui_scene_modals")
local globalScene = require("game_service.ui.ui_scene_global")
local shake = require("game_service.ui.shake")

local M = {}

function M.update(dt)
  -- click flash do menu
  if e.ui.menu and e.ui.menu.clickFlash and (e.ui.menu.clickFlash.t or 0) > 0 then
    e.ui.menu.clickFlash.t = e.ui.menu.clickFlash.t - dt
    if e.ui.menu.clickFlash.t < 0 then e.ui.menu.clickFlash.t = 0 end
  end

  -- ✅ menu aparece só no menu (botões globais ficam)
  menuScene.setMenuVisible(e.state == "menu")

  -- ✅ layout global sempre (posição e textos dos botões)
  globalScene.layoutGlobalUI()

  if e.state == "menu" then
    menuScene.layoutMenuUI()
  else
    -- no game, só garante que menu não está visível
    menuScene.setMenuVisible(false)
  end

  -- modais sempre que necessário
  modalsScene.layoutModalsUI()

  -- UI hover/shake (botões globais + modais + (menu se estiver no menu))
  if e.ui.manager then e.ui.manager:update(dt) end

  shake.updateShakes(dt)
end

return M
