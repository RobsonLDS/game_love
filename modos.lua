-- modos.lua
-- Retorna uma lista de instâncias (ou descritores) de modos disponíveis.

local PegaQuadrado = require("modos.pega_quadrado")

return {
  PegaQuadrado.new(),
}
