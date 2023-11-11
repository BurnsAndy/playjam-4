-- Define the Counterglass class
Counterglass = {}
Counterglass.__index = Counterglass

-- Constructor for Counterglass
function Counterglass.new()
  local self = setmetatable({}, Counterglass)
  self.topCounter = 100
  self.bottomCounter = 0
  self.flowRate = 0
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
function Counterglass:update(orientation)
  self.flowRate = self:getFlowRate(orientation)
  local flowAmount = self.flowRate * 0.5

  -- Ensure flow does not exceed remaining sand
  flowAmount = math.min(math.max(flowAmount, -self.bottomCounter), self.topCounter)

  self.topCounter = self.topCounter - flowAmount
  self.bottomCounter = self.bottomCounter + flowAmount
end

-- Method to display the current state of the hourglass
function Counterglass:display()
  print("Top: " .. self.topCounter .. ", Bottom: " .. self.bottomCounter .. ", Flow: " .. self.flowRate)
end
