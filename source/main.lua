import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "hourglass"
import "vessel"
import "counterglass"

local pd <const> = playdate
local gfx <const> = pd.graphics
local p <const> = pd.geometry.point

math.randomseed(playdate.getSecondsSinceEpoch())

function triggerModifierRandomly(percent)
  return percent >= math.random(1, 1000)
end

local reverseOn = false
local heavyOn = false
-- 30 fps, 150 frames = 5 seconds
local reverseTimer = 150
local heavyTimer = 150

local counterglass = Counterglass.new()

function pd.update()
  -- 0.1% chance to trigger a modifier
  if triggerModifierRandomly(2) then
    reverseOn = true
  end
  if reverseOn then
    reverseTimer = reverseTimer - 1
    if reverseTimer <= 0 then
      reverseOn = false
      reverseTimer = 150
    end
  end

  -- 0.1% chance to trigger a modifier
  if triggerModifierRandomly(2) then
    heavyOn = true
  end
  if heavyOn then
    heavyTimer = heavyTimer - 1
    if heavyTimer <= 0 then
      heavyOn = false
      heavyTimer = 150
    end
  end

  counterglass:update(playdate.getCrankPosition(), reverseOn, heavyOn)
  counterglass:display(reverseOn, heavyOn)
end
