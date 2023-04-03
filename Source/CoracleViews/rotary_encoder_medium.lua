--[[
	
]]--

import 'Coracle/math'
import 'CoracleViews/label_left'

class('MediumRotaryEncoder').extends(playdate.graphics.sprite)

local pixarlmed = playdate.graphics.font.new("Fonts/pixarlmed")
local pixarlsmol = playdate.graphics.font.new("Fonts/pixarl")

function MediumRotaryEncoder:init(title, subtitle, xx, yy, w, listener)
	MediumRotaryEncoder.super.init(self)
	
	self.listener = listener
	
	self.yy = yy
	
	
	local outerImage = playdate.graphics.image.new(30, 30, playdate.graphics.kColorWhite)
	playdate.graphics.pushContext(outerImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.drawCircleAtPoint(15, 15, 15)
	playdate.graphics.popContext()
	self.outerKnobSprite = playdate.graphics.sprite.new(outerImage)
	self.outerKnobSprite:moveTo(xx + w/2 - 20, yy)
	self.outerKnobSprite:add()

	local image = playdate.graphics.image.new(30, 30, playdate.graphics.kColorClear)
	playdate.graphics.pushContext(image)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	--playdate.graphics.fillCircleAtPoint(7, 15, 3)
	playdate.graphics.setLineWidth(2)
	playdate.graphics.drawLine(15, 15, 5, 26)
	playdate.graphics.setLineWidth(1)
	playdate.graphics.popContext()
	
	self:setImage(image)
	self:moveTo(xx + w/2 - 20, yy)
	self:add()
	
	self.hasFocus = false
	
	local nWidth, nHeight = playdate.graphics.getTextSize(subtitle)

	local focusedImage = playdate.graphics.image.new(w + 24, 44)
	playdate.graphics.pushContext(focusedImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(2)
	playdate.graphics.drawRoundRect(1, 1, w + 12, 40, 5) 
	playdate.graphics.setLineWidth(1)
	playdate.graphics.popContext()
	self.focusedSprite = playdate.graphics.sprite.new(focusedImage)
	self.focusedSprite:moveTo(xx + 1, yy + 1)
	self.focusedSprite:add()
	self.focusedSprite:setVisible(false)
	
	if title == nil and subtitle ~= nil then
		self.label = LabelLeft(subtitle, xx - w/2, yy - (nHeight/2), 0.4)
	elseif title ~= nil and subtitle ~= nil then
		playdate.graphics.setFont(pixarlsmol)
		self.label = LabelLeft(title, xx - w/2, yy - (nHeight/2) - 6, 1.0)
		playdate.graphics.setFont(pixarlmed)
		self.label = LabelLeft(subtitle, xx - w/2, yy - (nHeight/2) + 6, 0.4)
	end


	self.viewId = "unknown"
	end
	
function MediumRotaryEncoder:setViewId(viewId)
	self.viewId = viewId
end

function MediumRotaryEncoder:getViewId()
	return self.viewId
end

function MediumRotaryEncoder:removeAll()
	self.outerKnobSprite:remove()
	self.label:remove()
	self.focusedSprite:remove()
	self:remove()
end

function MediumRotaryEncoder:turn(degrees)
	if(degrees == 0.0)then return end --indicates no change from crank in this frame
	self:setRotation(math.max(0, (math.min(300, self:getRotation() + degrees))))
	if self.listener ~= nil then self.listener(round(self:getValue(), 2)) end
end

-- 0.0 to 1.0
function MediumRotaryEncoder:getValue()
	return map(self:getRotation(), 0, 300, 0.0, 1.0)
end

-- 0.0 to 1.0
function MediumRotaryEncoder:setValue(value)
	local normalised = value
	if value > 1.0 then
		normalised = 1.0
	elseif value < 0.0 then
		normalised = 0.0
	end
	self:turn(map(normalised, 0.0, 1.0, 0, 300))
	--if(self.listener ~= nil)then self.listener(round(normalised, 2)) end
end

function MediumRotaryEncoder:isFocused()
	return self.hasFocus
end

function MediumRotaryEncoder:setFocus(focus)
	self.hasFocus = focus
	self.focusedSprite:setVisible(focus)
	
	if focus == true then
		if self.onFocus ~= nil then self.onFocus() end
	end
end

function MediumRotaryEncoder:setOnFocus(onFocus, message)
	self.onFocus = onFocus
end

function MediumRotaryEncoder:getY()
	return self.yy
end