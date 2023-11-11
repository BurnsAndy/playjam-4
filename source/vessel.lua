import "vesselEdge"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local p <const> = geo.point

class('Vessel').extends()

--parameters:
    -- points: list of (x,y) coordinates that make up the shape
function Vessel:init(points, interval, sandAmount)
    Vessel.super.init(self)
    self.points = points
    self.sprites = {}
    self.interval = interval
    GenerateEdges(self)

    self.polygon = geo.polygon.new(table.unpack(self.points))
    self.polygon:close()
    self.sandList = {}
    SpawnSand(self, sandAmount)
end

function GenerateEdges(self)
    print(#self.points)
    local newPointArray = {}
    if (#self.points > 1) then
        for i=1,#self.points do
            local p1 = self.points[i]
            local p2 = (i < #self.points) and self.points[i + 1] or self.points[1]
            local p1x, p1y = p1:unpack()
            local p2x, p2y = p2:unpack()
            local line = geo.lineSegment.new(p1x, p1y, p2x, p2y)
            local t = self.interval
            local d = math.abs(p1:distanceToPoint(p2))
            table.insert(newPointArray, p1)
            repeat
                table.insert(newPointArray, line:pointOnLine(t))
                t = t + self.interval
            until t > d
        end
        table.insert(newPointArray, self.points[1])
        self.points = newPointArray
        for i=1,#self.points do
            local x,y = self.points[i]:unpack()
            local floorX = math.floor(x)
            local floorY = math.floor(y)
            local ceilX = math.ceil(x)
            local ceilY = math.ceil(y)
            
            table.insert(self.sprites, VesselEdge(floorX, floorY, self.interval))
            if (floorX ~= ceilX or floorY ~= ceilY) then
                table.insert(self.sprites, VesselEdge(ceilX, ceilY, self.interval))
            end
        end
    end
end

function SpawnSand(vessel, sandAmount)
    
    local vesselBounds = vessel.polygon:getBoundsRect()
    vesselBounds = vesselBounds:insetBy(10,10)
    
    local x0 = vesselBounds.x
    local y0 = vesselBounds.y
    local x1 = vesselBounds.x + vesselBounds.width
    local y1 = vesselBounds.y + vesselBounds.height
    
    for i=1,sandAmount do
        local spawnX = 0
        local spawnY = 0
        spawnX = math.random(x0, x1)
        spawnY = math.random(y0, y1)
        while not (vessel.polygon:containsPoint(spawnX,spawnY)) do
            spawnX = math.random(x0, x1)
            spawnY = math.random(y0, y1)
        end

        vessel.sandList[i] = Sand({
            x = spawnX,
            y = spawnY,
            xspeed = 0,
            yspeed = 0,
            width = 1,
            height = 1
        })
    end
end