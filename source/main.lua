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

math.randomseed(pd.getSecondsSinceEpoch())

local counterglass = Counterglass.new()
counterglass:initGfx()

function pd.update()
  gfx.sprite.update()

  if not counterglass.gameOver then
    if (pd.isCrankDocked()) then pd.ui.crankIndicator:draw() end

    counterglass:update()
  else
    counterglass:DrawGameOverText()
    if pd.buttonJustPressed(pd.kButtonA) then counterglass:NewGame() end
    if pd.buttonJustPressed(pd.kButtonB) then counterglass.highScore = 0 end
  end

  counterglass:DrawScore()
  gfx.drawText(counterglass:debugString(true), 2, 120)
end
