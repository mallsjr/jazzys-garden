---@diagnostic disable: lowercase-global
local TILE_WIDTH = 64
local TILE_HEIGHT = 64
local TILES = {}
local PLAYER = {
  x = 0,
  y = 0,
  isMoving = false,
  targetX = 0,
  targetY = 0,
  moveSpeed = 8, -- Pixels per frame (adjust for faster/slower movement)
}
local adjacentTile = nil

function love.load()
  TILES = createTiles()
  -- Initialize target position to current position
  PLAYER.targetX = PLAYER.x
  PLAYER.targetY = PLAYER.y
end

function love.update(dt)
  if PLAYER.isMoving then
    -- Move toward target position
    if PLAYER.x < PLAYER.targetX then
      PLAYER.x = math.min(PLAYER.x + PLAYER.moveSpeed, PLAYER.targetX)
    elseif PLAYER.x > PLAYER.targetX then
      PLAYER.x = math.max(PLAYER.x - PLAYER.moveSpeed, PLAYER.targetX)
    end

    if PLAYER.y < PLAYER.targetY then
      PLAYER.y = math.min(PLAYER.y + PLAYER.moveSpeed, PLAYER.targetY)
    elseif PLAYER.y > PLAYER.targetY then
      PLAYER.y = math.max(PLAYER.y - PLAYER.moveSpeed, PLAYER.targetY)
    end

    -- Check if we've reached the target
    if PLAYER.x == PLAYER.targetX and PLAYER.y == PLAYER.targetY then
      PLAYER.isMoving = false
    end
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end

  -- Only accept movement input if the player is not already moving
  if not PLAYER.isMoving then
    if key == "right" then
      adjacentTile = getAdjacentTile(PLAYER, "right")
      PLAYER.targetX = PLAYER.x + TILE_WIDTH
      PLAYER.isMoving = true
    elseif key == "left" then
      adjacentTile = getAdjacentTile(PLAYER, "left")
      PLAYER.targetX = PLAYER.x - TILE_WIDTH
      PLAYER.isMoving = true
    elseif key == "down" then
      adjacentTile = getAdjacentTile(PLAYER, "down")
      PLAYER.targetY = PLAYER.y + TILE_HEIGHT
      PLAYER.isMoving = true
    elseif key == "up" then
      adjacentTile = getAdjacentTile(PLAYER, "up")
      PLAYER.targetY = PLAYER.y - TILE_HEIGHT
      PLAYER.isMoving = true
    end
  end

  if key == "space" then
    -- Change color of tile if adjacent
    if adjacentTile then
      adjacentTile.color = { 0, 0, 0 } -- Change to black
    end
  end
end

function love.draw()
  drawTiles(TILES)
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("fill", PLAYER.x, PLAYER.y, TILE_WIDTH, TILE_HEIGHT)

  -- Highlight the adjacent tile if there is one
  if adjacentTile then
    love.graphics.setColor(0, 0, 255)
    love.graphics.rectangle("line", adjacentTile.x, adjacentTile.y, TILE_WIDTH, TILE_HEIGHT)
  end
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

function getTileAtPosition(x, y, tiles)
  for _, tile in ipairs(tiles) do
    if x >= tile.x and x < tile.x + tile.width and y >= tile.y and y < tile.y + tile.height then
      return tile
    end
  end
  return nil
end

function getAdjacentTile(player, direction)
  local checkX, checkY

  if direction == "up" then
    checkX = player.x + TILE_WIDTH / 2
    checkY = player.y - 1
  elseif direction == "down" then
    checkX = player.x + TILE_WIDTH / 2
    checkY = player.y + TILE_HEIGHT + 1
  elseif direction == "left" then
    checkX = player.x - 1
    checkY = player.y + TILE_HEIGHT / 2
  elseif direction == "right" then
    checkX = player.x + TILE_WIDTH + 1
    checkY = player.y + TILE_HEIGHT / 2
  end

  return getTileAtPosition(checkX, checkY, TILES)
end
