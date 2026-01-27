-- estado.lua
-- =========================
-- Estado
-- =========================
local UIManager = require("game_service.ui.ui_manager")
local e = {}

e.state = "menu" -- "menu" | "game"
e.activeMode = nil

-- =========================
-- SAVE / DATABASE (SQLite)
-- =========================
e.save = {
  profileIndex = 1, -- padrão: profile 1
  db = nil,         -- aqui vai a instância SaveDB.new(1)
}

-- opcional: helper pra trocar de profile depois (já deixa pronto)
function e.setProfile(index)
  e.save.profileIndex = index or 1
  if e.save.db then
    e.save.db:open(e.save.profileIndex)
  end
end

e.ui = {

  pendingRefocus = false,
  manager = UIManager:new(),

  fontTitle = nil,
  fontBody = nil,
  cardRects = {},

  menu = {
    scrollY = 0,
    scrollTarget = 0,
    maxScroll = 0,
    hoverIndex = nil,
    clickFlash = { index = nil, t = 0 }, -- efeito rápido ao clicar
    hoverShake = {}
  },

  options = {
    open = false,
    btn = { x=0,y=0,w=130,h=36 },
    panel = { x=0,y=0,w=420,h=260 },
    items = {},

    sizeKey = "medio",
    windowSizes = {
      pequeno = { w = 800,  h = 450 },
      medio   = { w = 1100, h = 620 },
      grande  = { w = 1400, h = 800 },
    },
    fullscreen = false,
    lastWindowedSizeKey = "medio",
  },

  language = {
    open = false,
    btn = { x=0,y=0,w=150,h=36 },
    panel = { x=0,y=0,w=360,h=190 },
    items = {},
  },
  saves = {
    open = false,
    btn = { x=0,y=0,w=120,h=36 },
    panel = { x=0,y=0,w=360,h=220 },
    items = {},
  },
}

function e.isAnyModalOpen()
  return e.ui.options.open or e.ui.language.open or e.ui.saves.open
end

return e