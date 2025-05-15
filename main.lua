---@diagnostic disable: lowercase-global
local TILE_WIDTH = 64
local TILE_HEIGHT = 64
local TILES = {}
local player = {
  x = 100,
  y = 100,
}

function love.load()
  TILES = createTiles()
end

function love.update(dt)
  if love.keyboard.isDown("right") then
    player.x = player.x + 4
  elseif love.keyboard.isDown("left") then
    player.x = player.x - 4
  elseif love.keyboard.isDown("down") then
    player.y = player.y + 4
  elseif love.keyboard.isDown("up") then
    player.y = player.y - 4
  end
end

function love.draw()
  drawTiles(TILES)
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("fill", player.x, player.y, TILE_WIDTH, TILE_HEIGHT)
end

function createTiles()
  local screenWidth = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()
  local numTilesX = math.ceil(screenWidth / TILE_WIDTH)
  local numTilesY = math.ceil(screenHeight / TILE_HEIGHT)

  local tiles = {}
  for i = 1, numTilesX do
    for j = 1, numTilesY do
      local tile = {
        x = (i - 1) * TILE_WIDTH,
        y = (j - 1) * TILE_HEIGHT,
        width = TILE_WIDTH,
        height = TILE_HEIGHT,
        color = { math.random(), math.random(), math.random() },
      }
      table.insert(tiles, tile)
    end
  end
  return tiles
end

function drawTiles(tiles)
  for _, tile in ipairs(tiles) do
    love.graphics.setColor(tile.color)
    love.graphics.rectangle("fill", tile.x, tile.y, tile.width, tile.height)
  end
end
