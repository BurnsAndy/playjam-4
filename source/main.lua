import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "hourglass"
import "vessel"
import "counterglass"

local pd <const> = playdate
local gfx <const> = pd.graphics
local p <const> = pd.geometry.point
local s <const> = playdate.sound

math.randomseed(pd.getSecondsSinceEpoch())

local counterglass = Counterglass.new()
counterglass:initGfx()

local bMusic = true

function pd.update()
  gfx.sprite.update()

  if (bMusic) then
    bMusic = false
    local fileplayer = s.fileplayer.new("sounds/69")
    fileplayer:play(0)
  end

  if not counterglass.gameOver then
    if (pd.isCrankDocked()) then pd.ui.crankIndicator:draw() end
    counterglass:update()
  else
    gfx.drawTextAligned(counterglass.gameOverText, pd.display.getWidth() / 2, pd.display.getHeight() / 2,
      kTextAlignment.center)
    if pd.buttonJustPressed(pd.kButtonA) then counterglass:NewGame() end
  end


  gfx.drawText("Score: " .. math.floor(counterglass.score), 1, 1)

  -- gfx.drawText(counterglass:debugString(true),0,0)
end
