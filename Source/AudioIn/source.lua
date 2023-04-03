class('Source').extends()

function Source:init()
	Source.super.init()
	self.slot = 0
	self.recording = false
end

function Source:start()
	self:recordSample()
end

function Source:recordSample()
	
	self.slot += 1
	if self.slot == globalSlots + 1 then
		self.slot = 1
	end
	
	print("recordSample() to slot " .. self.slot)
	
	self.buffer = playdate.sound.sample.new(10, playdate.sound.kFormat16bitMono)
	self.recording = true
	
	--[[
		Ideally we'd have this anonymous callback function recursively call recordSample() but
		there's a bug in the underlying implementation preventing that tidy syntax so we have to
		toggle a flag instead that's read in the main update loop to record the next subsample
		in the circular sample buffer
	--]]
	playdate.sound.micinput.recordToSample(self.buffer, function(sample)
		self.buffer:save("" .. self.slot .. ".pda")
		self.recording = false
	end)
end

function Source:isRecording()
	return self.recording
end


	