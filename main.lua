---@diagnostic disable: lowercase-global
local sti = require("libraries/Simple-Tiled-Implementation/sti")
-- local growable_tiles = require("growable_tiles")
local anim8 = require("libraries/anim8/anim8")

---@class Tile
---@field x number
---@field y number
---@field width number
---@field height number
---@field color table
---@field growable_area boolean

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
  x = 0,
  y = 0,
  height = 64,
  width = 64,
  direction = "right",
}

---@type Tile
local ADJACENT_TILE = {
  x = PLAYER.x + TILE_WIDTH,
  y = PLAYER.y,
  width = TILE_WIDTH,
  height = TILE_HEIGHT,
  color = { 1, 0, 0 },
  growable_area = false,
}

---@class Plant
---@field x number
---@field y number
---@field texture love.Image
---@field animation any
---@field planted boolean
local PLANTS = {}

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  gameMap = sti("assets/maps/map.lua")
  TILES = createTiles()
  rose_texture = love.graphics.newImage("assets/plant.png")
  grid = anim8.newGrid(16, 32, rose_texture:getWidth(), rose_texture:getHeight())
end

function love.update(dt)
  gameMap:update(dt)
  findAdjacentTile(PLAYER.direction)

  -- Update animations for all planted plants
  for _, plant in ipairs(PLANTS) do
    if plant.planted and plant.animation then
      plant.animation:update(dt)
    end
  end
end

---@param direction string
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
  elseif key == "space" then
    -- using adjacent tile x and y check if that tile is growable
    for _, tile in ipairs(TILES) do
      if tile.x == ADJACENT_TILE.x and tile.y == ADJACENT_TILE.y then
        if tile.growable_area then
          -- Check if there's already a planted plant at this location
          local plantExists = false
          for _, plant in ipairs(PLANTS) do
            if plant.x == tile.x and plant.y == tile.y and plant.planted then
              plantExists = true
              break
            end
          end

          if not plantExists then
            -- Create a new plant at this location
            local newPlant = {
              x = tile.x,
              y = tile.y,
              texture = rose_texture,
              animation = anim8.newAnimation(grid("3-6", 1), 10, "pauseAtEnd"),
              planted = true,
            }
            table.insert(PLANTS, newPlant)
            tile.growable_area = false
          end
          break
        end
      end
    end
  elseif key == "escape" then
    love.event.quit()
  end

  -- Update player position to the new, snapped position
  PLAYER.x = newX
  PLAYER.y = newY
end

function love.draw()
  -- drawTiles(TILES)
  love.graphics.setColor(1, 1, 1)
  gameMap:drawLayer(gameMap.layers["dirt"])
  gameMap:drawLayer(gameMap.layers["grass"])
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

  -- loop through the plants and draw them
  for _, plant in ipairs(PLANTS) do
    if plant.planted and plant.texture and plant.animation then
      plant.animation:draw(plant.texture, plant.x + 16, plant.y - 16, nil, 3, 3, 4, 8)
    end
  end
end

---@return Tile[]
--- Based on the dimensions of the screen, this function creates a grid of tiles.
function createTiles()
  local screenWidth = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()
  local numTilesX = math.ceil(screenWidth / TILE_WIDTH)
  local numTilesY = math.ceil(screenHeight / TILE_HEIGHT)

  local tiles = {}
  for i = 0, numTilesX - 1 do
    for j = 0, numTilesY - 1 do
      local tile = {
        x = i * TILE_WIDTH,
        y = j * TILE_HEIGHT,
        width = TILE_WIDTH,
        height = TILE_HEIGHT,
        color = { math.random(), math.random(), math.random() },
        growable_area = false,
      }

      table.insert(tiles, tile)
    end
  end

  -- Mark growable areas
  for _, obj in pairs(gameMap.layers["grow"].objects) do
    for _, tile in ipairs(tiles) do
      if obj.x == tile.x and obj.y == tile.y then
        tile.growable_area = true
        -- this really isn't needed we don't see the tiles
        -- tile.color = { 0, 1, 0 } -- Green for growable tiles
      end
    end

    -- Initialize empty plants for tracking purposes
    local plant = {
      x = obj.x,
      y = obj.y,
      planted = false,
    }
    table.insert(PLANTS, plant)
  end

  return tiles
end

---@param tiles Tile[]
---Takes in a list of tiles and draws them on the screen.
function drawTiles(tiles)
  for _, tile in ipairs(tiles) do
    love.graphics.setColor(tile.color)
    love.graphics.rectangle("fill", tile.x, tile.y, tile.width, tile.height)
  end
end
