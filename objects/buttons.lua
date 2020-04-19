local _M = {}
local vibrator = require('plugin.vibrator')

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
    color = {0, 1, 0},
  }
  local params = params or {}
  for k,v in pairs(defaults) do
    if params[k] == nil then
      params[k] = v
    end
  end
  return params
end

local function button_touch(self, event)
  local phase = event.phase
  local button = self.parent
  local glow = button.glow
  local bounds = self.contentBounds
  local inBounds = (event.x >= bounds.xMin and event.x <= bounds.xMax) and (event.y >= bounds.yMin and event.y <= bounds.yMax)

  if phase == 'began' then
    self.hasFocus = true
    display.currentStage:setFocus(self, event.id)
    glow.alpha = 1
    button:dispatchEvent('button_pressed')
    if is_device then
      vibrator.cancel()
      vibrator.vibrate(1)
    end
    if button.sound then
      if is_android then
        media.playSound(button.soundfile)
      else
        audio.play(button.sound)
      end
    end
  elseif phase == 'moved' and self.hasFocus then
    if not inBounds then
      glow.alpha = 0
      self.hasFocus = nil
      display.currentStage:setFocus(nil, event.id)
    end
  elseif phase == 'cancelled' or phase == 'ended' then
    glow.alpha = 0
    self.hasFocus = nil
    display.currentStage:setFocus(nil, event.id)
  end
end

local function finalize(self)
  if self.sound then
    audio.dispose( self.sound )
  end
  Runtime:removeEventListener('enterFrame', self)
end
--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------------------------------------
function _M.new(params)
  local params = set_defaults(params)
  local button = display.newGroup()
  button.anchorChildren = true
  if params.sound then
    button.soundfile = params.sound
    button.sound = audio.loadSound(params.sound)
  end

  local img = display.newImage(button, 'images/button.png', true)

  local img2 = display.newImage(button, 'images/button2.png', true)
  img2:setFillColor(unpack(params.color))
  img2.alpha = 1
  img2.blendMode = 'multiply'

  local glow = display.newImage(button, 'images/button_glow.png', true)
  glow:setFillColor(unpack(params.color))
  glow.alpha = 0
  glow.blendMode = 'add'

  button.glow = glow
  img2.touch = button_touch
  img2:addEventListener('touch')

  local scaleX = params.width / img.width
  local scaleY = params.height / img.height
  button.xScale, button.yScale = scaleX, scaleY

  button.finalize = finalize
  button:addEventListener('finalize')


  -- placement
  button.x, button.y = params.x, params.y
  button.anchorX, button.anchorY = params.anchorX, params.anchorY
  params.parent:insert(button)
  return button
end


return _M
