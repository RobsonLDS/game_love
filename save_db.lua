-- save_db.lua
local ok, sqlite3 = pcall(require, "lsqlite3")
if not ok then
  error(
    "SQLite não disponível: módulo 'lsqlite3' não encontrado.\n" ..
    "Você precisa colocar 'lsqlite3.dll' (compatível com LuaJIT/Love2D) na pasta do projeto " ..
    "ou configurar o package.cpath.\n\nErro original:\n" .. tostring(sqlite3)
  )
end

local SaveDB = {}
SaveDB.__index = SaveDB

SaveDB.PROFILES = 3
SaveDB.SAVES_DIR = "saves" -- dentro do love.filesystem (save directory)
SaveDB.FILES = {
  "profile1.sqlite",
  "profile2.sqlite",
  "profile3.sqlite",
}

local function ensure_saves_folder()
  if not love.filesystem.getInfo(SaveDB.SAVES_DIR, "directory") then
    love.filesystem.createDirectory(SaveDB.SAVES_DIR)
  end
end

local function ensure_db_schema(db)
  db:exec([[
    CREATE TABLE IF NOT EXISTS game_scores (
      id    INTEGER PRIMARY KEY AUTOINCREMENT,
      score INTEGER NOT NULL
    );
  ]])
end

local function db_path_for_profile(profileIndex)
  profileIndex = tonumber(profileIndex) or 1
  if profileIndex < 1 then profileIndex = 1 end
  if profileIndex > SaveDB.PROFILES then profileIndex = SaveDB.PROFILES end

  return SaveDB.SAVES_DIR .. "/" .. SaveDB.FILES[profileIndex]
end

-- Cria os 3 db.sqlite (se não existirem) e garante tabela
function SaveDB.bootstrap()
  ensure_saves_folder()

  for i = 1, SaveDB.PROFILES do
    local path = db_path_for_profile(i)

    -- abre (cria se não existir)
    local db = sqlite3.open(love.filesystem.getSaveDirectory() .. "/" .. path)
    ensure_db_schema(db)
    db:close()
  end
end

function SaveDB.new(profileIndex)
  local self = setmetatable({}, SaveDB)
  self.profileIndex = profileIndex or 1
  self.db = nil
  self:open(self.profileIndex)
  return self
end

function SaveDB:open(profileIndex)
  self.profileIndex = profileIndex or 1

  ensure_saves_folder()
  local path = db_path_for_profile(self.profileIndex)

  if self.db then
    self.db:close()
    self.db = nil
  end

  self.db = sqlite3.open(love.filesystem.getSaveDirectory() .. "/" .. path)
  ensure_db_schema(self.db)
end

function SaveDB:close()
  if self.db then
    self.db:close()
    self.db = nil
  end
end

function SaveDB:insert_score(score)
  if not self.db then return false, "db not open" end

  score = tonumber(score) or 0
  local stmt = self.db:prepare("INSERT INTO game_scores(score) VALUES (?);")
  stmt:bind_values(score)
  local ok = stmt:step() == sqlite3.DONE
  stmt:finalize()

  return ok
end

return SaveDB