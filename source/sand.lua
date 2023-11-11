local pd <const> = playdate
local gfx <const> = pd.graphics

class('Sand').extends(gfx.sprite)

function Sand:init(transform)
    Sand.super.init(self)
    local size = 3
    -- self:setImage(gfx.image.new('images/sand'))
    local image = gfx.image.new(size*2, size*2)
    gfx.pushContext(image)
        -- gfx.setColor(gfx.kColorWhite)
        gfx.drawCircleAtPoint(size,size,size)
    gfx.popContext()
    self = gfx.sprite.new(image)
    self.transform = transform
    


    self:setCollideRect(0,0,self:getSize())
    self:moveTo(self.transform.x, self.transform.y)
    self:add()
    
    function self:update()
        local transform = self.transform
        local ax, ay, az = pd.readAccelerometer()
        transform.x += ax
        transform.y += ay

        local _, _, collisions, collisionsLen = self:moveWithCollisions(transform.x + transform.xspeed,
        transform.y + transform.yspeed)
    end

    function self:collisionResponse(other)
        return gfx.sprite.kCollisionTypeSlide
    end
end