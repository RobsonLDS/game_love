local M = {}

function M.pointInRect(px, py, r)
  return px >= r.x and px <= r.x + r.w and py >= r.y and py <= r.y + r.h
end

function M.clamp(v, a, b)
  if v < a then return a end
  if v > b then return b end
  return v
end

function M.lerp(a, b, t)
  return a + (b - a) * t
end

function M.wrapText(font, text, maxWidth)
  local lines = {}
  for line in (text .. "\n"):gmatch("(.-)\n") do
    local words = {}
    for w in line:gmatch("%S+") do table.insert(words, w) end

    local current = ""
    for i = 1, #words do
      local test = (current == "") and words[i] or (current .. " " .. words[i])
      if font:getWidth(test) <= maxWidth then
        current = test
      else
        table.insert(lines, current)
        current = words[i]
      end
    end
    if current ~= "" then table.insert(lines, current) end
  end
  return lines
end

return M