local pd <const> = playdate
local gfx <const> = pd.graphics

class("Title").extends(gfx.sprite)

function Title:init()
    Title.super.init(self)
    self:setImage(gfx.image.new( "images/logo" ))
    self:setScale(.65)
    self:moveTo(200,100)
    self:add()
end

function Title:StartGame()
    counterglass = Counterglass.new()
    counterglass:initGfx()
    counterglass:NewGame()
    self:remove()
    return counterglass
end