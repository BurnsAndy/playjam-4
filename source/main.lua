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

math.randomseed(pd.getSecondsSinceEpoch())

function triggerModifierRandomly(percent)
  return percent >= math.random(1, 1000)
end

local reverseOn = false
local heavyOn = false
-- 30 fps, 150 frames = 5 seconds
local reverseTimer = 150
local heavyTimer = 150

local counterglass = Counterglass.new()
counterglass:initGfx()



function pd.update()
  gfx.sprite.update()

  if not counterglass.gameOver then
    --0.1% chance to trigger a modifier
    if triggerModifierRandomly(2) then
      reverseOn = true
      counterglass.modifiers["reverse"] = true
    end
    if reverseOn then
      reverseTimer = reverseTimer - 1
      if reverseTimer <= 0 then
        counterglass.modifiers["reverse"] = false
        reverseOn = false
        reverseTimer = 150
      end
    end

    -- 0.1% chance to trigger a modifier
    if triggerModifierRandomly(2) then
      counterglass.modifiers["heavy"] = true
      heavyOn = true
    end
    if heavyOn then
      heavyTimer = heavyTimer - 1
      if heavyTimer <= 0 then
        counterglass.modifiers["heavy"] = false
        heavyOn = false
        heavyTimer = 150
      end
    end

    counterglass:update(reverseOn, heavyOn)
    --counterglass:debugLog(reverseOn, heavyOn)

    --gfx.drawText(counterglass:debugString(reverseOn, heavyOn, true),0,0)
  else
    gfx.drawTextAligned("Press A to Start", pd.display.getWidth() /2, pd.display.getHeight() / 2, kTextAlignment.center)
    if pd.buttonJustPressed ( pd.kButtonA ) then counterglass:NewGame() end
  end

  
  gfx.drawText("Score: " .. math.floor(counterglass.score), 1, 1)
  
  gfx.drawText(counterglass:debugString(reverseOn, heavyOn, true),0,0)

end
