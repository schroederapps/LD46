local _M = {}
local math = math
local click_distance = 0
local indicator_lights = require('objects.indicator_lights')
local vibrator = {vibrate = function() end}
pcall(function()
  vibrator = require('plugin.vibrator')
end)
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
    local direction = 0
    if deltaRotation/360 > 0 then
      direction = 1
    elseif deltaRotation/360 < 0 then
      direction = -1
    end
    if deltaPower > .5 then
      direction = -direction
      deltaPower = 1 - deltaPower
    end
    click_distance = click_distance + deltaPower*10
    local bad_spin = (self.mode == 'clockwise' and direction == -1) or (self.mode == 'counterclockwise' and direction == 1)
    if bad_spin then
      deltaPower = -deltaPower
    end
    if click_distance > 2 then
      if bad_spin then
        PlaySound('audio/bad_spin.wav')
        vibrator.vibrate(100)
      else
        PlaySound('audio/click.wav')
        vibrator.vibrate(1)
      end
      click_distance = 0
    end
    self.power = deltaPower*20
  elseif phase == 'cancelled' or phase == 'ended' then
    self.power = 0
    self.hasFocus = nil
    display.currentStage:setFocus(nil, event.id)
  end
end

local last_mode = ''
local function mode_listener(self)
  if self.mode ~= last_mode then
    print('changing')
    last_mode = self.mode
    if self.mode == 'clockwise' then
      self.left_glow:setFillColor(1, 0, 0)
      self.right_glow:setFillColor(0, 1, 0)
    elseif self.mode == 'counterclockwise' then
      self.left_glow:setFillColor(0, 1, 0)
      self.right_glow:setFillColor(1, 0, 0)
    else
      self.left_glow:setFillColor(0, 1, 0)
      self.right_glow:setFillColor(0, 1, 0)
    end
  end
end

--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------------------------------------
function _M.new(params)
  local params = set_defaults(params)

  local dial = display.newGroup()

  local platter = display.newCircle(dial, 0, 0, params.diameter * .5)
  platter.fill = {type = 'image', filename = 'images/dial.png'}
  dial.platter = platter

  local overlay = display.newCircle(dial, 0, 0, params.diameter * .5)
  overlay.fill = {type = 'image', filename = 'images/overlay.png'}
  overlay.blendMode = 'screen'

  local border = display.newImageRect(dial, 'images/dial_border.png', params.diameter * 1.3, params.diameter * 1.3)


  -- old clockwise labeling method
  --[[
    local counterclockwise_light = indicator_lights.new({
      parent = dial,
      x = 120,
      y = -80,
      height = 40,
      width = 40,
    })
    counterclockwise_light:set_color({0, 1, 0})
    counterclockwise_light.on = true
    local counterclockwise_label = display.newText({
      parent = dial,
      x = counterclockwise_light.x -10,
      y = counterclockwise_light.y,
      font = fonts.archistico,
      text = '⃔',
      fontSize = 50,
    })
    counterclockwise_label.rotation = -90
    counterclockwise_label.blendMode = 'multiply'
    counterclockwise_label:setFillColor(0)
    counterclockwise_label.alpha = .4

    local clockwise_light = indicator_lights.new({
      parent = dial,
      x = counterclockwise_light.x + 25,
      y = counterclockwise_light.y,
      height = 40,
      width = 40,
    })
    clockwise_light:set_color({1, 0, 0})
    clockwise_light.on = true
    local clockwise_label = display.newText({
      parent = dial,
      x = clockwise_light.x + 10,
      y = clockwise_light.y,
      font = fonts.archistico,
      text = '⃕',
      fontSize = 50,
    })
    clockwise_label.rotation = 90
    clockwise_label.blendMode = 'multiply'
    clockwise_label:setFillColor(0)
    clockwise_label.alpha = .4
  ]]--

  local left_arrow = display.newImage(dial, 'images/arrow_light.png')
  local s = platter.width * .4 / left_arrow.width
  left_arrow.xScale, left_arrow.yScale = s, s
  left_arrow.anchorX = 1
  left_arrow.anchorY = 0
  left_arrow.blendMode = 'multiply'
  left_arrow.alpha = 1
  left_arrow.y = -platter.height * .6
  left_arrow.x = -platter.width * .1

  local left_glow = display.newImage(dial, 'images/arrow_glow.png')
  for i, k in pairs({'x', 'y', 'xScale', 'yScale', 'anchorX', 'anchorY'}) do
    left_glow[k] = left_arrow[k]
  end
  left_glow.blendMode = 'add'
  left_glow:setFillColor(1, 0, 0)

  local right_arrow = display.newImage(dial, 'images/arrow_light.png')
  local s = platter.width * .4 / right_arrow.width
  right_arrow.xScale, right_arrow.yScale = -s, s
  right_arrow.anchorX = 0
  right_arrow.anchorY = 0
  right_arrow.blendMode = 'multiply'
  right_arrow.alpha = 1
  right_arrow.y = -platter.height * .6
  right_arrow.x = platter.width * .1 + right_arrow.contentWidth

  local right_glow = display.newImage(dial, 'images/arrow_glow.png')
  for i, k in pairs({'x', 'y', 'xScale', 'yScale', 'anchorX', 'anchorY'}) do
    right_glow[k] = right_arrow[k]
  end
  right_glow.blendMode = 'add'
  right_glow:setFillColor(0, 1, 0)

  dial.mode = nil
  dial.right_glow = right_glow
  dial.left_glow = left_glow

  dial.x, dial.y = params.x, params.y
  params.parent:insert(dial)
  dial.touch = touch_spin
  dial:addEventListener('touch')
  dial.power = 0

  dial.enterFrame = mode_listener
  Runtime:addEventListener('enterFrame', dial)

  return dial
end


return _M
