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
function Counterglass:update(orientation, reverse, heavy)
  
  self.flowRate = self:getFlowRate(orientation)

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
  
  self.sprite:setRotation(orientation)
  self:DrawCounterglass()
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
  "Heavy: " .. tostring(heavy)
end

function Counterglass:DrawCounterglass()
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

function Counterglass:initGfx()
  self.sprite = gfx.sprite.new()
  self.sprite:moveTo(200,120)
  self.sprite:add()
end