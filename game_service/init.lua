-- game_service/init.lua
local GameService = {}

local utils   = require("game_service.utils")
local window  = require("game_service.window")
local modes   = require("game_service.modes")
local layout  = require("game_service.layout")
local input   = require("game_service.input")

local shake   = require("game_service.ui.shake")
local menu    = require("game_service.ui.menu")
local panels  = require("game_service.ui.panels")
local button  = require("game_service.ui.button")

local actions = require("game_service.input_actions")
local runtime = require("game_service.runtime")
local render  = require("game_service.render")

-- Exporta módulos (NÃO crie function GameService.update aqui)
for k, v in pairs(utils)   do GameService[k] = v end
for k, v in pairs(window)  do GameService[k] = v end
for k, v in pairs(modes)   do GameService[k] = v end
for k, v in pairs(layout)  do GameService[k] = v end
for k, v in pairs(input)   do GameService[k] = v end

for k, v in pairs(shake)   do GameService[k] = v end
for k, v in pairs(menu)    do GameService[k] = v end
for k, v in pairs(panels)  do GameService[k] = v end
for k, v in pairs(button)  do GameService[k] = v end

for k, v in pairs(actions) do GameService[k] = v end
for k, v in pairs(runtime) do GameService[k] = v end
for k, v in pairs(render)  do GameService[k] = v end

return GameService
