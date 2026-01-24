-- game_service/ui/panels.lua
local i18n = require("idiomas.i18n")
local e = require("estado")

local utils = require("game_service.utils")
local window = require("game_service.window")
local modesSvc = require("game_service.modes")

local shake = require("game_service.ui.shake")

local M = {}

-- =========================================================
-- Helpers de desenho (shake + hover + borda forte)
-- =========================================================
local function drawShakyText(id, font, text, x, y, mx, my)
  love.graphics.setFont(font)

  local w = font:getWidth(text)
  local h = font:getHeight()
  local rect = { x = x, y = y, w = w, h = h }
  local hover = utils.pointInRect(mx, my, rect)

  shake.hoverPulse(id, hover, 0.10, 3)
  local dx, dy = shake.getShakeOffset(id)

  love.graphics.print(text, x + dx, y + dy)

  return rect, hover
end

local function drawShakyButton(id, rect, label, font, mx, my, opts)
  opts = opts or {}
  local hover = utils.pointInRect(mx, my, rect)

  shake.hoverPulse(id, hover, opts.duration or 0.10, opts.strength or 4)
  local dx, dy = shake.getShakeOffset(id)

  local x, y = rect.x + dx, rect.y + dy

  -- fundo suave no hover (igual card/botões globais)
  if hover then
    love.graphics.setColor(1, 1, 1, opts.fillAlpha or 0.12)
    love.graphics.rectangle("fill", x, y, rect.w, rect.h, opts.round or 0, opts.round or 0)
    love.graphics.setColor(1, 1, 1, 1)
  end

  -- borda forte no hover
  love.graphics.setLineWidth(hover and (opts.lineHover or 3) or (opts.lineNormal or 1))
  love.graphics.rectangle("line", x, y, rect.w, rect.h, opts.round or 0, opts.round or 0)
  love.graphics.setLineWidth(1)

  -- label (também “anda” junto com o shake)
  love.graphics.setFont(font)
  if opts.align == "center" then
    love.graphics.printf(label, x, y + (opts.padY or 8), rect.w, "center")
  else
    love.graphics.print(label, x + (opts.padX or 12), y + (opts.padY or 8))
  end

  return hover
end

-- =========================================================
-- Painel OPÇÕES
-- =========================================================
function M.drawOptionsPanel()
  local opt = e.ui.options
  local p = opt.panel
  local mx, my = love.mouse.getPosition()

  love.graphics.rectangle("line", p.x, p.y, p.w, p.h)

  -- título (shake)
  drawShakyText("opt_title", e.ui.fontTitle, i18n.t("options_title"), p.x + 16, p.y + 12, mx, my)

  love.graphics.setFont(e.ui.fontBody)
  opt.items = {}

  local cursorY = p.y + 52

  -- texto "Fullscreen" (shake)
  drawShakyText("opt_lbl_fullscreen", e.ui.fontBody, i18n.t("options_fullscreen"), p.x + 16, cursorY, mx, my)

  -- botão fullscreen (shake + borda forte)
  local fsRect = { x = p.x + 180, y = cursorY - 6, w = 130, h = 32 }
  local labelFS = opt.fullscreen and i18n.t("options_on") or i18n.t("options_off")
  drawShakyButton("opt_toggle_fullscreen", fsRect, labelFS, e.ui.fontBody, mx, my, { align = "center", padY = 8 })

  table.insert(opt.items, { id="toggle_fullscreen", x=fsRect.x, y=fsRect.y, w=fsRect.w, h=fsRect.h })

  cursorY = cursorY + 52

  -- texto "Tamanho" (shake)
  drawShakyText("opt_lbl_size", e.ui.fontBody, i18n.t("options_size"), p.x + 16, cursorY, mx, my)

  if opt.fullscreen then
    drawShakyText("opt_lbl_size_disabled", e.ui.fontBody, i18n.t("options_disable_size"), p.x + 16, cursorY + 18, mx, my)
  end

  local sizes = {
    { key="pequeno", label=i18n.t("size_small") },
    { key="medio",   label=i18n.t("size_medium") },
    { key="grande",  label=i18n.t("size_large") },
  }

  local bx, by = p.x + 16, cursorY + 40
  local bw, bh, gap = 120, 32, 10

  for i, s in ipairs(sizes) do
    local r = { x = bx + (i - 1) * (bw + gap), y = by, w = bw, h = bh }
    local mark = (opt.sizeKey == s.key) and "* " or ""
    drawShakyButton("opt_size_" .. s.key, r, mark .. s.label, e.ui.fontBody, mx, my, { align = "left", padX = 12, padY = 8 })

    table.insert(opt.items, { id="size_"..s.key, x=r.x, y=r.y, w=r.w, h=r.h })
  end

  -- botão fechar (shake + borda forte)
  local closeW, closeH = 120, 34
  local closeRect = {
    x = p.x + p.w - closeW - 16,
    y = p.y + p.h - closeH - 16,
    w = closeW, h = closeH
  }
  drawShakyButton("opt_close", closeRect, i18n.t("btn_close"), e.ui.fontBody, mx, my, { align = "center", padY = 9 })
  table.insert(opt.items, { id="close", x=closeRect.x, y=closeRect.y, w=closeRect.w, h=closeRect.h })

  -- tip (shake)
  drawShakyText("opt_tip", e.ui.fontBody, i18n.t("options_tip"), p.x + 16, p.y + p.h - 28, mx, my)
end

function M.handleOptionsClick(mx, my)
  local opt = e.ui.options
  local p = opt.panel

  if not utils.pointInRect(mx, my, p) then
    e.ui.options.open = false
    return true
  end

  for _, it in ipairs(opt.items) do
    if utils.pointInRect(mx, my, it) then
      if it.id == "close" then
        e.ui.options.open = false
      elseif it.id == "toggle_fullscreen" then
        window.setFullscreen(not opt.fullscreen)
      elseif it.id:match("^size_") then
        if not opt.fullscreen then
          local key = it.id:gsub("^size_", "")
          window.setWindowSize(key)
        end
      end
      return true
    end
  end

  return true
end

-- =========================================================
-- Painel IDIOMA
-- =========================================================
function M.drawLanguagePanel()
  local lp = e.ui.language
  local p = lp.panel
  local mx, my = love.mouse.getPosition()

  love.graphics.rectangle("line", p.x, p.y, p.w, p.h)

  -- título (shake)
  drawShakyText("lang_title", e.ui.fontTitle, i18n.t("lang_title"), p.x + 16, p.y + 12, mx, my)

  love.graphics.setFont(e.ui.fontBody)
  lp.items = {}

  local btnW, btnH = p.w - 32, 38
  local x = p.x + 16
  local y1 = p.y + 58
  local y2 = y1 + 48

  local rPT = { x = x, y = y1, w = btnW, h = btnH }
  local markPT = (i18n.getLanguage() == "pt-BR") and "* " or ""
  drawShakyButton("lang_pt", rPT, markPT .. i18n.t("lang_pt"), e.ui.fontBody, mx, my, { align = "left", padX = 12, padY = 11 })
  table.insert(lp.items, { id="lang_pt", x=rPT.x,y=rPT.y,w=rPT.w,h=rPT.h })

  local rEN = { x = x, y = y2, w = btnW, h = btnH }
  local markEN = (i18n.getLanguage() == "en") and "* " or ""
  drawShakyButton("lang_en", rEN, markEN .. i18n.t("lang_en"), e.ui.fontBody, mx, my, { align = "left", padX = 12, padY = 11 })
  table.insert(lp.items, { id="lang_en", x=rEN.x,y=rEN.y,w=rEN.w,h=rEN.h })

  local closeW, closeH = 120, 34
  local closeRect = {
    x = p.x + p.w - closeW - 16,
    y = p.y + p.h - closeH - 16,
    w = closeW, h = closeH
  }
  drawShakyButton("lang_close", closeRect, i18n.t("btn_close"), e.ui.fontBody, mx, my, { align = "center", padY = 9 })
  table.insert(lp.items, { id="close", x=closeRect.x,y=closeRect.y,w=closeRect.w,h=closeRect.h })

  drawShakyText("lang_tip", e.ui.fontBody, i18n.t("lang_tip"), p.x + 16, p.y + p.h - 28, mx, my)
end

function M.handleLanguageClick(mx, my)
  local lp = e.ui.language
  local p = lp.panel

  if not utils.pointInRect(mx, my, p) then
    e.ui.language.open = false
    return true
  end

  for _, it in ipairs(lp.items) do
    if utils.pointInRect(mx, my, it) then
      if it.id == "close" then
        e.ui.language.open = false
      elseif it.id == "lang_pt" then
        i18n.setLanguage("pt-BR")
        modesSvc.applyLocaleAllModes()
        e.ui.language.open = false
      elseif it.id == "lang_en" then
        i18n.setLanguage("en")
        modesSvc.applyLocaleAllModes()
        e.ui.language.open = false
      end
      return true
    end
  end

  return true
end

return M
