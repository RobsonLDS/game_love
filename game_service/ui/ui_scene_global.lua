-- game_service/ui/ui_scene_global.lua
local i18n = require("idiomas.i18n")
local e = require("estado")

local M = {}

function M.layoutGlobalUI()
  if not e.ui.manager then return end

  -- SAVES (global)
  local btnSaves = e.ui.manager:get("btn_saves")
  if btnSaves then
    btnSaves.font = e.ui.fontBody
    local pi = (e.save and e.save.profileIndex) or 1
    btnSaves.label = i18n.t("btn_saves") .. " (" .. tostring(pi) .. ")"
    btnSaves:setRect(e.ui.saves.btn.x, e.ui.saves.btn.y, e.ui.saves.btn.w, e.ui.saves.btn.h)
    btnSaves.visible = true
  end

  -- LANGUAGE (global)
  local btnLang = e.ui.manager:get("btn_language")
  if btnLang then
    btnLang.font = e.ui.fontBody
    btnLang.label = i18n.t("btn_language")
    btnLang:setRect(e.ui.language.btn.x, e.ui.language.btn.y, e.ui.language.btn.w, e.ui.language.btn.h)
    btnLang.visible = true
  end

  -- OPTIONS (global)
  local btnOpt = e.ui.manager:get("btn_options")
  if btnOpt then
    btnOpt.font = e.ui.fontBody
    btnOpt.label = i18n.t("btn_options")
    btnOpt:setRect(e.ui.options.btn.x, e.ui.options.btn.y, e.ui.options.btn.w, e.ui.options.btn.h)
    btnOpt.visible = true
  end
end

return M
