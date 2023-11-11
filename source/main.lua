import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "hourglass"
import "vessel"

local pd <const> = playdate
local gfx <const> = pd.graphics
local p <const> = pd.geometry.point

vessel = Vessel({
    p.new(10,10),
    p.new(200, 100),
    p.new(390,10),
    p.new(390,230),
    p.new(200, 140),
    p.new(10,230)
    },
    1,
    50)

pd.startAccelerometer()
function pd.update()
	gfx.sprite.update()
    DrawVessel(vessel)
    pd.drawFPS(5,5)
end