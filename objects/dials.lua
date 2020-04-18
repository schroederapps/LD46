local _M = {}
local math = math
local sqrt = math.sqrt
local click = audio.loadSound('audio/click.wav')
local click_distance = 0
local vibrator = require('plugin.vibrator')
--------------------------------------------------------------------------------
-- PRIVATE FUNCTIONS
--------------------------------------------------------------------------------
local function set_defaults(params)
  local defaults = {
    x = centerX,
    y = screenBottom - 175,
    parent = display.currentStage,
    diameter = 225,
  }
  local params = params or {}
  for k,v in pairs(defaults) do
    if params[k] == nil then
      params[k] = v
    end
  end
  return params
end

local function distance(obj1, obj2)
  local dx = obj1.x - obj2.x
  local dy = obj1.y - obj2.y
  return sqrt(dx^2 + dy^2)
end

local function angleBetween ( srcObj, dstObj )
	local xDist = dstObj.x-srcObj.x ; local yDist = dstObj.y-srcObj.y
	local angleBetween = math.deg( math.atan( yDist/xDist ) )
	if ( srcObj.x < dstObj.x ) then angleBetween = angleBetween+90 else angleBetween = angleBetween-90 end
	return angleBetween
end

local function touch_spin(self, event)
  local phase = event.phase
  local platter = self.platter
  local inBounds = distance(self, event) < platter.width * .5
  local angle = angleBetween(self, event)

  if not inBounds then
    self.hasFocus = false
    display.currentStage:setFocus(nil, event.id)
  elseif not self.hasFocus then
    self.hasFocus = true
    display.currentStage:setFocus(self, event.id)
    self.touch_angle = angle
  elseif phase == 'moved' then
    local deltaRotation = angle - self.touch_angle
    platter.rotation = platter.rotation + deltaRotation
    self.touch_angle = angle

    local deltaPower = math.abs(deltaRotation/360)
    if deltaPower > .5 then
      deltaPower = 1 - deltaPower
    end
    click_distance = click_distance + deltaPower*10
    if click_distance > 2 then
      audio.play(click)
      if is_device then
        vibrator.vibrate(1)
      end
      click_distance = 0
    end
    self.power = self.power + deltaPower
  elseif phase == 'cancelled' or phase == 'ended' then
    self.hasFocus = nil
    display.currentStage:setFocus(nil, event.id)
  end
end

--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------------------------------------
function _M.new(params)
  local params = set_defaults(params)

  local dial = display.newGroup()
  dial.x, dial.y = params.x, params.y
  params.parent:insert(dial)
  dial.touch = touch_spin
  dial:addEventListener('touch')
  dial.power = 0

  local base = display.newCircle(dial, 0, 0, params.diameter * .5 + 10)
  base.fill = {type = 'image', filename = 'images/plastic.png'}
  base.blendMode = 'multiply'

  local platter = display.newCircle(dial, 0, 0, params.diameter * .5)
  platter.fill = {type = 'image', filename = 'images/dial.png'}
  dial.platter = platter

  return dial
end


return _M
