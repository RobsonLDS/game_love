package.cpath = package.cpath .. ";./libs/?.dll"

local i18n = require("idiomas.i18n")
local modes = require("modos")
local e = require("estado")
local SaveDB = require("save_db")

local GameService = require("game_service")


-- =========================
-- love.*
-- =========================
function love.load()
  love.window.setTitle("Pega Quadrado")

  -- ✅ carrega o ícone
  local iconData = love.image.newImageData("assets/icon.png")
  love.window.setIcon(iconData)

  love.math.setRandomSeed(os.time())

  -- garante que existam os 3 dbs ao abrir pela primeira vez (ou qualquer vez)
  SaveDB.bootstrap()

  -- profile padrão = 1 (usa o estado)
  e.save.profileIndex = e.save.profileIndex or 1
  e.save.db = SaveDB.new(e.save.profileIndex)

  e.ui.fontTitle = love.graphics.newFont(18)
  e.ui.fontBody  = love.graphics.newFont(14)

  local UIManager = require("game_service.ui.ui_manager")
  e.ui.manager = e.ui.manager or UIManager:new()

  -- carrega assets dos modos para aparecer no menu
  for _, m in ipairs(modes) do
    if m.loadAssets then m:loadAssets() end
  end

  GameService.applyLocaleAllModes()

  -- janela inicial
  e.ui.options.sizeKey = "medio"
  e.ui.options.fullscreen = false
  e.ui.options.lastWindowedSizeKey = "medio"
  GameService.applyWindowMode()

  GameService.goToMenu()
end

function love.quit()
  if e.save and e.save.db then e.save.db:close() end
end

function love.update(dt)
  GameService.update(dt)

  -- ✅ tenta recuperar foco automaticamente após setMode
  if e.ui.pendingRefocus and not love.window.hasFocus() then
    -- tenta trazer a janela pra frente (funciona em várias situações)
    love.window.requestAttention(true)
  end

  -- ✅ isso aqui faltou
  if e.state == "game" and e.activeMode and not e.isAnyModalOpen() then
    e.activeMode:update(dt, i18n)
  end
end

function love.draw()
  GameService.render(i18n)
end

function love.wheelmoved(x, y)
  GameService.wheelmoved(x, y)
end

function love.mousepressed(x, y, button)
  if button ~= 1 then return end

  -- ✅ UI sempre tem prioridade (menu, game, modais, tudo)
  if e.ui.manager and e.ui.manager:mousepressed(x, y, button) then
    return
  end

  -- ✅ se não foi consumido pela UI, passa pro modo do jogo
  if e.state == "game" and e.activeMode and e.activeMode.mousepressed then
    e.activeMode:mousepressed(x, y, button, i18n)
  end
end

function love.keypressed(key)
  GameService.keypressed(key)
end

function love.focus(focused)
  e.windowFocused = focused

  -- quando voltar a focar, limpa a flag
  if focused then
    e.ui.pendingRefocus = false
  end
end