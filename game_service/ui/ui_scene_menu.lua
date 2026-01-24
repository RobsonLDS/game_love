-- game_service/ui/ui_scene_menu.lua
local i18n = require("idiomas.i18n")
local modes = require("modos")
local e = require("estado")

local UIManager = require("game_service.ui.ui_manager")
local Label = require("game_service.ui.label")
local Button = require("game_service.ui.button_element")
local Card = require("game_service.ui.card")

local utils = require("game_service.utils")
local modesSvc = require("game_service.modes")

local M = {}

local function ensureManager()
  e.ui.manager = e.ui.manager or UIManager:new()
  return e.ui.manager
end

-- Garante que os elementos do MENU existam (cria uma vez)
function M.ensureMenuUI()
  local ui = ensureManager()
  e.ui._menuUI = e.ui._menuUI or { created = false }

  if e.ui._menuUI.created then
    return ui
  end

  -- =========
  -- Labels
  -- =========
  local titleLabel = Label:new({
    id = "menu_title",
    font = e.ui.fontTitle,
    text = i18n.t("menu_title"),
    shakeDuration = 0.10,
    shakeStrength = 4,
  })

  local hintLabel = Label:new({
    id = "menu_hint",
    font = e.ui.fontBody,
    text = i18n.t("menu_hint"),
    shakeDuration = 0.10,
    shakeStrength = 3,
  })

  ui:add(titleLabel, 10)
  ui:add(hintLabel, 10)

  -- =========
  -- Botões globais
  -- =========
  local btnLang = Button:new({
    id = "btn_language",
    font = e.ui.fontBody,
    label = i18n.t("btn_language"),
    shakeDuration = 0.10,
    shakeStrength = 4,
    onClick = function()
      e.ui.language.open = true
    end
  })

  local btnOpt = Button:new({
    id = "btn_options",
    font = e.ui.fontBody,
    label = i18n.t("btn_options"),
    shakeDuration = 0.10,
    shakeStrength = 4,
    onClick = function()
      e.ui.options.open = true
    end
  })

  ui:add(btnLang, 50)
  ui:add(btnOpt, 50)

  -- =========
  -- Cards (um por modo)
  -- =========
  e.ui._menuUI.cards = {}
  for i, mode in ipairs(modes) do
    local card = Card:new({
      id = "mode_" .. i,
      mode = mode,
      titleFont = e.ui.fontTitle,
      bodyFont = e.ui.fontBody,
      shakeDuration = 0.10,
      shakeStrength = 5,
      onClick = function(self)
        e.ui.menu.clickFlash.index = i
        e.ui.menu.clickFlash.t = 0.12
        modesSvc.startMode(self.mode)
      end
    })
    ui:add(card, 0)
    e.ui._menuUI.cards[i] = card
  end

  e.ui._menuUI.created = true
  return ui
end

-- Atualiza posições e textos (chame TODO frame no render ou quando mudar layout)
function M.layoutMenuUI()
  local ui = M.ensureMenuUI()

  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()

  -- atualiza textos (para mudar idioma “ao vivo”)
  local titleEl = ui:get("menu_title")
  local hintEl  = ui:get("menu_hint")
  if titleEl then
    titleEl.font = e.ui.fontTitle
    titleEl:setText(i18n.t("menu_title"))
    titleEl:autoRect(20, 20)
  end
  if hintEl then
    hintEl.font = e.ui.fontBody
    hintEl:setText(i18n.t("menu_hint"))
    hintEl:autoRect(20, 60)
  end

  -- botões globais: usa o layout calculado em layoutUI()
  local btnLang = ui:get("btn_language")
  if btnLang then
    btnLang.font = e.ui.fontBody
    btnLang.label = i18n.t("btn_language")
    btnLang:setRect(e.ui.language.btn.x, e.ui.language.btn.y, e.ui.language.btn.w, e.ui.language.btn.h)
  end

  local btnOpt = ui:get("btn_options")
  if btnOpt then
    btnOpt.font = e.ui.fontBody
    btnOpt.label = i18n.t("btn_options")
    btnOpt:setRect(e.ui.options.btn.x, e.ui.options.btn.y, e.ui.options.btn.w, e.ui.options.btn.h)
  end

  -- =========
  -- Cards com scroll (mantém sua lógica)
  -- =========
  local cardW = math.min(560, sw - 40)
  local cardH = 140
  local x, y0, gap = 20, 100, 16

  local viewTop = y0
  local viewBottom = sh - 70
  local viewH = math.max(120, viewBottom - viewTop)

  local totalH = #modes * cardH + math.max(0, #modes - 1) * gap
  local maxScroll = math.max(0, totalH - viewH)
  e.ui.menu.maxScroll = maxScroll

  e.ui.menu.scrollTarget = utils.clamp(e.ui.menu.scrollTarget or 0, 0, maxScroll)
  e.ui.menu.scrollY = utils.clamp(e.ui.menu.scrollY or 0, 0, maxScroll)

  local scroll = e.ui.menu.scrollY or 0

  -- Atualiza e.ui.cardRects pra compatibilidade com seu código antigo (se você ainda usa)
  e.ui.cardRects = {}

  e.ui.menu.hoverIndex = nil
  local mx, my = love.mouse.getPosition()

  for i = 1, #modes do
    local cy = y0 + (i - 1) * (cardH + gap) - scroll
    local rect = { x = x, y = cy, w = cardW, h = cardH }
    e.ui.cardRects[i] = rect

    local card = ui:get("mode_" .. i)
    if card then
      card:setRect(rect.x, rect.y, rect.w, rect.h)

      -- (opcional) hoverIndex compatível
      if utils.pointInRect(mx, my, rect) then
        e.ui.menu.hoverIndex = i
      end

      -- performance simples: esconde se muito fora
      local visible = (rect.y + rect.h >= viewTop - 60 and rect.y <= viewBottom + 60)
      card.visible = visible
    end
  end

  return ui
end

return M
