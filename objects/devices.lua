local _M = {}
local buttons = require('objects.buttons')
local dials = require('objects.dials')
local battery_meters = require('objects.battery_meters')
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
  local delta = timestamp - last_timestamp
  local percent = (delta / self.decaySpeed) * 100
  last_timestamp = timestamp
  self.level = self.level - percent
  self.level = self.level + self.dial.power
  if self.level > 100 then
    self.level = 100
  elseif self.level < 0 then
    last_timestamp = nil
    Runtime:removeEventListener('enterFrame', self)
    native.showAlert("Game Over", "testing", {"start over!"}, function()
      self.level = 100
      Runtime:addEventListener('enterFrame', self)
    end)
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
  device.anchorChildren = true
  params.parent:insert(device)
  device.decaySpeed = params.decaySpeed
  device.level = 100

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

  local dial = dials.new({
    x = 0,
    y = params.height * .3,
    diameter = params.width * .55,
    parent = device,
  })
  dial.base:setFillColor(unpack(params.strokeColor))
  device.dial = dial

  local meter = battery_meters.new({
    parent = device,
    y = -params.height * .4,
    x = 0,
    width = bg.width * .85,
    height = bg.width * .15,
    cornerRadius = params.cornerRadius * .5
  })
  device.meter = meter

  device.enterFrame = update_battery
  Runtime:addEventListener('enterFrame', device)

  device.finalize = finalize
  device:addEventListener('finalize')

  device.x, device.y = params.x, params.y
  return device
end


return _M
