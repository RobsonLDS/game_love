local Mode = {}
Mode.__index = Mode

local function randPos(w, h)
  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
  return love.math.random(0, sw - w), love.math.random(0, sh - h)
end

local function rectsOverlap(a, b)
  return a.x < b.x + b.w and
         b.x < a.x + a.w and
         a.y < b.y + b.h and
         b.y < a.y + a.h
end

function Mode.new()
  return setmetatable({
    id = "pega_quadrado",
    imagePath = "assets/pega-quadrado.png", -- opcional
    image = nil,

    -- estado do jogo
    player = { x = 100, y = 100, w = 30, h = 30, speed = 220 },
    target = { x = 300, y = 200, w = 20, h = 20 },
    score = 0,
    msg = "",

    -- textos (preenchidos pelo applyLocale)
    title = "",
    description = "",
  }, Mode)
end

function Mode:loadAssets()
  if self.image == nil and love.filesystem.getInfo(self.imagePath) then
    self.image = love.graphics.newImage(self.imagePath)
  end
end

-- i18n é passado pelo main (injetado)
function Mode:applyLocale(i18n)
  self.title = i18n.t("mode_pega_title")
  self.description = i18n.t("mode_pega_desc")
end

function Mode:reset(i18n)
  self.player.x, self.player.y = 100, 100
  self.score = 0
  self.msg = i18n.t("mode_pega_msg")
  self.target.x, self.target.y = randPos(self.target.w, self.target.h)
end

function Mode:update(dt, i18n)
  local dx, dy = 0, 0
  if love.keyboard.isDown("w") or love.keyboard.isDown("up") then dy = dy - 1 end
  if love.keyboard.isDown("s") or love.keyboard.isDown("down") then dy = dy + 1 end
  if love.keyboard.isDown("a") or love.keyboard.isDown("left") then dx = dx - 1 end
  if love.keyboard.isDown("d") or love.keyboard.isDown("right") then dx = dx + 1 end

  self.player.x = self.player.x + dx * self.player.speed * dt
  self.player.y = self.player.y + dy * self.player.speed * dt

  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
  if self.player.x < 0 then self.player.x = 0 end
  if self.player.y < 0 then self.player.y = 0 end
  if self.player.x > sw - self.player.w then self.player.x = sw - self.player.w end
  if self.player.y > sh - self.player.h then self.player.y = sh - self.player.h end

  if rectsOverlap(self.player, self.target) then
    self.score = self.score + 1
    self.msg = i18n.t("mode_pega_plus")
    self.target.x, self.target.y = randPos(self.target.w, self.target.h)
  end
end

function Mode:draw(i18n)
  love.graphics.print(i18n.t("game_score") .. self.score, 10, 10)
  love.graphics.print(self.msg, 10, 30)

  love.graphics.rectangle("line", self.player.x, self.player.y, self.player.w, self.player.h)
  love.graphics.rectangle("fill", self.target.x, self.target.y, self.target.w, self.target.h)

  love.graphics.print(i18n.t("game_back_menu"), 10, love.graphics.getHeight() - 20)
end

return Mode
