-- save_lua.lua
-- Banco relacional "fake" em arquivos .lua (1 arquivo por profile)
-- - Suporta crescimento do schema via migrations (schema_version)
-- - Estrutura: db.tables.<tabela>.rows + next_id
-- - Salva como "return { ... }" (editável)
--
-- Arquivos:
--   saves/profile1.lua
--   saves/profile2.lua
--   saves/profile3.lua

local SaveLua = {}
SaveLua.__index = SaveLua

SaveLua.SAVES_DIR = "saves"
SaveLua.PROFILES = 3
SaveLua.FILES = {
  "profile1.lua",
  "profile2.lua",
  "profile3.lua",
}

-- Versão atual do schema do seu "banco"
SaveLua.CURRENT_SCHEMA = 2

-- =========================
-- Utils: paths
-- =========================
local function ensure_dir(path)
  if not love.filesystem.getInfo(path, "directory") then
    love.filesystem.createDirectory(path)
  end
end

local function clamp_profile(i)
  i = tonumber(i) or 1
  if i < 1 then i = 1 end
  if i > SaveLua.PROFILES then i = SaveLua.PROFILES end
  return i
end

local function profile_path(i)
  i = clamp_profile(i)
  return SaveLua.SAVES_DIR .. "/" .. SaveLua.FILES[i]
end

-- =========================
-- Serializer: table -> "return {...}"
-- (suporta: number, boolean, string, table)
-- =========================
local function serialize_value(v, indent)
  indent = indent or 0
  local t = type(v)

  if t == "number" then
    return tostring(v)
  elseif t == "boolean" then
    return v and "true" or "false"
  elseif t == "string" then
    return string.format("%q", v)
  elseif t == "table" then
    local pad  = string.rep("  ", indent)
    local pad2 = string.rep("  ", indent + 1)
    local parts = { "{\n" }

    -- parte array
    local n = #v
    for i = 1, n do
      parts[#parts+1] = pad2 .. serialize_value(v[i], indent + 1) .. ",\n"
    end

    -- parte hash (ordem não garantida, mas legível)
    for k, val in pairs(v) do
      local isArrayKey = (type(k) == "number" and k >= 1 and k <= n and math.floor(k) == k)
      if not isArrayKey then
        local key
        if type(k) == "string" and k:match("^[%a_][%w_]*$") then
          key = k
        else
          key = "[" .. serialize_value(k, indent + 1) .. "]"
        end
        parts[#parts+1] = pad2 .. key .. " = " .. serialize_value(val, indent + 1) .. ",\n"
      end
    end

    parts[#parts+1] = pad .. "}"
    return table.concat(parts)
  else
    error("Tipo não suportado no save: " .. t)
  end
end

local function dump_table(tbl)
  return "return " .. serialize_value(tbl, 0) .. "\n"
end

-- =========================
-- Loader restrito: executa "return {...}" sem libs
-- =========================
local function safe_load_table(luaText)
  local chunk, err = loadstring(luaText)
  if not chunk then return nil, err end

  -- ambiente vazio: bloqueia os/io/require etc.
  setfenv(chunk, {})

  local ok, result = pcall(chunk)
  if not ok then return nil, result end
  if type(result) ~= "table" then
    return nil, "Arquivo não retornou uma tabela"
  end
  return result
end

-- =========================
-- Schema default (v1)
-- =========================
local function default_db_v1()
  return {
    schema_version = 1,
    tables = {
      -- Tabela: game_scores (id, score)
      game_scores = {
        next_id = 1,
        rows = {},
      },
    },
  }
end

-- Garante que campos essenciais existam
local function ensure_minimum_schema(db)
  if type(db) ~= "table" then db = default_db_v1() end
  if type(db.schema_version) ~= "number" then db.schema_version = 1 end
  if type(db.tables) ~= "table" then db.tables = {} end

  -- game_scores sempre deve existir
  if type(db.tables.game_scores) ~= "table" then
    db.tables.game_scores = { next_id = 1, rows = {} }
  end
  if type(db.tables.game_scores.rows) ~= "table" then
    db.tables.game_scores.rows = {}
  end
  if type(db.tables.game_scores.next_id) ~= "number" or db.tables.game_scores.next_id < 1 then
    db.tables.game_scores.next_id = 1
  end

  return db
end

-- =========================
-- Migrations
-- Regra: migrations[N] migra de (N-1) -> N
-- =========================
local migrations = {}

-- v1 -> v2: adiciona tabela game_modes (id, titulo, ativo)
migrations[2] = function(db)
  db.tables.game_modes = db.tables.game_modes or {
    next_id = 1,
    rows = {},
  }

  -- opcional: registrar um modo padrão (se quiser)
  -- table.insert(db.tables.game_modes.rows, { id = 1, titulo = "Pega Quadrado", ativo = true })
  -- db.tables.game_modes.next_id = 2
end

local function apply_migrations(db)
  db = ensure_minimum_schema(db)

  while db.schema_version < SaveLua.CURRENT_SCHEMA do
    local nextVersion = db.schema_version + 1
    local migrate = migrations[nextVersion]
    if migrate then
      migrate(db)
    else
      -- se não existir migration explícita, só sobe a versão (evita travar)
      -- mas o ideal é sempre criar migration.
    end
    db.schema_version = nextVersion
  end

  -- pós-check: garante estruturas das tabelas existentes
  if db.tables.game_modes then
    if type(db.tables.game_modes.rows) ~= "table" then db.tables.game_modes.rows = {} end
    if type(db.tables.game_modes.next_id) ~= "number" or db.tables.game_modes.next_id < 1 then
      db.tables.game_modes.next_id = 1
    end
  end

  return db
end

-- =========================
-- API pública
-- =========================
function SaveLua.bootstrap()
  ensure_dir(SaveLua.SAVES_DIR)

  for i = 1, SaveLua.PROFILES do
    local path = profile_path(i)
    if not love.filesystem.getInfo(path, "file") then
      local db = apply_migrations(default_db_v1())
      love.filesystem.write(path, dump_table(db))
    end
  end
end

function SaveLua.load_profile(i)
  i = clamp_profile(i)
  local path = profile_path(i)

  if not love.filesystem.getInfo(path, "file") then
    local db = apply_migrations(default_db_v1())
    love.filesystem.write(path, dump_table(db))
    return db
  end

  local content = love.filesystem.read(path)
  local db, err = safe_load_table(content)
  if not db then
    -- arquivo corrompido: devolve default, mas não apaga automaticamente
    return apply_migrations(default_db_v1()), ("Falha ao ler profile: " .. tostring(err))
  end

  local oldVersion = db.schema_version or 1
  db = apply_migrations(db)

  -- se migrou, salva de volta
  if (oldVersion or 1) ~= db.schema_version then
    love.filesystem.write(path, dump_table(db))
  end

  return db
end

function SaveLua.save_profile(i, db)
  i = clamp_profile(i)
  db = apply_migrations(db)
  local path = profile_path(i)
  return love.filesystem.write(path, dump_table(db))
end

-- =========================
-- Helpers de "tabelas"
-- =========================
local function get_table(db, tableName)
  db.tables = db.tables or {}
  db.tables[tableName] = db.tables[tableName] or { next_id = 1, rows = {} }
  db.tables[tableName].rows = db.tables[tableName].rows or {}
  if type(db.tables[tableName].next_id) ~= "number" or db.tables[tableName].next_id < 1 then
    db.tables[tableName].next_id = 1
  end
  return db.tables[tableName]
end

-- =========================
-- CRUD: game_scores
-- =========================
function SaveLua.insert_score(profileIndex, score)
  local db = SaveLua.load_profile(profileIndex)
  local t = get_table(db, "game_scores")

  local id = t.next_id
  local s = tonumber(score) or 0

  table.insert(t.rows, { id = id, score = s })
  t.next_id = id + 1

  SaveLua.save_profile(profileIndex, db)
  return id
end

function SaveLua.get_scores(profileIndex)
  local db = SaveLua.load_profile(profileIndex)
  local t = get_table(db, "game_scores")
  return t.rows
end

-- =========================
-- CRUD: game_modes (v2+)
-- =========================
function SaveLua.insert_game_mode(profileIndex, titulo, ativo)
  local db = SaveLua.load_profile(profileIndex)
  local t = get_table(db, "game_modes")

  local id = t.next_id
  table.insert(t.rows, {
    id = id,
    titulo = tostring(titulo or ""),
    ativo = (ativo ~= false),
  })
  t.next_id = id + 1

  SaveLua.save_profile(profileIndex, db)
  return id
end

function SaveLua.get_game_modes(profileIndex)
  local db = SaveLua.load_profile(profileIndex)
  local t = get_table(db, "game_modes")
  return t.rows
end

function SaveLua.set_game_mode_ativo(profileIndex, modeId, ativo)
  local db = SaveLua.load_profile(profileIndex)
  local t = get_table(db, "game_modes")

  for _, row in ipairs(t.rows) do
    if row.id == modeId then
      row.ativo = (ativo ~= false)
      SaveLua.save_profile(profileIndex, db)
      return true
    end
  end
  return false
end

return SaveLua
