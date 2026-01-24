-- game_service/ui/menu.lua
local i18n = require("idiomas.i18n")
local modes = require("modos")
local e = require("estado")

local utils = require("game_service.utils")
local shake = require("game_service.ui.shake")

local M = {}

function M.drawMenu()
  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
  local mx, my = love.mouse.getPosition()

  -- =========================
  -- Textos com shake pulso
  -- =========================

  love.graphics.setFont(e.ui.fontTitle)
  local title = i18n.t("menu_title")
  local titleX, titleY = 20, 20
  local titleW = e.ui.fontTitle:getWidth(title)
  local titleH = e.ui.fontTitle:getHeight()
  local titleRect = { x = titleX, y = titleY, w = titleW, h = titleH }
  local titleHover = utils.pointInRect(mx, my, titleRect)

  shake.hoverPulse("menu_title", titleHover, 0.10, 4)
  local tdx, tdy = shake.getShakeOffset("menu_title")
  love.graphics.print(title, titleX + tdx, titleY + tdy)

  love.graphics.setFont(e.ui.fontBody)
  local hint = i18n.t("menu_hint")
  local hintX, hintY = 20, 60
  local hintW = e.ui.fontBody:getWidth(hint)
  local hintH = e.ui.fontBody:getHeight()
  local hintRect = { x = hintX, y = hintY, w = hintW, h = hintH }
  local hintHover = utils.pointInRect(mx, my, hintRect)

  shake.hoverPulse("menu_hint", hintHover, 0.10, 3)
  local hdx, hdy = shake.getShakeOffset("menu_hint")
  love.graphics.print(hint, hintX + hdx, hintY + hdy)

  -- =========================
  -- Layout dos cards
  -- =========================
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

  e.ui.menu.hoverIndex = nil
  e.ui.cardRects = {}

  for i, mode in ipairs(modes) do
    local cy = y0 + (i - 1) * (cardH + gap) - scroll
    local rect = { x = x, y = cy, w = cardW, h = cardH }
    e.ui.cardRects[i] = rect

    if rect.y + rect.h >= viewTop - 60 and rect.y <= viewBottom + 60 then
      local isHover = utils.pointInRect(mx, my, rect)
      if isHover then e.ui.menu.hoverIndex = i end

      local id = "mode_" .. i
      shake.hoverPulse(id, isHover, 0.10, 5)
      local dx, dy = shake.getShakeOffset(id)
      local rx, ry = rect.x + dx, rect.y + dy

      local isFlash = (e.ui.menu.clickFlash.index == i and (e.ui.menu.clickFlash.t or 0) > 0)

      if isHover or isFlash then
        local a = isFlash and 0.22 or 0.12
        love.graphics.setColor(1, 1, 1, a)
        love.graphics.rectangle("fill", rx, ry, rect.w, rect.h)
        love.graphics.setColor(1, 1, 1, 1)
      end

      love.graphics.setLineWidth(isHover and 3 or 1)
      love.graphics.rectangle("line", rx, ry, rect.w, rect.h)
      love.graphics.setLineWidth(1)

      local thumbX, thumbY = rx + 12, ry + 12
      local thumbW, thumbH = 116, 116
      love.graphics.rectangle("line", thumbX, thumbY, thumbW, thumbH)

      if mode.image then
        local iw, ih = mode.image:getWidth(), mode.image:getHeight()
        local scale = math.min(thumbW / iw, thumbH / ih)
        local drawW, drawH = iw * scale, ih * scale
        local ddx = thumbX + (thumbW - drawW) / 2
        local ddy = thumbY + (thumbH - drawH) / 2
        love.graphics.draw(mode.image, ddx, ddy, 0, scale, scale)
      else
        love.graphics.print(i18n.t("no_image"), thumbX + 18, thumbY + 40)
      end

      local textX = thumbX + thumbW + 14
      local textW = rect.w - (textX - rx) - 12

      love.graphics.setFont(e.ui.fontTitle)
      love.graphics.print(mode.title or ("<mode " .. i .. ">"), textX, ry + 12)

      love.graphics.setFont(e.ui.fontBody)
      local lines = utils.wrapText(e.ui.fontBody, mode.description or "", textW)
      for li = 1, math.min(#lines, 5) do
        love.graphics.print(lines[li], textX, ry + 44 + (li - 1) * 18)
      end
    end
  end

  -- =========================
  -- Scrollbar simples
  -- =========================
  if maxScroll > 0 then
    local barX = x + cardW + 8
    local barY = viewTop
    local barW = 8
    local barH = viewH

    love.graphics.setColor(1, 1, 1, 0.12)
    love.graphics.rectangle("fill", barX, barY, barW, barH)
    love.graphics.setColor(1, 1, 1, 1)

    local handleH = math.max(30, barH * (viewH / totalH))
    local t = (scroll / maxScroll)
    local handleY = barY + (barH - handleH) * t

    love.graphics.setColor(1, 1, 1, 0.35)
    love.graphics.rectangle("fill", barX, handleY, barW, handleH)
    love.graphics.setColor(1, 1, 1, 1)
  end
end

return M
