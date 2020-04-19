local _M = {}
local buttons = require('objects.buttons')
local dials = require('objects.dials')
local battery_meters = require('objects.battery_meters')
local indicator_lights = require('objects.indicator_lights')
local buttons = require('objects.buttons')
local sounds = {
  ding = audio.loadSound('audio/ding.wav'),
  buzz = audio.loadSound('audio/buzz.wav'),
}
local button_colors = {
  {255/255, 72/255, 176/255},
  {255/255, 108/255, 47/255},
  {0/255, 170/255, 147/255},
  {255/255, 232/255, 0/255},
  {130/255, 216/255, 213/255},
  {255/255, 142/255, 145/255},
  {0/255, 120/255, 191/255},
  {255/255, 102/255, 94/255},
  {0/255, 169/255, 92/255},
}
local the_score = 0
--------------------------------------------------------------------------------
-- PRIVATE FUNCTIONS
--------------------------------------------------------------------------------
local function set_defaults(params)
  local defaults = {
    x = centerX,
    y = centerY,
    height = 770,
    width = 385,
    cornerRadius = 40,
    parent = display.currentStage,
    strokeWidth = 20,
    strokeColor = {0, 0, 0},
    decaySpeed = 5000,
  }
  local params = params or {}
  for k,v in pairs(defaults) do
    if params[k] == nil then
      params[k] = v
    end
  end
  return params
end

local last_timestamp
local function update_battery(self)
  local timestamp = system.getTimer()
  if last_timestamp == nil then
    last_timestamp = timestamp
  end
  if self.active then
    local delta = timestamp - last_timestamp
    local percent = (delta / self.decaySpeed) * 100
    self.level = self.level - percent
    the_score = the_score - delta * .003
    the_score = the_score + self.dial.power * .5
    if the_score < 0 then the_score = 0 end
  end
  last_timestamp = timestamp
  self.level = self.level + self.dial.power
  self.meter.barGroup.alpha = self.level/100 + .25
  self.active_game_light.on = self.active
  self.score_display.text = comma_value(the_score)
  if self.level >= 100 then
    self.level = 100
    self.active = true
  elseif self.level <= 0 then
    if self.active then
      last_timestamp = nil
      self.active = false
      native.showAlert("Game Over", "Crank the battery back up to try again.", {"OK"}, function() the_score = 0 end)
    end
  end
  self.meter.level = self.level
end

local function finalize(self)
  Runtime:removeEventListener('enterFrame', self)
end
--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------------------------------------
function _M.new(params)
  local params = set_defaults(params)
  local device = display.newGroup()

  -- initialize device
  device.decaySpeed = params.decaySpeed
  device.level = 0

  -- draw device image
  local border = display.newRoundedRect(device, 0, 0, params.width, params.height, params.cornerRadius + params.strokeWidth * .5)
  border.fill = {
    type = 'image',
    filename = 'images/plastic.png',
  }
  border:setFillColor(unpack(params.strokeColor))

  local bg = display.newRoundedRect(device, 0, 0, params.width - params.strokeWidth, params.height - params.strokeWidth, params.cornerRadius)
  bg.fill = {
    type = 'image',
    filename = 'images/plastic.png',
  }

  -- add the dial
  local dial = dials.new({
    x = 0,
    y = params.height * .3,
    diameter = params.width * .55,
    parent = device,
  })
  dial.base:setFillColor(unpack(params.strokeColor))
  device.dial = dial

  -- add the battery meter
  local meter = battery_meters.new({
    parent = device,
    y = -params.height * .4,
    x = 0,
    width = bg.width * .85,
    height = bg.width * .15,
    cornerRadius = params.cornerRadius * .5
  })
  device.meter = meter

  -- add the active game light
  local active_game_light = indicator_lights.new({
    parent = device,
    x = meter.x + meter.width * .49,
    y = meter.y - meter.height * .5,
    anchorX = 1,
    anchorY = 1,
    height = 30,
    width = 30,
    on_sound = sounds.ding,
    off_sound = sounds.buzz,
  })
  active_game_light:set_color({0, 1, 0})
  active_game_light.on = false
  device.active_game_light = active_game_light

  -- scoreboard
  local score_label = display.newText({
    parent = device,
    text = 'SCORE:',
    font = fonts.archistico,
    fontSize = 20,
    x = meter.x - meter.width * .47,
    y = meter.y - meter.height * .5,
  })
  score_label.anchorX, score_label.anchorY = 0, 1
  score_label:setFillColor(.8)

  local score_display = display.newText({
    parent = device,
    text = comma_value(the_score),
    font = fonts.archistico,
    fontSize = 28,
    x = score_label.x + score_label.width + 5,
    y = score_label.y,
  })
  score_display.anchorX, score_display.anchorY = 0, 1
  score_display:setFillColor(1)
  device.score_display = score_display

  -- add the color buttons
  local buttonGroup = display.newGroup()
  buttonGroup.anchorChildren = true
  buttonGroup.y = -80
  device:insert(buttonGroup)
  device.buttons = {}
  local x, y = 0, 0
  for i, color in pairs(button_colors) do
    local button = buttons.new({
      parent = buttonGroup,
      x = x,
      y = y,
      anchorX = 0,
      anchorY = 0,
      width = 100,
      height = 100,
      color = color,
      sound = "audio/button"..i..".wav"
    })
    if button.x + button.contentWidth > bg.width * .8 then
      x = 0
      y = button.y + button.contentHeight + 15
    else
      x = x + button.contentWidth + 15
    end
  end


  -- object listeners
  device.enterFrame = update_battery
  Runtime:addEventListener('enterFrame', device)

  device.finalize = finalize
  device:addEventListener('finalize')

  -- position & return device object
  device.anchorChildren = false
  params.parent:insert(device)
  device.x, device.y = params.x, params.y
  return device
end


return _M
