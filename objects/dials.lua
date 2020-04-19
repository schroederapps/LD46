local _M = {}
local math = math
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

local function normalize_vectors(obj1, obj2)
  local x1, y1 = obj1.x, obj1.y
  pcall(function()
    x1, y1 = obj1:localToContent(0, 0)
  end)
  local x2, y2 = obj2.x, obj2.y
  pcall(function()
    x2, yx = obj2:localToContent(0, 0)
  end)
  return x1, y1, x2, y2
end

local function get_distance(obj1, obj2)
  local x1, y1, x2, y2 = normalize_vectors(obj1, obj2)
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt(dx^2 + dy^2)
end

local function get_angle(obj1, obj2)
  local x1, y1, x2, y2 = normalize_vectors(obj1, obj2)
	local xDist = x1 - x2
  local yDist = y1 - y2
	local angle = math.deg(math.atan(yDist/xDist))
	if (x1 < x2) then
    angle = angle + 90
  else
    angle = angle - 90
  end
	return angle
end

local function touch_spin(self, event)
  local phase = event.phase
  local platter = self.platter
  local inBounds = get_distance(self, event) < platter.width * .5
  local angle = get_angle(self, event)
  if not inBounds then
    self.power = 0
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
    self.power = deltaPower*10
  elseif phase == 'cancelled' or phase == 'ended' then
    self.power = 0
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
  dial.base = base

  local platter = display.newCircle(dial, 0, 0, params.diameter * .5)
  platter.fill = {type = 'image', filename = 'images/dial2.png'}
  dial.platter = platter

  local overlay = display.newCircle(dial, 0, 0, params.diameter * .5)
  overlay.fill = {type = 'image', filename = 'images/overlay.png'}
  overlay.blendMode = 'screen'

  return dial
end


return _M
