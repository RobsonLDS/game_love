local i18n = require("idiomas.i18n")
local modes = require("modos")
local e = require("estado")

local GameService = require("game_service")


-- =========================
-- love.*
-- =========================
function love.load()
  love.window.setTitle("Lua Aprendizado - LÖVE2D")
  love.math.setRandomSeed(os.time())

  e.ui.fontTitle = love.graphics.newFont(18)
  e.ui.fontBody  = love.graphics.newFont(14)

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
  GameService.mousepressed(x, y, button)
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