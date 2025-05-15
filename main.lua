---@diagnostic disable: lowercase-global

---@class Tile
---@field x number
---@field y number
---@field width number
---@field height number
---@field color table

local TILE_WIDTH = 64
local TILE_HEIGHT = 64

---@type Tile[]
local TILES = {}

---@class Player
---@field x number
---@field y number
---@field width number
---@field height number
local PLAYER = {
  x = 0, -- Start at the top-left corner of the grid
  y = 0, -- Start at the top-left corner of the grid
  height = 64, -- Assuming player is same size as tile for simplicity
  width = 64, -- Assuming player is same size as tile for simplicity
}

function love.load()
  TILES = createTiles()
  -- Ensure player starts snapped to the grid.
  -- The initial x=0, y=0 works for the top-left tile.
  PLAYER.x = 0
  PLAYER.y = 0
end

function love.update(dt)
  -- Remove continuous movement from update
  -- Movement is now handled in keypressed
end

function love.keypressed(key)
  local newX = PLAYER.x
  local newY = PLAYER.y

  if key == "right" then
    newX = PLAYER.x + TILE_WIDTH
  elseif key == "left" then
    newX = PLAYER.x - TILE_WIDTH
  elseif key == "down" then
    newY = PLAYER.y + TILE_HEIGHT
  elseif key == "up" then
    newY = PLAYER.y - TILE_HEIGHT
  elseif key == "escape" then
    love.event.quit()
  end

  -- Optional: Add bounds checking if you don't want the player
  -- to move off-screen or outside the generated tiles.
  -- For this example, we'll allow movement outside the initial tile area.

  -- Update player position to the new, snapped position
  PLAYER.x = newX
  PLAYER.y = newY
end

function love.draw()
  drawTiles(TILES)
  -- Set draw color to white for the player
  love.graphics.setColor(1, 1, 1)
  -- Draw the player. Assuming PLAYER.x and PLAYER.y are the top-left
  -- corner coordinates for drawing.
  love.graphics.rectangle("fill", PLAYER.x, PLAYER.y, PLAYER.width, PLAYER.height)
end

---@return Tile[]
function createTiles()
  local screenWidth = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()
  local numTilesX = math.ceil(screenWidth / TILE_WIDTH)
  local numTilesY = math.ceil(screenHeight / TILE_HEIGHT)

  local tiles = {}
  for i = 0, numTilesX - 1 do -- Start from 0 for easier tile index calculation
    for j = 0, numTilesY - 1 do -- Start from 0
      local tile = {
        x = i * TILE_WIDTH, -- Calculate position based on index * size
        y = j * TILE_HEIGHT, -- Calculate position based on index * size
        width = TILE_WIDTH,
        height = TILE_HEIGHT,
        color = { math.random(), math.random(), math.random() },
      }
      table.insert(tiles, tile)
    end
  end
  return tiles
end

---@param tiles Tile[]
function drawTiles(tiles)
  for _, tile in ipairs(tiles) do
    love.graphics.setColor(tile.color)
    love.graphics.rectangle("fill", tile.x, tile.y, tile.width, tile.height)
  end
end
