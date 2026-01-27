-- game_service/input_actions.lua
local modes = require("modos")
local e = require("estado")
local menuScene = require("game_service.ui.ui_scene_menu")
local modalsScene = require("game_service.ui.ui_scene_modals")
local utils = require("game_service.utils")
local modesSvc = require("game_service.modes") -- startMode/goToMenu
local M = {}

function M.mousepressed(x, y, button)
  if button ~= 1 then return end

  -- garante que tudo existe
  menuScene.ensureMenuUI()
  modalsScene.ensureModalsUI()

  -- UIManager decide quem recebe (top-most zIndex ganha)
  if e.ui.manager and e.ui.manager:mousepressed(x, y, button) then
    return
  end

  -- se quiser cliques manuais extras no futuro, entram aqui
end

function M.keypressed(key)
  -- ESC fecha modais
  if e.ui.options.open then
    if key == "escape" then e.ui.options.open = false end
    return
  end
  if e.ui.language.open then
    if key == "escape" then e.ui.language.open = false end
    return
  end
  if e.ui.saves.open then
    if key == "escape" then e.ui.saves.open = false end
    return
  end

  -- atualizado com o esc salvando no banco
  if e.state == "game" then
    if key == "escape" then
      -- ✅ encerra o modo atual (salva score, limpa UI, etc.)
      if e.activeMode and e.activeMode.finish then
        e.activeMode:finish()
      end

      -- ✅ volta pro menu
      modesSvc.goToMenu()
    end
  elseif e.state == "menu" then
    if key == "escape" then love.event.quit() end
  end

end

return M
