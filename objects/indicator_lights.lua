local _M = {}

--------------------------------------------------------------------------------
-- PRIVATE FUNCTIONS
--------------------------------------------------------------------------------
local function set_defaults(params)
  local defaults = {
    x = centerX,
    y = centerY,
    width = 80,
    height = 80,
    parent = display.currentStage,
    anchorX = .5,
    anchorY = .5,
  }
  local params = params or {}
  for k,v in pairs(defaults) do
    if params[k] == nil then
      params[k] = v
    end
  end
  return params
end

local function set_state(self)
  local flare = self.flare
  if self.on then
    if flare.alpha <=.1 then
      if self.on_sound then
        audio.stop(32)
        audio.play(self.on_sound, {channel = 32})
      end
      print(flare.alpha)
      flare.alpha = .12
      transition.cancel(flare)
      transition.to(flare, {alpha = 1, time = 150})
    end
  else
    if flare.alpha >=.99 then
      if self.off_sound then
        audio.stop(32)
        audio.play(self.off_sound, {channel = 32})
      end
      flare.alpha = .98
      transition.cancel(flare)
      transition.to(flare, {alpha = 0, time = 150})
    end
  end
end

local function set_color(self, color)
  local color = color or {math.random(), math.random(), math.random()}
  self.flare:setFillColor(unpack(color))
end

local function finalize(self)
  Runtime:removeEventListener('enterFrame', self)
end

--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------------------------------------
function _M.new(params)
  local params = set_defaults(params)
  local light = display.newGroup()
  light.anchorChildren = true
  params.parent:insert(light)
  light.on_sound = params.on_sound
  light.off_sound = params.off_sound

  local img = display.newImage(light, 'images/round_light.png')
  local flare = display.newImage(light, 'images/light_flare.png')
  flare.blendMode = 'add'
  flare.alpha = 0

  light.flare = flare

  light.enterFrame = set_state
  Runtime:addEventListener('enterFrame', light)
  light.set_color = set_color
  light.finalize = finalize
  light:addEventListener('finalize')

  light.on = false
  local s = params.width / light.width
  light.xScale, light.yScale = s, s
  light.x, light.y = params.x, params.y
  light.anchorX, light.anchorY = params.anchorX, params.anchorY
  return light
end


return _M
