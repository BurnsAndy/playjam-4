local pd <const> = playdate
local gfx <const> = pd.graphics
local p <const> = pd.geometry.point

class('Sand').extends(gfx.sprite)

function Sand:init(transform)
    Sand.super.init(self)
    local size = 5
    local image = gfx.image.new(size*2, size*2)
    gfx.pushContext(image)
        gfx.drawCircleAtPoint(size,size,size)
    gfx.popContext()
    self = gfx.sprite.new(image)
    self.transform = transform
    self.xVelocity = 0
    self.yVelocity = 0
    self.maxSpeed = math.random(10,25)/10


    self:setCollideRect(0,0,self:getSize())
    self:moveTo(self.transform.x, self.transform.y)
    self:add()
    
    function self:update()
        local ax, ay, az = pd.readAccelerometer()
        local oldPos = p.new(self.x, self.y)
        local newX, newY, collisions, collisionsLen = self:moveWithCollisions(self.x + ax, self.y + ay)
        
        if not vessel.polygon:containsPoint(newX, newY) then
            self:moveTo(oldPos:unpack())
            --is it possible to fake sliding up.down the angled side of the hourglass?
        end
    end

    function self:collisionResponse(other)
        return gfx.sprite.kCollisionTypeSlide
    end

end