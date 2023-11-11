local pd <const> = playdate
local gfx <const> = pd.graphics

class('VesselEdge').extends(gfx.sprite)

function VesselEdge:init(x,y,size)
    VesselEdge.super.init(self)
    local image = gfx.image.new(size, size)
    gfx.pushContext(image)
        gfx.drawRect(0,0,size,size)
        --gfx.drawCircleAtPoint(0,0,size,size)
    gfx.popContext()
    self = gfx.sprite.new(image)
    self:setCollideRect(0, 0, self:getSize())
    self:moveTo(x, y)
    self:add()
    --print("VesselEdge created at " .. x .. ", " .. y)
end

