local I18N = {}

local packs = {
  ["pt-BR"] = require("idiomas.portugues"),
  ["en"]    = require("idiomas.ingles"),
}

local current = "pt-BR"

function I18N.setLanguage(code)
  if packs[code] then
    current = code
    return true
  end
  return false
end

function I18N.getLanguage()
  return current
end

function I18N.t(key)
  local pack = packs[current] or packs["pt-BR"]
  return pack[key] or ("<" .. key .. ">")
end

return I18N
