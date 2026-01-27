-- game_service/layout.lua
-- AQUI ESTÂO O POSSICIONAMENTO DOS BOTÕES DE OPÇOES DO JOGO 
-- AQUI TAMBEM ESTÂO O POSICIONAMENTO DOS MODAIS DAS OPÇÔES
local e = require("estado")
local M = {}

function M.layoutUI()
  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
  local pad, gap = 16, 10
  local bh = 36

  -- larguras
  local bwSaves = 120
  local bwLang  = 150
  local bwOpt   = 130

  -- =========================
  -- Botões globais (embaixo à direita)
  -- ordem: [ SAVES ] [ LANGUAGE ] [ OPTIONS ]
  -- =========================
  local y = sh - bh - pad

  e.ui.options.btn.w, e.ui.options.btn.h = bwOpt, bh
  e.ui.options.btn.x = sw - bwOpt - pad
  e.ui.options.btn.y = y

  e.ui.language.btn.w, e.ui.language.btn.h = bwLang, bh
  e.ui.language.btn.x = e.ui.options.btn.x - bwLang - gap
  e.ui.language.btn.y = y

  e.ui.saves.btn.w, e.ui.saves.btn.h = bwSaves, bh
  e.ui.saves.btn.x = e.ui.language.btn.x - bwSaves - gap
  e.ui.saves.btn.y = y

  -- =========================
  -- Painéis (modais) centralizados
  -- =========================
  e.ui.options.panel.w, e.ui.options.panel.h = 420, 260
  e.ui.options.panel.x = math.floor((sw - e.ui.options.panel.w) / 2)
  e.ui.options.panel.y = math.floor((sh - e.ui.options.panel.h) / 2)

  e.ui.language.panel.w, e.ui.language.panel.h = 360, 190
  e.ui.language.panel.x = math.floor((sw - e.ui.language.panel.w) / 2)
  e.ui.language.panel.y = math.floor((sh - e.ui.language.panel.h) / 2)

  e.ui.saves.panel.w, e.ui.saves.panel.h = 360, 220
  e.ui.saves.panel.x = math.floor((sw - e.ui.saves.panel.w) / 2)
  e.ui.saves.panel.y = math.floor((sh - e.ui.saves.panel.h) / 2)
end

return M
