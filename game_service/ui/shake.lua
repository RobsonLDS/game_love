-- em ui/shake.lua
local math_sin = math.sin
local e = require("estado")
local M = {}

function M.ensureShake()
  e.ui.shake = e.ui.shake or { prevHover = {}, items = {} }
end

function M.pulseShake(id, duration, strength)
  M.ensureShake()
  local s = e.ui.shake.items[id]
  if not s then
    s = { t = 0, duration = duration or 0.10, strength = strength or 5 }
    e.ui.shake.items[id] = s
  end
  s.duration = duration or s.duration
  s.strength = strength or s.strength
  s.t = s.duration
end

function M.hoverPulse(id, isHover, duration, strength)
  M.ensureShake()
  local wasHover = e.ui.shake.prevHover[id] == true
  if isHover and not wasHover then
    M.pulseShake(id, duration, strength)
  end
  e.ui.shake.prevHover[id] = isHover == true
end

function M.updateShakes(dt)
  M.ensureShake()
  for _, s in pairs(e.ui.shake.items) do
    if s.t and s.t > 0 then
      s.t = s.t - dt
      if s.t < 0 then s.t = 0 end
    end
  end
end

function M.getShakeOffset(id)
  M.ensureShake()
  local s = e.ui.shake.items[id]
  if not s or not s.t or s.t <= 0 then return 0, 0 end

  local phase = (s.duration - s.t) * 40
  local amp = s.strength * (s.t / s.duration)

  return math_sin(phase) * amp,
         math_sin(phase * 1.3) * amp
end

function M.getShakeOffset_antigo(id)
  M.ensureShake()
  local s = e.ui.shake.items[id]
  if not s or not s.t or s.t <= 0 then return 0, 0 end
  return love.math.random(-s.strength, s.strength),
         love.math.random(-s.strength, s.strength)
end

return M