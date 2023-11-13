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
    reverse = false,
    doublecrank = false,
    halfcrank = false,
    fuck = false
  }
  -- 30 fps, 150 frames = 5 seconds
  self.modifierTimers = {
    heavy = 150,
    reverse = 150,
    doublecrank = 150,
    halfcrank = 150,
    fuck = 150
  }
  self.orientation = 0
  self:RetrieveHighScore()
  return self
end

-- Method to calculate flow rate based on orientation
function Counterglass:getFlowRate(orientation)
  local normalizedAngle = math.rad(orientation)
  local flowRate = math.cos(normalizedAngle)

  -- As score gets higher, flow rate gets faster so it's harder
  local scoreModifier = 0.1 * (self.score // 400)
  if flowRate > 0 then
    flowRate += scoreModifier
  else
    flowRate -= scoreModifier
  end

  return flowRate
end

-- Method to update the counters based on the current orientation
function Counterglass:update()
  -- Turn modifiers on and off
  self:ManageModifiers()

  -- Set crank rate
  local crankRate = 1
  local fuckValue = 0
  if self.modifiers["fuck"] then
    fuckValue = math.random(-10, 10)
  end
  if self.modifiers["doublecrank"] then
    crankRate = crankRate * 2
  end
  if self.modifiers["halfcrank"] then
    crankRate = crankRate / 2
  end

  -- Update orientation and calculate flow rate
  self.orientation = (self.orientation + (pd.getCrankChange() * crankRate) + fuckValue) % 360
  self.flowRate = self:getFlowRate(self.orientation)

  -- Heavy sand flows at twice the rate of normal sand
  local flowModifier = 0.5
  if self.modifiers["heavy"] then
    flowModifier = 1
  end
  local flowAmount = self.flowRate * flowModifier

  if self.modifiers["reverse"] then
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
function Counterglass:debugLog()
  print(self:debugString(true))
end

function Counterglass:debugString(seperateLines)
  local seperateLines = seperateLines or false
  return "Top: " .. self.topCounter .. (seperateLines and "\n" or ", ") ..
      "Bottom: " .. self.bottomCounter .. (seperateLines and "\n" or ", ") ..
      "Flow: " .. self.flowRate .. (seperateLines and "\n" or ", ") ..
      "GO: " .. tostring(self.gameOver) .. (seperateLines and "\n" or ", ") ..
      "GOT: " .. tostring(self.gameOverTimer) .. (seperateLines and "\n" or ", ") ..
      "Orient: " .. tostring(self.orientation)
end

function Counterglass:DrawCounterglass()
  if not self.gameOver then
    local image = gfx.image.new(100, 200)
    gfx.pushContext(image)
    gfx.setLineWidth(2)
    gfx.drawTriangle(0, 0, 100, 0, 50, 100)
    gfx.drawTriangle(0, 200, 100, 200, 50, 100)
    gfx.popContext()
    gfx.pushContext(image)
    gfx.setDitherPattern(1 - self.topCounter / 100)
    gfx.fillTriangle(0, 0, 100, 0, 50, 100)
    gfx.setDitherPattern(1 - self.bottomCounter / 100)
    gfx.fillTriangle(0, 200, 100, 200, 50, 100)
    gfx.popContext()
    self.sprite:setImage(image)
  end
end

function Counterglass:initGfx()
  self.sprite = gfx.sprite.new()
  self.sprite:moveTo(200, 120)
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
  for modifier, _ in pairs(self.modifiers) do
    self.modifiers[modifier] = false
    self.modifierTimers[modifier] = 150
  end
end

function Counterglass:CurrentModfiers()
  return
      (self.modifiers["heavy"] and "HEAVY\n" or "") ..
      (self.modifiers["reverse"] and "REVERSE\n" or "") ..
      (self.modifiers["doublecrank"] and "DOUBLECRANK\n" or "") ..
      (self.modifiers["halfcrank"] and "HALFCRANK\n" or "") ..
      (self.modifiers["fuck"] and "F#&K\n" or "")
end

function triggerModifierRandomly(percent)
  return percent >= math.random(1, 1000)
end

function Counterglass:ManageModifiers()
  for modifier, _ in pairs(self.modifiers) do
    --0.2% chance to trigger a modifier
    if triggerModifierRandomly(3) then
      self.modifiers[modifier] = true
    end

    -- Decrement modifier timers, reset state when timer runs out
    if self.modifiers[modifier] then
      self.modifierTimers[modifier] -= 1

      if self.modifierTimers[modifier] <= 0 then
        self.modifiers[modifier] = false
        self.modifierTimers[modifier] = 150
      end
    end
  end
end

function Counterglass:DrawGameOverText()
  local _, lineCount = self.gameOverText:gsub("\n", "\n")
  gfx.drawTextAligned(self.gameOverText, pd.display.getWidth() / 2,
    (pd.display.getHeight() - lineCount * gfx.getFont():getHeight()) / 2, kTextAlignment.center)
end

function Counterglass:SaveHighScore()
  pd.datastore.write({ highScore = self.highScore })
end

function Counterglass:RetrieveHighScore()
  local datastore = pd.datastore.read()
  self.highScore = datastore and datastore.highScore or 0
end

function Counterglass:DrawScore()
  gfx.drawText("Score: " .. math.floor(self.score), 5, 1)
  gfx.drawTextAligned("High Score: " .. math.floor(self.highScore), 395, 1, kTextAlignment.right)
end
