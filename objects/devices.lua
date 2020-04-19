local _M = {}
local buttons = require('objects.buttons')
local dials = require('objects.dials')
local battery_meters = require('objects.battery_meters')
local indicator_lights = require('objects.indicator_lights')
local command_bars = require('objects.command_bars')
local buttons = require('objects.buttons')
local theme = 'glass'
local button_colors = {
  glass = {
    {255/255, 50/255, 50/255},
    {234/255, 173/255, 237/255},
    {185/255, 252/255, 148/255},
    {130/255, 216/255, 213/255},
    {255/255, 232/255, 0/255},
    {235/255, 191/255, 167/255},
    {251/255, 107/255, 29/255},
    {0/255, 120/255, 191/255},
    {0/255, 150/255, 10/255},
  },
  wood_panel = {
    {255/255, 72/255, 176/255},
    {255/255, 108/255, 47/255},
    {227/255, 200/255, 150/255},
    {130/255, 216/255, 213/255},
    {255/255, 232/255, 0/255},
    {255/255, 142/255, 145/255},
    {255/255, 102/255, 94/255},
    {0/255, 120/255, 191/255},
    {0/255, 169/255, 92/255},
  }
}
local the_score = 0
--------------------------------------------------------------------------------
-- PRIVATE FUNCTIONS
--------------------------------------------------------------------------------
local function reset_game(self)
  the_score = 0
  self.level = 100
  self:shuffle()
  self.dial.mode = nil
  self.active = true
end

local function game_over(self)
  PlaySound('audio/game_over.wav')
  native.showAlert("Game Over", "Crank the battery back up to try again.", {"OK"}, function()
    self.dial.mode = nil
    self:reset()
  end)
end

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
    --if the_score < 0 then the_score = 0 end
  end
  last_timestamp = timestamp
  self.level = self.level + self.dial.power
  self.active_game_light.on = self.active
  self.score_display.text = comma_value(the_score)
  if self.level >= 100 then
    self.level = 100
    if not self.active then
      self:reset()
    end
  elseif self.level <= 0 then
    self.level = 0
    if self.active then
      last_timestamp = nil
      self.active = false
      self:game_over()
    end
  end
  self.meter.level = self.level
end

local function shuffle_buttons(self)
  display.currentStage:setFocus(nil)
  local x, y = 0, 0
  for i, button in pairs(self.buttons) do
    button:reset(200, i*30)
  end
  Shuffle(self.buttons)
  for i, button in pairs(self.buttons) do
    button.x, button.y = x, y
    if button.x + button.contentWidth > self.bg.width * .8 then
      x = 0
      y = button.y + button.contentHeight
    else
      x = x + button.contentWidth
    end
  end
end

local function button_listener(event)
  local button = event.target
  local device = button.device
  local command_bar = device.command_bar
  if device.active then
    local correct = command_bar:check_color(button.color_index)
    if correct then
      button:play()
      device.level = device.level + 5
      the_score = the_score + 100
    else
      PlaySound('audio/buzz.wav')
      device.level = device.level - 5
      the_score = the_score - 100
    end
    local shuffle1 = math.random()
    local shuffle2 = math.random()
    if math.abs(shuffle1 - shuffle2) < .05 then
      device:shuffle()
    else
      local mode1 = math.random()
      local mode2 = math.random()
      if math.abs(mode1 - mode2) < .05 then
        local n = math.random(3)
        local modes = {'clockwise', 'counterclockwise', nil}
        device.dial.mode = modes[n]
      end
    end
  end
end

local function command_bar_listener(event)
  local device = event.target.device
  the_score = the_score - 100
  device.level = device.level - 10
  PlaySound('audio/buzz.wav')
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
  local bg = display.newRoundedRect(device, 0, 0, params.width - params.strokeWidth, params.height - params.strokeWidth, params.cornerRadius)
  bg.fill = {
    type = 'image',
    filename = 'images/' .. theme .. '.png',
  }
  bg.alpha = 1
  bg.blendMode = 'screen'
  device.bg = bg

  -- add the dial
  local dial = dials.new({
    x = 0,
    y = params.height * .3,
    diameter = params.width * .55,
    parent = device,
  })
  device.dial = dial

  -- add the battery meter
  local meter = battery_meters.new({
    parent = device,
    y = -params.height * .5 + 90,
    x = 0,
    width = bg.width * .85,
    height = bg.width * .15,
    cornerRadius = params.cornerRadius * .5
  })
  device.meter = meter

  -- add the active game light (REMOVED)
  --[[
  local active_game_light = indicator_lights.new({
    parent = device,
    x = meter.x + meter.width * .5 - 15,
    y = meter.y - meter.height * .5 + 5,
    anchorX = 1,
    anchorY = 1,
    height = 30,
    width = 30,
    on_sound = 'audio/ding.wav',
    off_sound = 'audio/buzz.wav',
  })
  active_game_light:set_color({.2, 1, .2})
  active_game_light.on = false
  ]]
  device.active_game_light = active_game_light or {}

  -- add the color buttons
  local buttonGroup = display.newGroup()
  buttonGroup.anchorChildren = true
  buttonGroup.y = -60
  device:insert(buttonGroup)
  device.buttons = {}
  local x, y = 0, 0
  for i, color in pairs(button_colors[theme]) do
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
    button.color_index = i
    button:addEventListener('button_pressed', button_listener)
    button.device = device
    device.buttons[i] = button
  end
  device.shuffle = shuffle_buttons
  device:shuffle()

  -- add the command bar
  local command_bar = command_bars.new({
    parent = device,
    x = -bg.width * .5 + 50,
    y = -235,
    colors = button_colors[theme],
  })
  device.command_bar = command_bar
  command_bar.device = device
  command_bar:addEventListener('overflow', command_bar_listener)

  -- scoreboard
  local score_label = display.newText({
    parent = device,
    text = 'Score:',
    font = fonts.archistico,
    fontSize = 20,
    x = meter.x - meter.width * .5 + 23,
    y = meter.y - meter.height * .5 + 3,
  })
  score_label.anchorX, score_label.anchorY = 0, 1
  score_label:setFillColor(0)

  local score_display = display.newText({
    parent = device,
    text = comma_value(the_score),
    font = fonts.archistico,
    fontSize = 28,
    x = score_label.x + score_label.width + 5,
    y = score_label.y,
  })
  score_display.anchorX, score_display.anchorY = 0, 1
  score_display:setFillColor(0)
  device.score_display = score_display

  -- add the border
  local border = display.newImage(device, 'images/device_border.png', true)
  local border_scale = bg.width*1.1 / border.width
  border.xScale, border.yScale = border_scale, border_scale

  -- object listeners
  device.enterFrame = update_battery
  Runtime:addEventListener('enterFrame', device)

  device.reset = reset_game
  device.game_over = game_over

  device.finalize = finalize
  device:addEventListener('finalize')

  -- position & return device object
  device.anchorChildren = false
  params.parent:insert(device)
  device.x, device.y = params.x, params.y

  device:reset()
  return device
end


return _M
