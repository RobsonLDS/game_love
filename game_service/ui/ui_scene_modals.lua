-- game_service/ui/ui_scene_modals.lua
local i18n = require("idiomas.i18n")
local e = require("estado")

local SaveLua = require("save_lua")
local Label = require("game_service.ui.label")
local Button = require("game_service.ui.button_element")
local Blocker = require("game_service.ui.blocker")
local PanelFrame = require("game_service.ui.panel_frame")

local M = {}

local function ui()
  return e.ui.manager
end

function M.ensureModalsUI()
  -- =========================
  -- GLOBAL BUTTON: SAVES (criação única)
  -- =========================
  if not ui():get("btn_saves") then
    local btnSaves = Button:new({
      id = "btn_saves",
      font = e.ui.fontBody,
      label = i18n.t("btn_saves"),
      shakeDuration = 0.10,
      shakeStrength = 4,
      hoverBorder = true,
      consumeClicks = true,
      onClick = function()
        e.ui.saves.open = true
        e.ui.language.open = false
        e.ui.options.open = false
      end
    })
    ui():add(btnSaves, 50)
  end

  if e.ui._modalsUI and e.ui._modalsUI.created then
    return
  end

  e.ui._modalsUI = { created = true }

  -- =========================
  -- OPTIONS MODAL
  -- =========================

  local btnSaves = Button:new({
    id = "btn_saves",
    text = "Saves",
    font = e.ui.fontBody,
    w = e.ui.saves.btn.w,
    h = e.ui.saves.btn.h,

    hoverBorder = true,
    shakeDuration = 0.10,
    shakeStrength = 3,

    consumeClicks = true,
    onClick = function()
      e.ui.saves.open = not e.ui.saves.open
      e.ui.options.open = false
      e.ui.language.open = false
    end
  })

  ui():add(btnSaves, 90)

  local optBlocker = Blocker:new({
    id = "modal_opt_blocker",
    clickPulse = false,   -- ✅ não treme
    consumeClicks = true,
    alpha = 0.18,
    onClickOutside = function()
      e.ui.options.open = false
    end
  })

  local optFrame = PanelFrame:new({
    id = "modal_opt_frame",
    clickPulse = false,   -- ✅ não treme
    fillAlpha = 0.00, -- se quiser leve fundo: 0.06
  })

  local optTitle = Label:new({
    id = "modal_opt_title",
    font = e.ui.fontTitle,
    text = i18n.t("options_title"),
    shakeStrength = 4,
  })

  local optLblFs = Label:new({
    id = "modal_opt_lbl_fullscreen",
    font = e.ui.fontBody,
    text = i18n.t("options_fullscreen"),
    shakeStrength = 3,
  })

  local optBtnFs = Button:new({
    id = "modal_opt_btn_fullscreen",
    font = e.ui.fontBody,
    label = "",
    shakeStrength = 4,
    onClick = function()
      local window = require("game_service.window")
      window.setFullscreen(not e.ui.options.fullscreen)
    end
  })

  local optLblSize = Label:new({
    id = "modal_opt_lbl_size",
    font = e.ui.fontBody,
    text = i18n.t("options_size"),
    shakeStrength = 3,
  })

  local optLblSizeDisabled = Label:new({
    id = "modal_opt_lbl_size_disabled",
    font = e.ui.fontBody,
    text = i18n.t("options_disable_size"),
    shakeStrength = 2,
  })

  local optBtnSmall = Button:new({
    id = "modal_opt_size_pequeno",
    font = e.ui.fontBody,
    label = "",
    shakeStrength = 4,
    onClick = function()
      if e.ui.options.fullscreen then return end
      local window = require("game_service.window")
      window.setWindowSize("pequeno")
    end
  })

  local optBtnMed = Button:new({
    id = "modal_opt_size_medio",
    font = e.ui.fontBody,
    label = "",
    shakeStrength = 4,
    onClick = function()
      if e.ui.options.fullscreen then return end
      local window = require("game_service.window")
      window.setWindowSize("medio")
    end
  })

  local optBtnBig = Button:new({
    id = "modal_opt_size_grande",
    font = e.ui.fontBody,
    label = "",
    shakeStrength = 4,
    onClick = function()
      if e.ui.options.fullscreen then return end
      local window = require("game_service.window")
      window.setWindowSize("grande")
    end
  })

  local optBtnClose = Button:new({
    id = "modal_opt_close",
    font = e.ui.fontBody,
    label = i18n.t("btn_close"),
    shakeStrength = 4,
    onClick = function()
      e.ui.options.open = false
    end
  })

  local optTip = Label:new({
    id = "modal_opt_tip",
    font = e.ui.fontBody,
    text = i18n.t("options_tip"),
    shakeStrength = 2,
  })

  -- zIndex: modais em 100+
  ui():add(optBlocker, 100)
  ui():add(optFrame,   101)
  ui():add(optTitle,   102)
  ui():add(optLblFs,   102)
  ui():add(optBtnFs,   102)
  ui():add(optLblSize, 102)
  ui():add(optLblSizeDisabled, 102)
  ui():add(optBtnSmall, 102)
  ui():add(optBtnMed,   102)
  ui():add(optBtnBig,   102)
  ui():add(optBtnClose, 102)
  ui():add(optTip,      102)

  -- =========================
  -- LANGUAGE MODAL
  -- =========================
  local langBlocker = Blocker:new({
    id = "modal_lang_blocker",
    alpha = 0.18,
    onClickOutside = function()
      e.ui.language.open = false
    end
  })

  local langFrame = PanelFrame:new({
    id = "modal_lang_frame",
    fillAlpha = 0.00,
  })

  local langTitle = Label:new({
    id = "modal_lang_title",
    font = e.ui.fontTitle,
    text = i18n.t("lang_title"),
    shakeStrength = 4,
  })

  local btnPT = Button:new({
    id = "modal_lang_pt",
    font = e.ui.fontBody,
    label = "",
    shakeStrength = 4,
    onClick = function()
      i18n.setLanguage("pt-BR")
      require("game_service.modes").applyLocaleAllModes()
      e.ui.language.open = false
    end
  })

  local btnEN = Button:new({
    id = "modal_lang_en",
    font = e.ui.fontBody,
    label = "",
    shakeStrength = 4,
    onClick = function()
      i18n.setLanguage("en")
      require("game_service.modes").applyLocaleAllModes()
      e.ui.language.open = false
    end
  })

  local langClose = Button:new({
    id = "modal_lang_close",
    font = e.ui.fontBody,
    label = i18n.t("btn_close"),
    shakeStrength = 4,
    onClick = function()
      e.ui.language.open = false
    end
  })

  local langTip = Label:new({
    id = "modal_lang_tip",
    font = e.ui.fontBody,
    text = i18n.t("lang_tip"),
    shakeStrength = 2,
  })

  ui():add(langBlocker, 110)
  ui():add(langFrame,   111)
  ui():add(langTitle,   112)
  ui():add(btnPT,       112)
  ui():add(btnEN,       112)
  ui():add(langClose,   112)
  ui():add(langTip,     112)

   -- =========================
  -- SAVES MODAL
  -- =========================
  local savesBlocker = Blocker:new({
    id = "modal_saves_blocker",
    alpha = 0.18,
    onClickOutside = function()
      e.ui.saves.open = false
    end
  })

  local savesFrame = PanelFrame:new({
    id = "modal_saves_frame",
    fillAlpha = 0.00,
  })

  local savesTitle = Label:new({
    id = "modal_saves_title",
    font = e.ui.fontTitle,
    text = "Saves",
    shakeStrength = 4,
  })

  local function selectProfile(idx)
    -- troca profile (se você tiver e.setProfile no estado, use ele)
    if e.setProfile then
      e.setProfile(idx)
    else
      e.save.profileIndex = idx
    end

    -- carrega dados do profile escolhido
    e.save.data = SaveLua.load_profile(e.save.profileIndex)

    e.ui.saves.open = false
  end

  local s1 = Button:new({
    id = "modal_save_p1",
    font = e.ui.fontBody,
    label = "Profile 1",
    shakeStrength = 4,
    hoverBorder = true,
    consumeClicks = true,
    onClick = function() selectProfile(1) end
  })

  local s2 = Button:new({
    id = "modal_save_p2",
    font = e.ui.fontBody,
    label = "Profile 2",
    shakeStrength = 4,
    hoverBorder = true,
    consumeClicks = true,
    onClick = function() selectProfile(2) end
  })

  local s3 = Button:new({
    id = "modal_save_p3",
    font = e.ui.fontBody,
    label = "Profile 3",
    shakeStrength = 4,
    hoverBorder = true,
    consumeClicks = true,
    onClick = function() selectProfile(3) end
  })

  local savesClose = Button:new({
    id = "modal_saves_close",
    font = e.ui.fontBody,
    label = i18n.t("btn_close"),
    shakeStrength = 4,
    hoverBorder = true,
    consumeClicks = true,
    onClick = function()
      e.ui.saves.open = false
    end
  })

  local savesTip = Label:new({
    id = "modal_saves_tip",
    font = e.ui.fontBody,
    text = "Escolha um profile para carregar.",
    shakeStrength = 2,
  })

  ui():add(savesBlocker, 120)
  ui():add(savesFrame,   121)
  ui():add(savesTitle,   122)
  ui():add(s1,           122)
  ui():add(s2,           122)
  ui():add(s3,           122)
  ui():add(savesClose,   122)
  ui():add(savesTip,     122)
end

function M.layoutModalsUI()
  M.ensureModalsUI()

  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()

  -- ======= TOP BUTTONS (SAVES)
  do
    local b = ui():get("btn_saves")
    if b then
      -- posiciona ao lado dos outros botões (canto superior direito)
      -- ajuste se você já tem coordenadas fixas para options/language
      local w, h = e.ui.saves.btn.w, e.ui.saves.btn.h
      local margin = 16
      local gap = 10

      -- Se você já tem btn_language e btn_options, alinha em fila:
      local bx = sw - margin - w
      local by = margin

      -- tenta colocar à esquerda do botão de language, se existir
      local langBtn = ui():get("btn_language")
      if langBtn and langBtn.x then
        bx = (langBtn.x - gap - w)
        by = langBtn.y or by
      end

      b:setRect(bx, by, w, h)

      -- mostra profile atual no texto (opcional e legal)
      local pi = (e.save and e.save.profileIndex) or 1
      b.label = "Saves (" .. tostring(pi) .. ")"
    end
  end

  -- ======= OPTIONS
  local optOpen = e.ui.options.open == true
  local op = e.ui.options.panel

  ui():get("modal_opt_blocker").visible = optOpen
  ui():get("modal_opt_frame").visible   = optOpen
  ui():get("modal_opt_title").visible   = optOpen
  ui():get("modal_opt_lbl_fullscreen").visible = optOpen
  ui():get("modal_opt_btn_fullscreen").visible = optOpen
  ui():get("modal_opt_lbl_size").visible = optOpen
  ui():get("modal_opt_lbl_size_disabled").visible = optOpen and e.ui.options.fullscreen == true
  ui():get("modal_opt_size_pequeno").visible = optOpen
  ui():get("modal_opt_size_medio").visible   = optOpen
  ui():get("modal_opt_size_grande").visible  = optOpen
  ui():get("modal_opt_close").visible = optOpen
  ui():get("modal_opt_tip").visible   = optOpen

  if optOpen then
    -- blocker cobre tela inteira e sabe o retângulo do painel
    local b = ui():get("modal_opt_blocker")
    b:setRect(0, 0, sw, sh)
    b.panelRect = { x = op.x, y = op.y, w = op.w, h = op.h }

    ui():get("modal_opt_frame"):setRect(op.x, op.y, op.w, op.h)

    -- textos
    local title = ui():get("modal_opt_title")
    title.font = e.ui.fontTitle
    title:setText(i18n.t("options_title"))
    title:autoRect(op.x + 16, op.y + 12)

    local lblFs = ui():get("modal_opt_lbl_fullscreen")
    lblFs.font = e.ui.fontBody
    lblFs:setText(i18n.t("options_fullscreen"))
    lblFs:autoRect(op.x + 16, op.y + 52)

    -- botão fullscreen
    local btnFs = ui():get("modal_opt_btn_fullscreen")
    btnFs.font = e.ui.fontBody
    btnFs.label = (e.ui.options.fullscreen and i18n.t("options_on") or i18n.t("options_off"))
    btnFs:setRect(op.x + 180, op.y + 46, 130, 32)

    local lblSize = ui():get("modal_opt_lbl_size")
    lblSize.font = e.ui.fontBody
    lblSize:setText(i18n.t("options_size"))
    lblSize:autoRect(op.x + 16, op.y + 104)

    local lblDisabled = ui():get("modal_opt_lbl_size_disabled")
    lblDisabled.font = e.ui.fontBody
    lblDisabled:setText(i18n.t("options_disable_size"))
    lblDisabled:autoRect(op.x + 16, op.y + 122)

    -- botões de tamanho
    local bx, by = op.x + 16, op.y + 144
    local bw, bh, gap = 120, 32, 10

    local b1 = ui():get("modal_opt_size_pequeno")
    b1.font = e.ui.fontBody
    b1.label = ((e.ui.options.sizeKey == "pequeno") and "* " or "") .. i18n.t("size_small")
    b1:setRect(bx + 0 * (bw + gap), by, bw, bh)

    local b2 = ui():get("modal_opt_size_medio")
    b2.font = e.ui.fontBody
    b2.label = ((e.ui.options.sizeKey == "medio") and "* " or "") .. i18n.t("size_medium")
    b2:setRect(bx + 1 * (bw + gap), by, bw, bh)

    local b3 = ui():get("modal_opt_size_grande")
    b3.font = e.ui.fontBody
    b3.label = ((e.ui.options.sizeKey == "grande") and "* " or "") .. i18n.t("size_large")
    b3:setRect(bx + 2 * (bw + gap), by, bw, bh)

    -- fechar
    local close = ui():get("modal_opt_close")
    close.font = e.ui.fontBody
    close.label = i18n.t("btn_close")
    close:setRect(op.x + op.w - 120 - 16, op.y + op.h - 34 - 16, 120, 34)

    local tip = ui():get("modal_opt_tip")
    tip.font = e.ui.fontBody
    tip:setText(i18n.t("options_tip"))
    tip:autoRect(op.x + 16, op.y + op.h - 28)
  end

  -- ======= LANGUAGE
  local langOpen = e.ui.language.open == true
  local lp = e.ui.language.panel

  ui():get("modal_lang_blocker").visible = langOpen
  ui():get("modal_lang_frame").visible   = langOpen
  ui():get("modal_lang_title").visible   = langOpen
  ui():get("modal_lang_pt").visible      = langOpen
  ui():get("modal_lang_en").visible      = langOpen
  ui():get("modal_lang_close").visible   = langOpen
  ui():get("modal_lang_tip").visible     = langOpen

  if langOpen then
    local b = ui():get("modal_lang_blocker")
    b:setRect(0, 0, sw, sh)
    b.panelRect = { x = lp.x, y = lp.y, w = lp.w, h = lp.h }

    ui():get("modal_lang_frame"):setRect(lp.x, lp.y, lp.w, lp.h)

    local title = ui():get("modal_lang_title")
    title.font = e.ui.fontTitle
    title:setText(i18n.t("lang_title"))
    title:autoRect(lp.x + 16, lp.y + 12)

    local btnW, btnH = lp.w - 32, 38
    local x = lp.x + 16
    local y1 = lp.y + 58
    local y2 = y1 + 48

    local pt = ui():get("modal_lang_pt")
    pt.font = e.ui.fontBody
    pt.label = ((i18n.getLanguage() == "pt-BR") and "* " or "") .. i18n.t("lang_pt")
    pt:setRect(x, y1, btnW, btnH)

    local en = ui():get("modal_lang_en")
    en.font = e.ui.fontBody
    en.label = ((i18n.getLanguage() == "en") and "* " or "") .. i18n.t("lang_en")
    en:setRect(x, y2, btnW, btnH)

    local close = ui():get("modal_lang_close")
    close.font = e.ui.fontBody
    close.label = i18n.t("btn_close")
    close:setRect(lp.x + lp.w - 120 - 16, lp.y + lp.h - 34 - 16, 120, 34)

    local tip = ui():get("modal_lang_tip")
    tip.font = e.ui.fontBody
    tip:setText(i18n.t("lang_tip"))
    tip:autoRect(lp.x + 16, lp.y + lp.h - 28)
  end

    -- ======= SAVES
  local savesOpen = e.ui.saves.open == true
  local sp = e.ui.saves.panel

  ui():get("modal_saves_blocker").visible = savesOpen
  ui():get("modal_saves_frame").visible   = savesOpen
  ui():get("modal_saves_title").visible   = savesOpen
  ui():get("modal_save_p1").visible       = savesOpen
  ui():get("modal_save_p2").visible       = savesOpen
  ui():get("modal_save_p3").visible       = savesOpen
  ui():get("modal_saves_close").visible   = savesOpen
  ui():get("modal_saves_tip").visible     = savesOpen

  if savesOpen then
    local b = ui():get("modal_saves_blocker")
    b:setRect(0, 0, sw, sh)
    b.panelRect = { x = sp.x, y = sp.y, w = sp.w, h = sp.h }

    ui():get("modal_saves_frame"):setRect(sp.x, sp.y, sp.w, sp.h)

    local title = ui():get("modal_saves_title")
    title.font = e.ui.fontTitle
    title:setText("Saves")
    title:autoRect(sp.x + 16, sp.y + 12)

    local btnW, btnH = sp.w - 32, 38
    local x = sp.x + 16
    local y1 = sp.y + 58
    local y2 = y1 + 48
    local y3 = y2 + 48

    local pi = (e.save and e.save.profileIndex) or 1

    local p1 = ui():get("modal_save_p1")
    p1.font = e.ui.fontBody
    p1.label = ((pi == 1) and "* " or "") .. "Profile 1"
    p1:setRect(x, y1, btnW, btnH)

    local p2 = ui():get("modal_save_p2")
    p2.font = e.ui.fontBody
    p2.label = ((pi == 2) and "* " or "") .. "Profile 2"
    p2:setRect(x, y2, btnW, btnH)

    local p3 = ui():get("modal_save_p3")
    p3.font = e.ui.fontBody
    p3.label = ((pi == 3) and "* " or "") .. "Profile 3"
    p3:setRect(x, y3, btnW, btnH)

    local close = ui():get("modal_saves_close")
    close.font = e.ui.fontBody
    close.label = i18n.t("btn_close")
    close:setRect(sp.x + sp.w - 120 - 16, sp.y + sp.h - 34 - 16, 120, 34)

    local tip = ui():get("modal_saves_tip")
    tip.font = e.ui.fontBody
    tip:setText("Escolha um profile para carregar.")
    tip:autoRect(sp.x + 16, sp.y + sp.h - 28)
  end

end

return M
