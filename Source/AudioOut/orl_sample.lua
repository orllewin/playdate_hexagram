import "CoreLibs/object"
import 'CoreLibs/easing'

class('OrlSample').extends()

function OrlSample:init(sample)
	OrlSample.super.init()
	
	assert(sample ~= nil, "Bad State: nil sample")
	
	self.sample = sample
	local sampleLength, sampleBuffer = self.sample:getLength()
	self.length = sampleLength * 1000
	
	self.player = playdate.sound.sampleplayer.new(self.sample)
	self.player:setVolume(1.0)
	
	self.attack = 250
	self.release = 150
	self.attackTimer = nil
	self.attackEasing = playdate.easingFunctions.linear
	self.attackActive = false
	
	self.releaseTimer = nil
	self.releaseEasing = playdate.easingFunctions.linear
	self.releaseActive = false
end

function OrlSample:play(onFinish)
	self.onFinish = onFinish
	self.player:play()
	self.player:setFinishCallback(function() 
		if self.onFinish ~= nil then self.onFinish() end
	end)
	if self.attack > 0.0 then
		self.player:setVolume(0.0)
		self.attackTimer = playdate.timer.new(self.attack, 0.0, 1.0)
		self.attackActive = true
		self.attackTimer.timerEndedCallback = function()
			self.attackActive = false
		end
	else
		self.player:setVolume(1.0)
	end
	if self.release > 0.0 then
		playdate.timer.performAfterDelay(self.length - self.release, function() 
			self.releaseTimer = playdate.timer.new(self.release, 1.0, 0.0, self.releaseEasing)
			self.releaseActive = true
			self.releaseTimer.timerEndedCallback = function()
				self.releaseActive = false
			end
		end)
	end
end

function OrlSample:isPlaying()
	return self.player:isPlaying()
end

function OrlSample:update()
	if self.attackActive then
		self.player:setVolume(self.attackTimer.value)
	end
	
	if self.releaseActive then
		self.player:setVolume(self.releaseTimer.value)
	end
end

function OrlSample:getSeconds()
	return self.sample:getLength()
end

function OrlSample:setAttack(ms)
	self.attack = ms
end

function OrlSample:setRelease(ms)
	self.release = ms
end

function OrlSample:setRate(rate)
	self.player:setRate(rate)
end

function OrlSample:getRate()
	return self.player:getRate()
end