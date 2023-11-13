local pd <const> = playdate
local gfx <const> = pd.graphics

-- Define the Counterglass class
Counterglass = {}
Counterglass.__index = Counterglass

-- Constructor for Counterglass
function Counterglass.new()
  local self = setmetatable({}, Counterglass)
  self.topCounter = 100
  self.bottomCounter = 0
  self.flowRate = 0
  self.sprite = nil
  self.score = 0
  self.highScore = 0
  self.gameOver = true
  self.gameOverTimer = 0
  self.gameOverText = "Press A to Start"
  self.modifiers = {
    heavy = false,
    reverse = false
  }
  self.orientation = 0
  self:RetrieveHighScore()
  return self
end

-- Method to calculate flow rate based on orientation
function Counterglass:getFlowRate(orientation)
  local normalizedAngle = math.rad(orientation % 180)
  local flowRate = math.cos(normalizedAngle)

  if orientation >= 180 and orientation <= 360 then
    flowRate = -flowRate
  end

  return flowRate
end

-- Method to update the counters based on the current orientation
function Counterglass:update(reverse, heavy)
  self.orientation = (self.orientation + pd.getCrankChange() * 1) % 360
  self.flowRate = self:getFlowRate(self.orientation)

  -- Heavy sand flows at twice the rate of normal sand
  local flowModifier = 0.5
  if heavy then
    flowModifier = 1
  end
  local flowAmount = self.flowRate * flowModifier

  if reverse then
    -- Ensure flow does not exceed remaining sand
    flowAmount = math.min(math.max(flowAmount, -self.topCounter), self.bottomCounter)
    self.topCounter = self.topCounter + flowAmount
    self.bottomCounter = self.bottomCounter - flowAmount
  else
    flowAmount = math.min(math.max(flowAmount, -self.bottomCounter), self.topCounter)
    self.topCounter = self.topCounter - flowAmount
    self.bottomCounter = self.bottomCounter + flowAmount
  end

  self.score += math.abs(flowAmount)
  gfx.drawText(self:CurrentModfiers(), 1, 16)
  self.sprite:setRotation(self.orientation)
  self:DrawCounterglass()
  self:CheckGameOver()
end

-- Method to display the current state of the hourglass
function Counterglass:debugLog(reverse, heavy)
  print(self:debugString(reverse,heavy))
end

function Counterglass:debugString(reverse, heavy, seperateLines)
  local seperateLines = seperateLines or false
  return "Top: " .. self.topCounter .. (seperateLines and "\n" or ", ") ..
  "Bottom: " .. self.bottomCounter .. (seperateLines and "\n" or ", ") ..
  "Flow: " .. self.flowRate ..  (seperateLines and "\n" or ", ") ..
  "Reverse: " .. tostring(reverse) ..  (seperateLines and "\n" or ", ") ..
  "Heavy: " .. tostring(heavy) .. (seperateLines and "\n" or ", ") ..
  "gameOver: " .. tostring(self.gameOver) .. (seperateLines and "\n" or ", ") ..
  "gameOverTimer: " .. tostring(self.gameOverTimer) .. (seperateLines and "\n" or ", ") ..
  "orientation: " .. tostring(self.orientation)
end

function Counterglass:DrawCounterglass()
  if not self.gameOver then
    local image = gfx.image.new(100,200)
    gfx.pushContext(image)
      gfx.setLineWidth(2)
      gfx.drawTriangle(0,0, 100,0, 50,100)
      gfx.drawTriangle(0,200, 100,200, 50,100)
    gfx.popContext()
    gfx.pushContext(image)
      gfx.setDitherPattern(1 - self.topCounter/100)
      gfx.fillTriangle(0,0, 100,0, 50,100)
      gfx.setDitherPattern(1 - self.bottomCounter/100)
      gfx.fillTriangle(0,200, 100,200, 50,100)
    gfx.popContext()
    self.sprite:setImage(image)
  end
end

function Counterglass:initGfx()
  self.sprite = gfx.sprite.new()
  self.sprite:moveTo(200,120)
  self.sprite:add()
end

function Counterglass:CheckGameOver()
  if not self.gameOver then
    if (self.topCounter > 99 or self.bottomCounter > 99) then
      self.gameOverTimer += 1
    else
      self.gameOverTimer = 0
    end

    if self.gameOverTimer >= 30 then
      gfx.clear()
      
      self.sprite:remove()
      self.gameOverText = "GAME OVER\n" ..
      ((math.floor(self.score) > self.highScore) and "\nNew High Score!\n" or "") .. 
      "\nPress A to Try Again"
      if math.floor(self.score) > self.highScore then
        self.highScore = self.score
        self:SaveHighScore()
      end
      self.gameOver = true
    end
  end
end

function Counterglass:NewGame()
  self.score = 0
  self.gameOver = false
  self.gameOverTimer = 0
  self.topCounter = 100
  self.bottomCounter = 0
  self.flowRate = 0
  self.orientation = 0
  self:ClearModfiers()
  self:initGfx()
end

function Counterglass:ClearModfiers()
  for i=1, #self.modifiers do
    self.modifiers[i] = false
  end
end

function Counterglass:CurrentModfiers()
  return 
    (self.modifiers["heavy"] and "HEAVY\n" or "") ..
    (self.modifiers["reverse"] and "REVERSE\n" or "") 
end

function Counterglass:DrawGameOverText()
  local _, lineCount = self.gameOverText:gsub("\n","\n")
  gfx.drawTextAligned(self.gameOverText, pd.display.getWidth() /2, (pd.display.getHeight() - lineCount * gfx.getFont():getHeight())/2, kTextAlignment.center)
end

function Counterglass:SaveHighScore()
  pd.datastore.write({highScore = self.highScore})
end

function Counterglass:RetrieveHighScore()
  local datastore = pd.datastore.read()
  self.highScore = datastore and datastore.highScore or 0
end

function Counterglass:DrawScore()
  gfx.drawText("Score: " .. math.floor(self.score), 5, 1)
  gfx.drawTextAligned("High Score: " .. math.floor(self.highScore), 395, 1, kTextAlignment.right)
end