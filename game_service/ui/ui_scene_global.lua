-- game_service/ui/ui_scene_global.lua
local i18n = require("idiomas.i18n")
local e = require("estado")

local M = {}

function M.layoutGlobalUI()
  if not e.ui.manager then return end

  local btnLang = e.ui.manager:get("btn_language")
  if btnLang then
    btnLang.font = e.ui.fontBody
    btnLang.label = i18n.t("btn_language")
    btnLang:setRect(e.ui.language.btn.x, e.ui.language.btn.y, e.ui.language.btn.w, e.ui.language.btn.h)
    btnLang.visible = true
  end

  local btnOpt = e.ui.manager:get("btn_options")
  if btnOpt then
    btnOpt.font = e.ui.fontBody
    btnOpt.label = i18n.t("btn_options")
    btnOpt:setRect(e.ui.options.btn.x, e.ui.options.btn.y, e.ui.options.btn.w, e.ui.options.btn.h)
    btnOpt.visible = true
  end
end

return M
