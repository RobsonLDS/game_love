-- dentro de um modo qualquer (ex: modos/pega_quadrado.lua)
local Label = require("game_service.ui.label")
local Button = require("game_service.ui.button_element")
local e = require("estado")

local Mode = {}
Mode.__index = Mode

local function randPos(w, h)
  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
  return love.math.random(0, sw - w), love.math.random(0, sh - h)
end

local function rectsOverlap(a, b)
  return a.x < b.x + b.w and
         b.x < a.x + a.w and
         a.y < b.y + b.h and
         b.y < a.y + a.h
end

function Mode.new()
  return setmetatable({
    id = "pega_quadrado",
    imagePath = "assets/pega-quadrado.png", -- opcional
    image = nil,
    
    -- para o banco de dados
    ended = false,
    savedScore = false,

    -- estado do jogo
    player = { x = 100, y = 100, w = 30, h = 30, speed = 220 },
    target = { x = 300, y = 200, w = 20, h = 20 },
    score = 0,
    msg = "",

    -- textos (preenchidos pelo applyLocale)
    title = "",
    description = "",
  }, Mode)
end

function Mode:loadAssets()
  if self.image == nil and love.filesystem.getInfo(self.imagePath) then
    self.image = love.graphics.newImage(self.imagePath)
  end
end

-- i18n é passado pelo main (injetado)
function Mode:applyLocale(i18n)
  self.title = i18n.t("mode_pega_title")
  self.description = i18n.t("mode_pega_desc")
end

function Mode:reset(i18n)
  self.uiIds = {} -- ✅ sempre reinicia a lista de ids desse modo

  local UIManager = require("game_service.ui.ui_manager")
  e.ui.manager = e.ui.manager or UIManager:new()
  local ui = e.ui.manager

  -- SCORE (Label UI)
  local scoreLbl = Label:new({
    id = "pega_score",
    font = e.ui.fontBody,
    text = i18n.t("game_score") .. self.score,
    shakeDuration = 0.10,
    shakeStrength = 3,
    hoverBorder = true,
    consumeClicks = true,
  })
  scoreLbl:autoRect(20, 120)
  ui:add(scoreLbl, 20)                 -- ✅ AQUI era o erro (não é e.ui:add)
  table.insert(self.uiIds, scoreLbl.id)

  -- DICA "ESC para sair" (Label UI)
  local escLbl = Label:new({
    id = "pega_esc_hint",
    font = e.ui.fontBody,
    text = i18n.t("game_back_menu"),
    shakeDuration = 0.10,
    shakeStrength = 3,
    hoverBorder = true,
    consumeClicks = true,
  })
  escLbl:autoRect(20, love.graphics.getHeight() - 40)
  ui:add(escLbl, 20)
  table.insert(self.uiIds, escLbl.id)

  -- MENSAGEM DE FEEDBACK (ex: "+1 ponto")
  local msgLbl = Label:new({
    id = "pega_msg",
    font = e.ui.fontBody,
    text = "",
    shakeDuration = 0.12,
    shakeStrength = 4,
    hoverBorder = true,
    consumeClicks = true,
  })
  msgLbl:autoRect(20, 150)
  ui:add(msgLbl, 20)
  table.insert(self.uiIds, msgLbl.id)
end

function Mode:update(dt, i18n)
  local dx, dy = 0, 0
  if love.keyboard.isDown("w") or love.keyboard.isDown("up") then dy = dy - 1 end
  if love.keyboard.isDown("s") or love.keyboard.isDown("down") then dy = dy + 1 end
  if love.keyboard.isDown("a") or love.keyboard.isDown("left") then dx = dx - 1 end
  if love.keyboard.isDown("d") or love.keyboard.isDown("right") then dx = dx + 1 end

  self.player.x = self.player.x + dx * self.player.speed * dt
  self.player.y = self.player.y + dy * self.player.speed * dt

  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
  if self.player.x < 0 then self.player.x = 0 end
  if self.player.y < 0 then self.player.y = 0 end
  if self.player.x > sw - self.player.w then self.player.x = sw - self.player.w end
  if self.player.y > sh - self.player.h then self.player.y = sh - self.player.h end

  if rectsOverlap(self.player, self.target) then
    self.score = self.score + 1
    self.msg = i18n.t("mode_pega_plus")
    self.target.x, self.target.y = randPos(self.target.w, self.target.h)

    local msgEl = e.ui.manager:get("pega_msg")
    if msgEl then
      msgEl:setText(self.msg)
      msgEl:autoRect(20, 150)

      -- 💥 shake automático ao mudar mensagem
      local shake = require("game_service.ui.shake")
      shake.pulseShake(
        msgEl.id,
        msgEl.shakeDuration or 0.12,
        msgEl.shakeStrength or 4
      )
    end
  end  
  
  -- ✅ atualiza texto do score (UI)
  local scoreEl = e.ui.manager and e.ui.manager:get("pega_score")
  if scoreEl then
    scoreEl:setText(i18n.t("game_score") .. self.score)
    scoreEl:autoRect(20, 120) -- mantém o rect do hover alinhado ao texto
  end

  -- ✅ mantém o "Esc para sair" no rodapé
  local escEl = e.ui.manager and e.ui.manager:get("pega_esc_hint")
  if escEl then
    escEl:setText(i18n.t("game_back_menu"))
    escEl:autoRect(20, love.graphics.getHeight() - 40)
  end
end

function Mode:draw(i18n)
  love.graphics.rectangle("line", self.player.x, self.player.y, self.player.w, self.player.h)
  love.graphics.rectangle("fill", self.target.x, self.target.y, self.target.w, self.target.h)
end

function Mode:destroyUI()
  if not self.uiIds or not e.ui.manager then return end
  for _, id in ipairs(self.uiIds) do
    e.ui.manager:remove(id)
  end
  self.uiIds = {}
end

function Mode:finish()
  if self.ended then return end
  self.ended = true

  -- salva score UMA VEZ
  if (not self.savedScore) and e.save and e.save.db then
    e.save.db:insert_score(self.score)
    self.savedScore = true
  end

  -- limpa UI do modo (se você já faz isso em outro lugar, ok manter aqui também)
  self:destroyUI()
end

return Mode
