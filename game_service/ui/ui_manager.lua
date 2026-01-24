-- ui/ui_manager.lua
-- Um gerenciador simples de UI:
-- - registra elementos (com zIndex opcional)
-- - update/draw em lote
-- - dispatch de mousepressed (top-most ganha)
-- - utilitários pra limpar/pegar elementos por id

local UIManager = {}
UIManager.__index = UIManager

function UIManager:new()
  return setmetatable({
    elements = {},   -- lista (ordenada por z)
    byId = {},       -- id -> element
    dirty = true,    -- precisa reordenar
  }, self)
end

function UIManager:clear()
  self.elements = {}
  self.byId = {}
  self.dirty = true
end

function UIManager:add(el, zIndex)
  if not el then return nil end
  if not el.id then
    error("UIManager:add() -> elemento precisa ter .id")
  end

  -- se já existe, remove antes (pra evitar duplicação)
  if self.byId[el.id] then
    self:remove(el.id)
  end

  el.zIndex = zIndex or el.zIndex or 0

  table.insert(self.elements, el)
  self.byId[el.id] = el
  self.dirty = true
  return el
end

function UIManager:remove(id)
  local el = self.byId[id]
  if not el then return end

  for i = #self.elements, 1, -1 do
    if self.elements[i].id == id then
      table.remove(self.elements, i)
      break
    end
  end

  self.byId[id] = nil
  self.dirty = true
end

function UIManager:get(id)
  return self.byId[id]
end

function UIManager:_sortIfNeeded()
  if not self.dirty then return end
  table.sort(self.elements, function(a, b)
    local za = a.zIndex or 0
    local zb = b.zIndex or 0
    if za == zb then
      -- fallback: ordem estável por id pra evitar “piscadas” em empate
      return tostring(a.id) < tostring(b.id)
    end
    return za < zb
  end)
  self.dirty = false
end

function UIManager:update(dt)
  self:_sortIfNeeded()

  local mx, my = love.mouse.getPosition()
  for _, el in ipairs(self.elements) do
    if el.visible ~= false and el.update then
      el:update(dt, mx, my)
    end
  end
end

function UIManager:draw()
  self:_sortIfNeeded()

  for _, el in ipairs(self.elements) do
    if el.visible ~= false and el.draw then
      el:draw()
    end
  end
end

-- Dispatch:
-- - percorre de trás pra frente (maior z primeiro)
-- - primeiro que “consome” o clique para
-- - consumo pode ser:
--   a) el.mousepressed retorna true
--   b) se mousepressed existe e hitTest bateu, assume consumido (fallback)
function UIManager:mousepressed(x, y, button)
  self:_sortIfNeeded()

  for i = #self.elements, 1, -1 do
    local el = self.elements[i]
    if el.visible ~= false and el.enabled ~= false then
      local hit = el.hitTest and el:hitTest(x, y) or false
      if hit then
        if el.mousepressed then
          local consumed = el:mousepressed(x, y, button)
          if consumed == nil then
            -- fallback: se clicou em algo clicável, considera consumido
            return true
          end
          if consumed then return true end
        else
          return true
        end
      end
    end
  end

  return false
end

return UIManager
