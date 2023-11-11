import "sand"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Hourglass').extends(gfx.sprite)

function Hourglass:init(w,h,sandAmount)
    Hourglass.super.init(self)
    local image = gfx.image.new(w, h)
    gfx.pushContext(image)
        gfx.drawRect(0,0,w,h)
    gfx.popContext()
    self = gfx.sprite.new(image)
    --self:setCollideRect(0, 0, self:getSize())
    self:moveTo(200, 120)
    self:add()
    self.sandList = {}
    SpawnSand(self, sandAmount)

    function self:draw()
        print(self.x .. ", " .. self.y)
        gfx.setLineWidth(3)
        gfx.drawRect(self.x, self.y,w,h)
    end

    function self:update()
        local change, acceleratedChange = pd.getCrankChange()
        self:setRotation(self:getRotation() + change)
    end

end

function SpawnSand(hourglass, sandAmount)
    local x0 = hourglass.x - hourglass.width/2
    local y0 = hourglass.y - hourglass.height/2
    local x1 = hourglass.x + hourglass.width/2
    local y1 = hourglass.y + hourglass.height/2
    for i=1,sandAmount do
        hourglass.sandList[i] = Sand({
            x = math.random(x0, x1),
            y = math.random(y0, y1),
            xspeed = 0,
            yspeed = 2,
            width = 1,
            height = 1
        })
    end
end



