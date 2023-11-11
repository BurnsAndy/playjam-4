import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "hourglass"
import "vessel"

local pd <const> = playdate
local gfx <const> = pd.graphics
local p <const> = pd.geometry.point

pd.startAccelerometer()
gfx.setImageDrawMode(gfx.kDrawModeInverted)
function pd.update()
	gfx.sprite.update()
    pd.drawFPS(5,5)
    
end

--gfx.drawRect(100,100,100,100)
--Hourglass(200, 100, 100)
Vessel({
    p.new(10,10),

    p.new(190, 100),

    p.new(390,10),
    p.new(390,230),

    p.new(190, 140),

    p.new(10,230)
    },
    1,
    100)