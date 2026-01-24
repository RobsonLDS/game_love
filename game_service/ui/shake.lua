-- game_service/ui/shake.lua
local M = {}

-- Estado interno do shake (sem depender de "estado.lua")
local _state = {
  prevHover = {}, -- id -> bool
  items = {}      -- id -> { t, duration, strength }
}

function M.pulseShake(id, duration, strength)
  local s = _state.items[id]
  if not s then
    s = { t = 0, duration = duration or 0.10, strength = strength or 5 }
    _state.items[id] = s
  end
  s.duration = duration or s.duration
  s.strength = strength or s.strength
  s.t = s.duration
end

-- chama isso quando você tem o boolean de hover daquele elemento
function M.hoverPulse(id, isHover, duration, strength)
  local wasHover = _state.prevHover[id] == true

  -- entrada no hover -> pulso
  if isHover and not wasHover then
    M.pulseShake(id, duration, strength)
  end

  _state.prevHover[id] = isHover == true
end

function M.updateShakes(dt)
  for _, s in pairs(_state.items) do
    if s.t and s.t > 0 then
      s.t = s.t - dt
      if s.t < 0 then s.t = 0 end
    end
  end
end

function M.getShakeOffset(id)
  local s = _state.items[id]
  if not s or not s.t or s.t <= 0 then return 0, 0 end

  return love.math.random(-s.strength, s.strength),
         love.math.random(-s.strength, s.strength)
end

-- (opcional) util pra debug/reset
function M.reset()
  _state.prevHover = {}
  _state.items = {}
end

return M
