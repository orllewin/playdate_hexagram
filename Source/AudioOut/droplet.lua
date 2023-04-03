import 'CoreLibs/object'
import 'Coracle/math'
import 'AudioOut/orl_sample'

class('Droplet').extends()

function Droplet:init(label)
	Droplet.super.init(self)
	
	self.label = label
	
	self.rate = globalRate
end

function Droplet:delayRetry()
	playdate.timer.performAfterDelay(1000, function() 
		self:reset()
	end)
end

function Droplet:reset()
	local slot = math.floor(math.random(globalSlots))
	if playdate.file.exists("" .. slot .. ".pda") == false then
		self:delayRetry()
		return
	end
	print("Droplet " .. self.label .. " using slot: " .. slot)
	local sample = playdate.sound.sample.new("" .. slot .. ".pda")
	local sampleLength, sampleBuffer = sample:getLength()
	local sampleLengthMs = sampleLength * 1000
	local sampleRate = playdate.sound.getSampleRate()
	
	local randomMidPointMs = math.random(math.floor(sampleLengthMs))
	local maxWidthMs = sampleLengthMs
	local widthMs = math.max(2500, math.random(maxWidthMs))
		
	--Ensure subsample is within sample range
	if randomMidPointMs - widthMs/2 < 0 then
		randomMidPointMs = widthMs/2
	elseif randomMidPointMs + widthMs/2 > math.floor(sampleLengthMs) then
		randomMidPointMs = math.floor(sampleLengthMs) - widthMs/2
	end
	
	local subsampleStartMs = randomMidPointMs - (widthMs/2)
	local subsampleStartFrame = math.floor(subsampleStartMs/1000 * sampleRate)
	
	local subsampleEndMs = randomMidPointMs + (widthMs/2)
	local subsampleEndFrame = math.floor(subsampleEndMs/1000 * sampleRate)
	
	local subsample = sample:getSubsample(subsampleStartFrame, subsampleEndFrame)
	assert(subsample ~= nil, "Bad State: nil sample")
	
	--We don't need the parent sample now we have the subsample:
	sample = nil
	
	self.orlSample = OrlSample(subsample)
	self:setAttack(globalAttack)
	self:setRelease(globalRelease)
	
	self:randomise()
	print("Droplet " .. self.label .. " ready - queueing")
	self:queuePlayback()
end

function Droplet:queuePlayback()
	local futureMs = math.floor(math.random(map(self.rate, 0.0, 1.0, 30000, 5000)))
	print("Droplet " .. self.label .. " will play in " .. futureMs/1000 .. " seconds")
	playdate.timer.performAfterDelay(futureMs, function() 
		print("Droplet " .. self.label .. " play() length: " .. self.orlSample:getSeconds())
		self:play()
	end)
end

function Droplet:play()
	
	self.orlSample:play(function() 
		if math.random(100) < 25 then
			--Change subsample entirely:
			self:reset()
		else
			--Keep subsample but randomise effects/rate
			self:randomise()
			self:queuePlayback()
		end
		
	end)
end

function Droplet:randomise()
	local r = math.floor(math.random(6))
	if r == 1 then
		self.orlSample:setRate(1.0)
	elseif r == 2 then
		self.orlSample:setRate(0.5)
	elseif r == 3 then
		self.orlSample:setRate(0.25)
	elseif r == 4 then
		self.orlSample:setRate(-0.25)
	elseif r == 5 then
		self.orlSample:setRate(-0.5)
	elseif r == 6 then
		self.orlSample:setRate(-1.0)
	end
end

function Droplet:update()
	if self.orlSample ~= nil then self.orlSample:update() end
end
 
--How often the sample triggers
function Droplet:setRate(rate)
	self.rate = rate
end

function Droplet:setAttack(attack)
	if self.orlSample == nil then return end
	self.orlSample:setAttack(map(attack, 0.0, 1.0, 0, 3000))
end

function Droplet:setRelease(release)
	if self.orlSample == nil then return end
	self.orlSample:setRelease(map(release, 0.0, 1.0, 0, 3000))
end