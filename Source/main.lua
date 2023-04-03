import 'CoreLibs/graphics'
import "CoreLibs/object"
import 'CoreLibs/sprites'
import 'CoreLibs/timer'
import 'Coracle/math'
import 'CoracleViews/focus_manager'
import 'CoracleViews/label_left'
import 'CoracleViews/hexagram'
import 'CoracleViews/rotary_encoder_medium'
import 'AudioOut/droplet'
import 'AudioIn/source'

playdate.setCrankSoundsDisabled(true)

globalSlots = 7
for i=1,globalSlots do
	if playdate.file.exists("" .. i .. ".pda") then
		playdate.file.delete("" .. i .. ".pda")
	end
end


local graphics <const> = playdate.graphics
local sound <const> = playdate.sound

globalRate = 0.5
globalAttack = 0.2
globalRelease = 0.2

local inverted = true
playdate.display.setInverted(inverted)

graphics.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
	graphics.setColor(graphics.kColorWhite)
	graphics.fillRect(0, 0, 400, 240)
end)

local pixarlmed = graphics.font.new("Fonts/pixarlmed")
graphics.setFont(pixarlmed)

local pixarlsmol = graphics.font.new("Fonts/pixarl")

local droplets = {}

local dropletCount = 5

for i=1,dropletCount do
	droplets[i] = Droplet("".. i)
	droplets[i]:reset()
end

-- Effects --------------------------------------------------------------------------------
local globalDriveAmount = 0.0
local globalDelayDebounce = nil
local globalDelayBlocked = false

local maxDelay = 2.5
local globalDelayLength = 0.25
local globalDelayLevel = 0.35
local globalDelayFeedback = 0.35

local globalLowPassFrequency = 0.8
local globalLowPassRes = 0.2

--Hi pass: not user configurable:
local highpass = sound.twopolefilter.new(sound.kFilterHighPass)
highpass:setMix(1.0)
highpass:setFrequency(60)
highpass:setResonance(0.0)
sound.addEffect(highpass)

local globalDelay = sound.delayline.new(map(globalDelayLength, 0.0, 1.0, 0.0, maxDelay))
globalDelay:setFeedback(globalDelayFeedback)
globalDelay:setMix(0.0)
sound.addEffect(globalDelay)

local globalBitcrusher = sound.bitcrusher.new()
globalBitcrusher:setAmount(0.30)
globalBitcrusher:setUndersampling(0.55)
globalBitcrusher:setMix(globalDriveAmount)
sound.addEffect(globalBitcrusher)


local overdrive = sound.overdrive.new()
overdrive:setGain(0.0)
overdrive:setLimit(0.9)
overdrive:setMix(globalDriveAmount)
sound.addEffect(overdrive)

local lowpass = sound.twopolefilter.new(sound.kFilterLowPass)
lowpass:setMix(1.0)
lowpass:setFrequency(map(globalLowPassFrequency, 0.0, 1.0, 100, 10000))
lowpass:setResonance(globalLowPassRes)
sound.addEffect(lowpass)

function setRate(rate)
	globalRate = rate
	for i=1,dropletCount do
		droplets[i]:setRate(globalRate)
	end
end

function setAttack(attack)
	globalAttack = attack
	for i=1,dropletCount do
		droplets[i]:setAttack(value)
	end
end

function setRelease(release)
	globalRelease = release
	for i=1,dropletCount do
		droplets[i]:setRelease(value)
	end
end

function setDelayLength(length)
	
	if globalDelayBlocked then return end
	
	globalDelayBlocked = true
	globalDelayLength = length
	local mappedDelay = map(globalDelayLength, 0.0, 1.0, 0.1, maxDelay)
	print("Set delay length to: " .. length .. " mapped: " .. mappedDelay)
	sound.removeEffect(globalDelay)
	globalDelay = sound.delayline.new(mappedDelay)
	globalDelay:setFeedback(globalDelayFeedback)
	globalDelay:setMix(globalDelayLevel/2.0)
	sound.addEffect(globalDelay)
	
	globalDelayDebounce = playdate.timer.new(200, function()
		globalDelayBlocked = false
	end)
end

function setDelayFeedback(feedback)
	print("Set delay feedback to: " .. feedback)
	globalDelayFeedback = feedback
	globalDelay:setFeedback(globalDelayFeedback)
end

function setDelayLevel(level)
	print("Set delay level to: " .. level)
	globalDelayLevel = level
	globalDelay:setMix(globalDelayLevel/2.0)
end

function setDrive(drive)
	print("Drive: " .. drive)
	globalDriveAmount = drive
	globalBitcrusher:setMix(globalDriveAmount/2)
	globalBitcrusher:setAmount(globalDriveAmount*0.9)
	globalBitcrusher:setUndersampling(globalDriveAmount*0.9)
	
	overdrive:setGain(globalDriveAmount*3)
	overdrive:setMix(globalDriveAmount/2)
end

-- EO Effects -----------------------------------------------------------------------------

local source = Source()
source:start()

local focusManager = FocusManager()

local encoderXColumn1 = 73
local encoderXColumn2 = 335
local encoderYAnchor = 60
local encoderYSpacing = 50
local encoderWidth = 115

local yAnchor = 30
local smallerYSpacing = 46

-- Column 1
local rateHex = Hexagram(encoderXColumn1 + 90, yAnchor, 35, 0.5)
local rateEncoder = MediumRotaryEncoder("Trigger", "Rate", encoderXColumn1, yAnchor, encoderWidth, function(value)
	--rate change
	setRate(value)
	rateHex:cast(value)
end)
rateEncoder:setValue(globalRate)
rateHex:cast(globalRate)
focusManager:addView(rateEncoder, 1)

local attackHex = Hexagram(encoderXColumn1 + 90, yAnchor + smallerYSpacing, 35, 0.5)
local attackEncoder = MediumRotaryEncoder("Droplet", "Attack", encoderXColumn1, yAnchor + smallerYSpacing, encoderWidth, function(value)
	--attack change
	for i=1,dropletCount do
		droplets[i]:setAttack(value)
	end
	
	attackHex:cast(value)
end)
attackEncoder:setValue(globalAttack)
attackHex:cast(globalAttack)
focusManager:addView(attackEncoder, 2)

local releaseHex = Hexagram(encoderXColumn1 + 90, yAnchor + (smallerYSpacing * 2), 35, 0.5)
local releaseEncoder = MediumRotaryEncoder("Droplet", "Release", encoderXColumn1, yAnchor + (smallerYSpacing * 2), encoderWidth, function(value)
	--release change
	for i=1,dropletCount do
		droplets[i]:setRelease(value)
	end
	
	releaseHex:cast(value)
end)
releaseEncoder:setValue(globalRelease)
releaseHex:cast(globalRelease)
focusManager:addView(releaseEncoder, 3)

local driveHex = Hexagram(encoderXColumn1 + 90, yAnchor + (smallerYSpacing * 3), 35, 0.5)
local driveEncoder = MediumRotaryEncoder("Droplet", "Drive", encoderXColumn1, yAnchor + (smallerYSpacing * 3), encoderWidth, function(value)
	--Global overdrive:
	setDrive(value)
	driveHex:cast(value)
end)
driveHex:cast(0.0)
focusManager:addView(driveEncoder, 4)

--Column 2
local delayLengthHex = Hexagram(encoderXColumn2 - 95, yAnchor, 35, 0.5)
local delayLengthEncoder = MediumRotaryEncoder("Delay", "Length", encoderXColumn2, yAnchor, encoderWidth, function(value)
	--delay length change
	setDelayLength(value)
	delayLengthHex:cast(value)
end)
delayLengthEncoder:setValue(globalDelayLength)
delayLengthHex:cast(globalDelayLength)
focusManager:addView(delayLengthEncoder, 1)

local delayFeedbackHex = Hexagram(encoderXColumn2 - 95, yAnchor + smallerYSpacing, 35, 0.5)
local delayFeedbackEncoder = MediumRotaryEncoder("Delay", "FBack.", encoderXColumn2, yAnchor + smallerYSpacing, encoderWidth, function(value)
	--delay feedback change
	setDelayFeedback(value)
	delayFeedbackHex:cast(value)
end)
delayFeedbackEncoder:setValue(globalDelayFeedback)
delayFeedbackHex:cast(globalDelayFeedback)
focusManager:addView(delayFeedbackEncoder, 2)

local delayLevelHex = Hexagram(encoderXColumn2 - 95, yAnchor + (smallerYSpacing * 2), 35, 0.5)
local delayLevelEncoder = MediumRotaryEncoder("Delay", "Level", encoderXColumn2, yAnchor + (smallerYSpacing * 2), encoderWidth, function(value)
	--delay level change
	setDelayLevel(value)
	delayLevelHex:cast(value)
end)
delayLevelEncoder:setValue(globalDelayLevel)
delayLevelHex:cast(0.0)
focusManager:addView(delayLevelEncoder, 3)

local loPassFreqHex = Hexagram(encoderXColumn2 - 95, yAnchor + (smallerYSpacing * 3), 35, 0.5)
local lowPassFreqEncoder = MediumRotaryEncoder("Low Pass", "Freq.", encoderXColumn2, yAnchor + (smallerYSpacing * 3), encoderWidth, function(value)
 	globalLowPassFrequency = value
	lowpass:setFrequency(map(globalLowPassFrequency, 0.0, 1.0, 100, 10000))
	loPassFreqHex:cast(value)
end)
lowPassFreqEncoder:setValue(globalLowPassFrequency)
loPassFreqHex:cast(globalLowPassFrequency)
focusManager:addView(lowPassFreqEncoder, 4)

local loPassResHex = Hexagram(encoderXColumn2 - 95, yAnchor + (smallerYSpacing * 4), 35, 0.5)
local lowPassResEncoder = MediumRotaryEncoder("Low Pass", "Res.", encoderXColumn2, yAnchor + (smallerYSpacing * 4), encoderWidth, function(value)
	globalLowPassRes = value
	lowpass:setResonance(globalLowPassRes)
	loPassResHex:cast(value)
end)
lowPassResEncoder:setValue(globalLowPassRes)
loPassResHex:cast(globalLowPassRes)
focusManager:addView(lowPassResEncoder, 5)

focusManager:start()
focusManager:push()

graphics.setColor(graphics.kColorBlack)
local hexagramImage = graphics.image.new("Images/hexagram")
local logoSprite = graphics.sprite.new( hexagramImage )
logoSprite:moveTo(105, 215)
logoSprite:add() 


function playdate.update()
	for i=1,dropletCount do
		droplets[i]:update()
	end
	
	graphics.sprite.update()
	playdate.timer:updateTimers()
	
	--See note in Source, flag checked here to trigger next sample record:
	if source:isRecording() == false then
		source:recordSample()
	end
end

local menu = playdate.getSystemMenu()
local invertMenuItem, error = menu:addMenuItem("Invert Display", function() 
	inverted = not inverted
	playdate.display.setInverted(inverted)
end)
