import 'CoreLibs/object'
import 'Coracle/math'
import 'AudioOut/orl_sample'

class('BassDroplet').extends()

function BassDroplet:init(label)
	BassDroplet.super.init(self)
	
	self.label = label
	
	self.rate = globalRate
end

function BassDroplet:delayRetry()
	playdate.timer.performAfterDelay(1000, function() 
		self:reset()
	end)
end

function BassDroplet:reset(playDelay)
if playDelay ~= nil then self.playDelay = playDelay end
	local slot = math.floor(math.random(globalSlots))
	if slot == globalRecordSlot or playdate.file.exists("" .. slot .. ".pda") == false then
		self:delayRetry()
		return
	end
	print("BassDroplet " .. self.label .. " using slot: " .. slot)
	local sample = playdate.sound.sample.new("" .. slot .. ".pda")
	local sampleLength, sampleBuffer = sample:getLength()
	local sampleLengthMs = sampleLength * 1000
	local sampleRate = playdate.sound.getSampleRate()
	
	local randomMidPointMs = math.random(math.floor(sampleLengthMs))
	local maxWidthMs = math.floor(sampleLengthMs/1.5)
	local widthMs = math.max(1500, math.random(maxWidthMs))
		
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
	
	if self.orlSample ~= nil then
		self.orlSample:stopAndFree()
	end
	
	self.orlSample = OrlSample(subsample)
	self:setAttack(globalAttack)
	self:setRelease(globalRelease)
	
	self:randomise()
	print("BassDroplet " .. self.label .. " ready - queueing")
	if self.playDelay ~= nil then
		playdate.timer.performAfterDelay(self.playDelay, function() 
			self:play()
		end)
	else
		self:play()
	end
end

function BassDroplet:play()
	print("BassDroplet " .. self.label .. " playing")
	self.orlSample:play(function() 
		if math.random(100) < 35 then
			--Change subsample entirely:
			self:reset()
		else
			--Keep subsample but randomise effects/rate
			self:randomise()
			self:play()
		end
		
	end)
end

function BassDroplet:randomise()
	local r = math.floor(math.random(7))
	if r == 1 then
		self.orlSample:setRate(0.5)
	elseif r == 2 then
		self.orlSample:setRate(0.25)
	elseif r == 3 then
		self.orlSample:setRate(0.25)
	elseif r == 4 then
		self.orlSample:setRate(-0.25)
	elseif r == 5 then
		self.orlSample:setRate(-0.25)
	elseif r == 6 then
		self.orlSample:setRate(-0.25)
	else
		self.orlSample:setRate(-0.5)
	end
end

function BassDroplet:update()
	if self.orlSample ~= nil then self.orlSample:update() end
end
 
--How often the sample triggers
function BassDroplet:setRate(rate)
	--self.rate = rate
end

function BassDroplet:setAttack(attack)
	if self.orlSample == nil then return end
	--self.orlSample:setAttack(map(attack, 0.0, 1.0, 0, 3000))
end

function BassDroplet:setRelease(release)
	if self.orlSample == nil then return end
	--self.orlSample:setRelease(map(release, 0.0, 1.0, 0, 3000))
end