import 'CoreLibs/sprites.lua'
import 'CoreLibs/graphics.lua'

gfx = playdate.graphics
geo = playdate.geometry

gfx.setBackgroundColor(gfx.kColorBlack)

gfx.setColor(gfx.kColorBlack)
gfx.fillRect(0, 0, 400, 240)
gfx.setColor(gfx.kColorWhite)


local GRAVITY = 0.015
local THRUST = 0.05
local MAX_THRUST = 30

function radToDeg(rad)
	return rad * (180 / math.pi)
end

function randomFloatBetween(min, max)
	return min + math.random() * (max - min)
end

function clamp(number, min, max)
	return math.max(min, math.min(number, max))
end

function getThrust()
	local crankChange = playdate.getCrankChange()
	local clamped = clamp(crankChange, 0, MAX_THRUST)

	return clamped / MAX_THRUST
end

function randomSpeed()
	local dx = randomFloatBetween(-2, 2)
	local dy = randomFloatBetween(-0.65, 0.5)

	return dx, dy
end

local dx, dy = randomSpeed()


platform = geo.rect.new(100,100,100,10)
gfx.fillRect(platform)


local imageTable = gfx.imagetable.new('Images/lander', 5)

local lander = gfx.sprite.new()
local landerIdle = imageTable:getImage(1)

lander:setImage(landerIdle)
lander:setScale(1.5)
lander:setCenter(0.5, 0.33)
lander:moveTo(200, 20)
lander:add()

local animationFrame = 1;
local framesPerThrustLevel = 4
local thrustLevel = 0

playdate.AButtonDown = function ()
	dx, dy = randomSpeed()
	lander:moveTo(200, 20)
end

playdate.startAccelerometer()

lander.update = function()
	local gravityx, gravityy = playdate.readAccelerometer()
	local angleRadians = math.atan2(gravityx, gravityy) * -1
	local angleDeg = radToDeg(angleRadians)

	lander:setRotation(angleDeg)

	local tx = 0
	local ty = 0

	local thrust = getThrust()

	if thrust > 0 then
		tx = math.sin(angleRadians) * thrust * THRUST
		ty = -math.cos(angleRadians) * thrust * THRUST
		local currentThrustLevel = math.ceil(thrust * 4)

		local animationOffset = (currentThrustLevel - 1) * framesPerThrustLevel
		local animationStart = 2 + animationOffset
		local animationEnd = animationStart + framesPerThrustLevel - 1

		if currentThrustLevel > thrustLevel then
			animationFrame = animationStart
		else
			animationFrame += 1
		end

		thrustLevel = currentThrustLevel

		if animationFrame > animationEnd then
			animationFrame = animationStart
		end

		lander:setImage(imageTable:getImage(animationFrame))
	else
		lander:setImage(landerIdle)
	end

	local newx = lander.x + dx + tx
	local newy = lander.y + dy + ty

	dx += tx
	dy += ty + GRAVITY

	lander:moveTo(newx, newy)
end

function playdate.update()
	gfx.sprite.update()
end
