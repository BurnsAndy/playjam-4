import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "counterglass"
import "title"

local pd <const> = playdate
local gfx <const> = pd.graphics
local p <const> = pd.geometry.point
local s <const> = playdate.sound

math.randomseed(pd.getSecondsSinceEpoch())

local counterglass = nil
local bMusic = true
local title = Title()
local crankChange = 0

function pd.update()
  gfx.sprite.update()

  if (bMusic) then
    bMusic = false
    local fileplayer = s.fileplayer.new("sounds/69")
    fileplayer:play(0)
  end

  if counterglass ~= nil then
    if not counterglass.gameOver then
      if (pd.isCrankDocked()) then pd.ui.crankIndicator:draw() end
      counterglass:update()
    else
      counterglass:DrawGameOverText()
      if pd.buttonJustPressed(pd.kButtonA) then counterglass:NewGame() end
      if pd.buttonJustPressed ( pd.kButtonB ) then counterglass.highScore = 0 end
    end
    counterglass:DrawScore()
  else
    if(pd.isCrankDocked()) then pd.ui.crankIndicator:draw(0,-180) end
    title:setRotation(title:getRotation() + pd.getCrankChange())
    gfx.drawTextAligned("Your time is up! Don't let the hourglass run out.\nPress A to Start.", pd.display.getWidth() /2, 200, kTextAlignment.center)
    if pd.buttonJustPressed ( pd.kButtonA ) then counterglass = title:StartGame(counterglass) end
  end
end
