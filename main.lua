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
---@field direction string
local PLAYER = {
  x = 0, -- Start at the top-left corner of the grid
  y = 0, -- Start at the top-left corner of the grid
  height = 64, -- Assuming player is same size as tile for simplicity
  width = 64, -- Assuming player is same size as tile for simplicity
  direction = "right", -- Default direction
}

---@type Tile
local ADJACENT_TILE = {
  x = PLAYER.x + TILE_WIDTH,
  y = PLAYER.y,
  width = TILE_WIDTH,
  height = TILE_HEIGHT,
  color = { 1, 0, 0 }, -- Red for the adjacent tile
}

function love.load()
  TILES = createTiles()
  -- Ensure player starts snapped to the grid.
  -- The initial x=0, y=0 works for the top-left tile.
  PLAYER.x = 0
  PLAYER.y = 0
end

function love.update(dt)
  findAdjacentTile(PLAYER.direction)
end

function findAdjacentTile(direction)
  -- Update the adjacent tile position based on the player's current position
  -- and current direction.
  if direction == "right" then
    if PLAYER.x + TILE_WIDTH < love.graphics.getWidth() then
      ADJACENT_TILE.x = PLAYER.x + TILE_WIDTH
      ADJACENT_TILE.y = PLAYER.y
    end
  elseif direction == "left" then
    if PLAYER.x - TILE_WIDTH >= 0 then
      ADJACENT_TILE.x = PLAYER.x - TILE_WIDTH
      ADJACENT_TILE.y = PLAYER.y
    end
  elseif direction == "down" then
    if PLAYER.y + TILE_HEIGHT < love.graphics.getHeight() then
      ADJACENT_TILE.x = PLAYER.x
      ADJACENT_TILE.y = PLAYER.y + TILE_HEIGHT
    end
  elseif direction == "up" then
    if PLAYER.y - TILE_HEIGHT >= 0 then
      ADJACENT_TILE.x = PLAYER.x
      ADJACENT_TILE.y = PLAYER.y - TILE_HEIGHT
    end
  end
end

function love.keypressed(key)
  local newX = PLAYER.x
  local newY = PLAYER.y

  if key == "right" then
    newX = PLAYER.x + TILE_WIDTH
    PLAYER.direction = "right"
  elseif key == "left" then
    newX = PLAYER.x - TILE_WIDTH
    PLAYER.direction = "left"
  elseif key == "down" then
    newY = PLAYER.y + TILE_HEIGHT
    PLAYER.direction = "down"
  elseif key == "up" then
    newY = PLAYER.y - TILE_HEIGHT
    PLAYER.direction = "up"
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
  love.graphics.setColor(ADJACENT_TILE.color)
  -- set the thickness of the rectangle outline
  love.graphics.setLineWidth(4)
  love.graphics.rectangle("line", ADJACENT_TILE.x, ADJACENT_TILE.y, ADJACENT_TILE.width, ADJACENT_TILE.height)
  -- Reset color and width for other drawings
  love.graphics.setColor(1, 1, 1)
  love.graphics.setLineWidth(1)
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
